//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

/*
 We will work with async code,
 so we need to keep the playground running until the end of times.
*/
PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()

/*:

 Let's take a look how to translate an async API to Combine

*/

struct MyError: Error {}

struct Conversation {
    let participants: [String]
    let messages: [String]
}

final class ConversationStore {
    func saveConversation(
        _ conversation: Conversation,
        completion: @escaping (Result<String, MyError>) -> Void
    ) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            completion(.success("Conversation saved"))
        }
    }
}

let conversation = Conversation(
    participants: ["Bojack", "Ricky"],
    messages: ["I am a famous horse", "I don't care"]
)

let store = ConversationStore()
store.saveConversation(conversation) { result in
    print(">>> \(result)")
}

final class ConversationStoreCombine {
    private let imperativeStore = ConversationStore()

    func saveConversation(
        _ conversation: Conversation
    ) -> AnyPublisher<String, MyError> {
        Future<String, MyError> { [imperativeStore] completion in
            imperativeStore.saveConversation(conversation, completion: completion)
        }.eraseToAnyPublisher()
    }
}

let combineStore = ConversationStoreCombine()
combineStore
    .saveConversation(conversation)
    .sink(
        receiveCompletion: { completion in
            print(">>> \(completion)")
        },
        receiveValue: { value in
            print(">>> \(value)")
        }
    ).store(in: &cancellables)

/*:

 While this translation works fine, we have a few gotchas.

 Future is eager evaluated

 This means if we have the following code,

 ```
 Future<Int, Never> { completion in
     print(">>> 42 from Future")
     completion(.success(42))
 }
 ```

 We will see 42 printed in the console, even that we haven't "sinked" into this publisher.

 We can "fix" that by using yet another publisher, `Deferred`

 */


let future = Future<Int, Never> { completion in
    print(">>> 42 from Future")
    completion(.success(42))
}

let deferredFuture = Deferred {
    Future<Int, Never> { completion in
        print(">>> 42 from Future wrapped in Deferred")
        completion(.success(42))
    }
}

deferredFuture
    .sink { print(">>> \($0)")}
    .store(in: &cancellables)

let zenURL = URL(string: "https://api.github.com/zen")!

struct CancelToken {
    let cancel: () -> Void
}

func request(url: URL, completion: @escaping (Result<String, Error>) -> Void) -> CancelToken {
    let task = URLSession.shared.dataTask(
        with: url,
        completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let string = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                completion(.success(string))
            }

        }
    )

    task.resume()

    return CancelToken { task.cancel() }
}

//let token = request(url: zenURL) { result in
//    print(">>> result = \(result)")
//}

func requestPublisher(url: URL) -> AnyPublisher<String, Error> {
    var token: CancelToken?
    let future = Future<String, Error> { completion in
        token = request(url: url, completion: completion)
    }.handleEvents(
        receiveCancel: {
            token?.cancel()
        }
    )

    return Deferred { future }.eraseToAnyPublisher()
}

requestPublisher(url: zenURL).sink(
    receiveCompletion: { completion in
        print(">>> request completion \(completion)")
    },
    receiveValue: { value in
        print(">>> request value \(value)")
    }
).store(in: &cancellables)

print(">>> End of Playground ✅")

//: [Next](@next)

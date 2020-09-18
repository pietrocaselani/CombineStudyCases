//: [Previous](@previous)

/*:

 ## Publishers

 The `Publisher` protocol is the core interface for the framework.

 Every `Publisher` is just like a Swift sequence.

 `[Int]` represents multiple values in space
 `Publisher<Int>` represents multiple values in time

 Most data struct classes teach us how to organise data in space,

 but not much is said about how organise data through time.

 Combine help us structuring our data through time.

 Every `Publisher` will __publish__ a sequence of values over time.

 The framework already provide a few publishers for most common uses cases.

 Let's create a few publishers and use the `sink` operator to receive the values.

 */

import Combine
import PlaygroundSupport

/*
 We will work with async code,
 so we need to keep the playground running until the end of times.
*/
PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()

/*:

 `Just` publishes only a single value.

*/

let helloPublisher = Just("Hello")

helloPublisher.sink(
    receiveValue: { value in
        print(">>> \(value)")
    }
).store(in: &cancellables)

/*:

 `sink` also provides a closure to be notified when the publisher ends the sequence of values.

*/

helloPublisher.sink(
    receiveCompletion: { completion in
        print(">>> Completion \(completion)") // finished/cancelled
    },
    receiveValue: { value in
        print(">>> \(value)")
    }
).store(in: &cancellables)

/*:

 Publishers will stop publishing values when the sequence is finished
 or when there is some error in the sequence.

 `Fail` publishes only an Error.
 This means that it will interrupt the sequence.

 */

struct MyError: Error {}

let myErrorPublisher = Fail<Int, MyError>(error: MyError())
myErrorPublisher.sink(
    receiveCompletion: { completion in
        print(">>> Fail completed with \(completion)")
    },
    receiveValue: { value in
        print(">>> This will never be printed out")
    }
).store(in: &cancellables)

/*:

 `Empty` doesn't publish values, it just finishes the sequence.

 */

Empty<Int, Never>()
    .sink { completion in
        print(">>> Empty completed with \(completion)")

    } receiveValue: { value in
        print(">>> This will never be printed out")
    }.store(in: &cancellables)


//: [Next](@next)

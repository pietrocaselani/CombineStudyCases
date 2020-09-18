//: [Previous](@previous)

import Combine
import PlaygroundSupport

/*
 We will work with async code,
 so we need to keep the playground running until the end of times.
*/
PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()


/*:

 # Subjects

 Subjects are `Publisher`s but they also expose
 an interface to outside callers to publish values.

 Combine ships with two subjects

 `CurrentValueSubject`

 A subject that wraps a single value and publishes a new element whenever the value changes.
 (a.k.a: `Bindable`)

 `PassthroughSubject`

 A subject that broadcasts elements to downstream subscribers.
 (a.k.a: `Signal`)

 Subjects are useful to transform imperative code into reactive.

 For example, our button #selector function can publish
 a value to a `PassthroughSubject` and now the button is reactive.

 We can do the same for APIs that use delegates.
 Each time the delegated is invoked, we publish a new value.

 */


let passSubject = PassthroughSubject<Int, Never>()
let statefulSubject = CurrentValueSubject<Int, Never>(42)

passSubject.send(1)

passSubject
    .filter { int -> Bool in
        int % 2 == 0
    }
    .map { $0 * $0 }
    .handleEvents(
        receiveSubscription: { subscription in
            print(">>> passSubject.receiveSubscription \(subscription)")
        },
        receiveOutput: { output in
            print(">>> passSubject.receiveOutput \(output)")
        },
        receiveCompletion: { completion in
            print(">>> passSubject.receiveCompletion \(completion)")
        },
        receiveCancel: {
            print(">>> passSubject.receiveCancel")
        },
        receiveRequest: { demand in
            print(">>> passSubject.receiveRequest \(demand)")
        }
    )
    .sink { _ in }
    .store(in: &cancellables)

passSubject.send(2)
passSubject.send(3)
passSubject.send(4)

// Lets finish the signal and see what happens
passSubject.send(completion: .finished)
passSubject.send(2)
passSubject.send(3)
passSubject.send(4)

// CurrentValueSubject has the same API
// As soon you subscribe, you will get the current value
statefulSubject.sink { print(">>> statefulSubject.sink \($0)") }.store(in: &cancellables)

statefulSubject.send(1)
statefulSubject.send(2)

print(">>> statefulSubject.value = \(statefulSubject.value)")

statefulSubject.send(3)
statefulSubject.send(4)

//: [Next](@next)

//: [Previous](@previous)

/*:

 If your test target exposes a `Publisher`, what should be asserted of it?

 `Publishers` are essentially encapsulated asynchronous operations:

     Do you need to assert the time the operation took?
     Do you need to assert only the results? Then how do you block execution while waiting for the stream to end?
     Do you need to assert which events are sent while modifying the source? Then how do you check the values received?

 How would you create a testing hot/cold publisher?
 Which would work better for your test?

 */

//: [Next](@next)

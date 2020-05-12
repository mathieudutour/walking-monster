import Foundation

// Listeners are updatable and have an identifier so they can be compared
protocol Subscriber {
  func update(state: State, previousState: State, initialRender: Bool)
  var identifier: String { get set }
}

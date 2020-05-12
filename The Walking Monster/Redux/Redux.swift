import HealthKit
import UIKit

class Redux {
  static let sharedInstance: Redux = {
    let instance = Redux()
    return instance
  }()

  private var subscribers: [Subscriber] = []

  var healthStore: HKHealthStore?
  var icloudStore = NSUbiquitousKeyValueStore()
  var timer: Timer?

  var previousState = State()
  var state = State()

  init() {
    initialState()
  }

  func dispatch() {
    subscribers.forEach { $0.update(state: self.state, previousState: self.previousState, initialRender: false) }
    previousState = state.deepCopy()

    syncChanges()
  }

  // helper that can be use in implementations of Subscribers to make it unique and identifieable so it can be filtered (see `unsubscribe`).
  static func generateIdentifier() -> String {
    return NSUUID().uuidString
  }

  static func subscribe(listener: Subscriber) {
    let instance = Redux.sharedInstance
    instance.subscribers.append(listener)
    listener.update(state: instance.state, previousState: instance.previousState, initialRender: true)
  }

  static func unsubscribe(listener: Subscriber) {
    let instance = Redux.sharedInstance
    instance.subscribers = instance.subscribers.filter { $0.identifier != listener.identifier }
  }
}

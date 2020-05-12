import HealthKit
import UIKit

let WALKING_TYPE = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

// MARK: - initial state

extension Redux {
  func initialState() {
    state.firstLaunch = getStoredFirstLaunch()
    state.endDate = getStoredEndDate()

    let healthKitAvailable = HKHealthStore.isHealthDataAvailable()
    if !healthKitAvailable {
      state.healthKitUnavailable = true
      state.loading = false
      dispatch()
      return
    }

    healthStore = HKHealthStore()
    let allTypes = Set(arrayLiteral: WALKING_TYPE)
    healthStore?.getRequestStatusForAuthorization(toShare: Set(), read: allTypes) { authorizationStatus, _ in
      let authorized = authorizationStatus == .unnecessary
      self.state.needToOnboard = !authorized
      self.state.healthKitAuthorized = authorized
      if authorized {
        self.enableHealthKitBackgroundFetch()
      }
      self.state.loading = false
      self.dispatch()
    }
  }

  static func onboardingDone() {
    let instance = Redux.sharedInstance
    instance.state.needToOnboard = false
    instance.dispatch()
  }
}

// MARK: - HealthKit
extension Redux {
  static func requestHealthKit(complete: @escaping (_ error: Error?) -> Void) {
    let instance = Redux.sharedInstance
    let allTypes = Set(arrayLiteral: WALKING_TYPE)

    instance.healthStore?.requestAuthorization(toShare: Set(), read: allTypes) { _, error in
      if let error = error {
        complete(error)
        return
      }

      instance.state.healthKitAuthorized = true
      instance.enableHealthKitBackgroundFetch()

      complete(nil)
    }
  }

  private func enableHealthKitBackgroundFetch() {
    let backgroundQuery = HKObserverQuery(sampleType: WALKING_TYPE, predicate: nil) { _, completionHandler, error in
      if let error = error {
        // TODO: Perform Proper Error Handling Here...
        print("*** An error occured while setting up the stepCount observer. \(error.localizedDescription) ***")
        return
      }

      let predicate = HKQuery.predicateForSamples(withStart: self.state.firstLaunch, end: NSDate() as Date, options: .strictStartDate)

      let query = HKStatisticsQuery(quantityType: WALKING_TYPE, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
        guard let result = result, let sum = result.sumQuantity() else {
          print(error ?? "unknown error when fetching the healthkit statistic query")
          completionHandler()
          return
        }
        self.state.setStepsSinceLaunch(Int(sum.doubleValue(for: HKUnit.count())))
        self.dispatch()
      }

      self.healthStore?.execute(query)
    }

    healthStore?.execute(backgroundQuery)

    healthStore?.enableBackgroundDelivery(for: WALKING_TYPE, frequency: HKUpdateFrequency.hourly, withCompletion: { success, error in
      if !success {
        // TODO:
        print(error ?? "unknown error while enabling background delivery")
      }
    })
  }
}

extension Redux {
  static func startRefresh() {
    let instance = Redux.sharedInstance
    if instance.timer != nil {
      return
    }
    let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
      let _instance = Redux.sharedInstance
      let predicate = HKQuery.predicateForSamples(withStart: _instance.state.firstLaunch, end: NSDate() as Date, options: .strictStartDate)

      let query = HKStatisticsQuery(quantityType: WALKING_TYPE, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
        guard let result = result, let sum = result.sumQuantity() else {
          // TODO:
          return
        }
        _instance.state.setStepsSinceLaunch(Int(sum.doubleValue(for: HKUnit.count())))
        _instance.dispatch()
        if _instance.state.endDate != nil {
          Redux.stopRefresh()
        }
      }

      _instance.healthStore?.execute(query)
    })
    timer.tolerance = 0.5
    instance.timer = timer
  }

  static func stopRefresh() {
    let instance = Redux.sharedInstance
    if let timer = instance.timer {
      timer.invalidate()
      instance.timer = nil
    }
  }
}

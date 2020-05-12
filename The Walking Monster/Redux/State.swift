import UIKit

private let SECONDS_PER_DAY: Double = (60 * 60 * 24)
private let STEPS_PER_DAY = 4000
private let INCREASE_PER_DAY = 10
private let INITIAL_STEPS = 4000

class State: NSObject {
  var loading = true
  var needToOnboard = false
  var healthKitUnavailable = false
  var healthKitAuthorized = false
  var firstLaunch: Date?
  var endDate: Date?
  var stepsSinceLaunch: Int = 0
  var stepsLeft: Int = INITIAL_STEPS

  func deepCopy() -> State {
    let stateCopy = State()
    stateCopy.loading = loading
    stateCopy.needToOnboard = needToOnboard
    stateCopy.healthKitUnavailable = healthKitUnavailable
    stateCopy.healthKitAuthorized = healthKitAuthorized
    stateCopy.firstLaunch = firstLaunch
    stateCopy.stepsSinceLaunch = stepsSinceLaunch
    stateCopy.endDate = endDate
    return stateCopy
  }
}

extension State {
  private func monsterSteps() -> Int {
    guard let startDate = self.firstLaunch else {
      return 0
    }
    let secondSinceLaunch = -startDate.timeIntervalSinceNow
    let numberOfDays = Int(secondSinceLaunch / SECONDS_PER_DAY)

    let daysStepsWithoutIncrease = numberOfDays * STEPS_PER_DAY
    // sum (1..n) = n * (n + 1) / 2
    let increaseSteps = INCREASE_PER_DAY * numberOfDays * (numberOfDays + 1) / 2
    let secondsSteps = Double(INCREASE_PER_DAY * numberOfDays + STEPS_PER_DAY) * (Double(secondSinceLaunch) - Double(numberOfDays) * SECONDS_PER_DAY) / SECONDS_PER_DAY

    return daysStepsWithoutIncrease + increaseSteps + Int(secondsSteps)
  }

  func setStepsSinceLaunch(_ steps: Int) {
    if endDate != nil {
      // we already lost, no need to continue
      return
    }
    stepsSinceLaunch = steps
    refreshSteps()
  }

  private func refreshSteps() {
    if endDate != nil {
      // we already lost, no need to continue
      return
    }
    let stepsLeft = INITIAL_STEPS + stepsSinceLaunch - monsterSteps()

    if stepsLeft <= 0 {
      self.stepsLeft = 0
      endDate = NSDate() as Date
      Redux.sendNotification(identifier: "walking-monster.fail", title: "Oh no! The Walking Monster caught you!")
    } else {
      self.stepsLeft = stepsLeft
    }
  }
}

import BLTNBoard
import SwiftGifOrigin
import UIKit
import UserNotifications

class OnboardingController: UIViewController {
  lazy var bulletinManager: BLTNItemManager = {
    let healthkitPrimer = createHealthKitPrimer()

    return BLTNItemManager(rootItem: healthkitPrimer)

  }()

  @IBOutlet var getStartedButton: UIButton!
  @IBOutlet var background: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()

    getStartedButton.layer.cornerRadius = 12
    background.image = UIImage.gif(name: "WalkingMonster")
    bulletinManager.backgroundViewStyle = .blurredDark
  }

  @IBAction func onGetStarted(_: Any) {
    bulletinManager.showBulletin(above: self)
  }
}

extension OnboardingController {
  fileprivate func createHealthKitPrimer() -> BLTNPageItem {
    let healthkitPrimer = BLTNPageItem(title: "Health Kit")

    healthkitPrimer.isDismissable = false

    healthkitPrimer.descriptionText = "If you want any chance to escape the monster, we need to check how much you try to avoid it by looking at your daily steps. We won't do anything with it, pinky promise."
    healthkitPrimer.actionButtonTitle = "Sounds Good"
    healthkitPrimer.image = #imageLiteral(resourceName: "HealthKitPrompt")
    healthkitPrimer.imageAccessibilityLabel = "Steps Icon"

    healthkitPrimer.appearance.actionButtonColor = PRIMARY_COLOR
    healthkitPrimer.appearance.actionButtonTitleColor = BACKGROUND_COLOR

    healthkitPrimer.actionHandler = { item in
      item.manager?.displayActivityIndicator(color: BACKGROUND_COLOR)
      Redux.requestHealthKit() { error in
        if let error = error {
          // TODO:
          print(error)
          DispatchQueue.main.async {
            item.manager?.hideActivityIndicator()
          }
          return
        }
        DispatchQueue.main.async {
          let notificationPrimer = self.createNotificationPrimer()
          item.manager?.push(item: notificationPrimer)
        }
      }
    }

    return healthkitPrimer
  }

  fileprivate func createNotificationPrimer() -> BLTNPageItem {
    let notificationPrimer = BLTNPageItem(title: "Notifications")

    notificationPrimer.isDismissable = false

    notificationPrimer.descriptionText = "We can keep you up to date with the progress of the monster from time to time."
    notificationPrimer.actionButtonTitle = "Sounds Good"
    notificationPrimer.alternativeButtonTitle = "I'll Pass"
    notificationPrimer.image = #imageLiteral(resourceName: "NotificationPrompt")
    notificationPrimer.imageAccessibilityLabel = "Notifications Icon"

    notificationPrimer.appearance.actionButtonColor = PRIMARY_COLOR
    notificationPrimer.appearance.actionButtonTitleColor = BACKGROUND_COLOR
    notificationPrimer.appearance.alternativeButtonTitleColor = PRIMARY_COLOR

    notificationPrimer.presentationHandler = { item in
      DispatchQueue.main.async {
        item.manager?.hideActivityIndicator()
      }
    }

    notificationPrimer.actionHandler = { item in
      item.manager?.displayActivityIndicator(color: BACKGROUND_COLOR)
      Redux.requestNotifications { _ in
        DispatchQueue.main.async {
          Redux.onboardingDone()
          item.manager?.dismissBulletin(animated: true)
        }
      }
    }

    notificationPrimer.alternativeHandler = { _ in
      Redux.onboardingDone()
    }

    return notificationPrimer
  }
}

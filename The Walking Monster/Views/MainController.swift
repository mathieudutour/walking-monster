
import SwiftGifOrigin
import UIKit
import UserNotifications

class MainController: UIViewController, Subscriber {
  var identifier = Redux.generateIdentifier()

  @IBOutlet var background: UIImageView!
  @IBOutlet var steps: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    Redux.subscribe(listener: self)

    background.image = UIImage.gif(name: "WalkingMonster")
  }

  func update(state: State, previousState _: State, initialRender _: Bool) {
    DispatchQueue.main.async {
      self.steps.text = String(state.stepsLeft)
    }
  }
}

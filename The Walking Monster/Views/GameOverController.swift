import UIKit
import UserNotifications

class GameOverController: UIViewController, Subscriber {
  var identifier = Redux.generateIdentifier()
  @IBOutlet weak var result: UILabel!
  @IBOutlet weak var share: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    share.layer.cornerRadius = 12
    Redux.subscribe(listener: self)
  }

  func update(state: State, previousState _: State, initialRender _: Bool) {
    DispatchQueue.main.async {
      guard let startDate = state.firstLaunch, let endDate = state.endDate else {
        return
      }
      self.result.text = "You escaped me for \(Int(endDate.timeIntervalSince(startDate) / 3600)) hours - or \(state.stepsSinceLaunch) steps. That's impressive."
    }
  }

  @IBAction func onShare(_ sender: Any) {
    guard let startDate = Redux.sharedInstance.state.firstLaunch, let endDate = Redux.sharedInstance.state.endDate else {
      return
    }
    let stepsSinceLaunch = Redux.sharedInstance.state.stepsSinceLaunch

    // text to share
    let text = "I escaped the Walking Monster for \(Int(endDate.timeIntervalSince(startDate) / 3600)) hours - or \(stepsSinceLaunch) steps. Would you be able to walk further?"
    let website = URL(string:"https://apps.apple.com/app/walking-monster/id1023212254")!

    // set up activity view controller
    let activityViewController = UIActivityViewController(activityItems: [text, website], applicationActivities: nil)

    // present the view controller
    present(activityViewController, animated: true)
  }
}

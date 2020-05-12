//
//  Router.swift
//  The Walking Monster
//
//  Created by Mathieu Dutour on 04/07/2018.
//  Copyright © 2018 Mathieu Dutour. All rights reserved.
//

import UIKit

class Router: UINavigationController, Subscriber {
  var identifier = Redux.generateIdentifier()

  override func viewDidLoad() {
    super.viewDidLoad()
    setNavigationBarHidden(true, animated: false)
    Redux.subscribe(listener: self)
  }

  deinit {
    Redux.unsubscribe(listener: self)
  }

  func update(state: State, previousState: State, initialRender: Bool) {
    DispatchQueue.main.async {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      if state.loading, previousState.loading != state.loading {
        self.setViewControllers([storyboard.instantiateViewController(withIdentifier: "Loading")], animated: false)
      } else if state.healthKitUnavailable, previousState.healthKitUnavailable != state.healthKitUnavailable || initialRender {
        self.setViewControllers([storyboard.instantiateViewController(withIdentifier: "HealthKitUnavailable")], animated: false)
      } else if state.needToOnboard, previousState.needToOnboard != state.needToOnboard || initialRender {
        self.setViewControllers([storyboard.instantiateViewController(withIdentifier: "Onboarding")], animated: false)
      } else if state.healthKitAuthorized, previousState.healthKitAuthorized != state.healthKitAuthorized || initialRender {
        self.setViewControllers([storyboard.instantiateViewController(withIdentifier: "In")], animated: false)
      } else if state.endDate != nil, previousState.endDate != state.endDate || initialRender {
        self.setViewControllers([storyboard.instantiateViewController(withIdentifier: "GameOver")], animated: false)
      }
    }
  }
}

//
//  Redux+storage.swift
//  The Walking Monster
//
//  Created by Mathieu Dutour on 08/07/2018.
//  Copyright © 2018 Mathieu Dutour. All rights reserved.
//

import UIKit

extension Redux {
  func syncChanges() {
    var modified = false

    if let firstLaunch = self.state.firstLaunch, firstLaunch != self.previousState.firstLaunch {
      icloudStore.set(Double(firstLaunch.timeIntervalSince1970), forKey: "firstLaunch")
      modified = true
    }

    if let endDate = self.state.endDate, endDate != self.previousState.endDate {
      icloudStore.set(Double(endDate.timeIntervalSince1970), forKey: "endDate")
      modified = true
    }

    if modified {
      icloudStore.synchronize()
    }
  }

  func getStoredFirstLaunch() -> Date {
    let firstLaunchTimestamp = icloudStore.double(forKey: "firstLaunch")
    var firstLaunch: Date
    if firstLaunchTimestamp > 0 {
      firstLaunch = Date(timeIntervalSince1970: firstLaunchTimestamp)
    } else {
      firstLaunch = NSDate() as Date
      icloudStore.set(Double(firstLaunch.timeIntervalSince1970), forKey: "firstLaunch")
      icloudStore.synchronize()
    }

    return firstLaunch
  }

  func getStoredEndDate() -> Date? {
    let endDateTimestamp = icloudStore.double(forKey: "endDate")
    if endDateTimestamp > 0 {
      return Date(timeIntervalSince1970: endDateTimestamp)
    }
    return nil
  }
}

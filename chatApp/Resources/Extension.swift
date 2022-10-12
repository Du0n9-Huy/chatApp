//
//  Extension.swift
//  chatApp
//
//  Created by huy on 22/09/2022.
//

import Foundation
import UIKit

extension UIView {
    var width: CGFloat {
        return frame.width
    }

    var height: CGFloat {
        return frame.height
    }

    var left: CGFloat {
        return frame.origin.x
    }

    var right: CGFloat {
        return left + width
    }

    var top: CGFloat {
        return frame.origin.y
    }

    var bottom: CGFloat {
        return top + height
    }
}

extension Notification.Name {
    static let didGoogleLogInNotification = Notification.Name("didGoogleLogInNotification")
}

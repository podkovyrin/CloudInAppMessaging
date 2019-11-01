//
//  UIView+Animations.swift
//  TwoFAuth
//
//  Created by Andrew Podkovyrin on 7/29/19.
//  Copyright © 2019 2FAuth. All rights reserved.
//

import UIKit

extension UIView {
    class func animate(delay: TimeInterval = 0, animations: @escaping () -> Void,
                       completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3,
                       delay: delay,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: [.curveEaseInOut],
                       animations: animations,
                       completion: completion)
    }

    func shakeView() {
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        shakeAnimation.duration = 0.5
        shakeAnimation.values = [-24, 24, -16, 16, -8, 8, -4, 4, 0]
        layer.add(shakeAnimation, forKey: "shake-animation")
    }
}

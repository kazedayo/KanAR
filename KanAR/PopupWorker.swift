//
//  PopupWorker.swift
//  KanAR
//
//  Created by Kin Wa Lam on 10/3/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import Foundation
import UIKit
import SwiftEntryKit

class PopupWorker {
    
    static let sharedInstance = PopupWorker()
    
    func showPopup(title: String, desc: String, bgcolor: EKColor, fontcolor: EKColor, duration: Double) {
        var attributes = EKAttributes.topFloat
        let titleText = title
        let descText = desc
        
        attributes.statusBar = .light
        attributes.displayDuration = duration
        attributes.screenInteraction = .forward
        attributes.roundCorners = .all(radius: 10)
        attributes.entryBackground = .color(color: bgcolor)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.5)
            let heightConstraint = EKAttributes.PositionConstraints.Edge.intrinsic
            attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        }
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))

        let title = EKProperty.LabelContent(text: titleText, style: .init(font: .preferredFont(forTextStyle: .title1), color: fontcolor))
        let description = EKProperty.LabelContent(text: descText, style: .init(font: .preferredFont(forTextStyle: .body), color: fontcolor))
        let simpleMessage = EKSimpleMessage(title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}

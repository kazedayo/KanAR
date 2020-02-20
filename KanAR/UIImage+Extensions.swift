//
//  UIImage+Extensions.swift
//  KanAR
//
//  Created by Kin Wa Lam on 20/2/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        var rect: CGRect!
        if (UIScreen.main.scale == 2.0) {
            rect = CGRect(x: 0, y: 0, width: size.width/2, height: size.width/2)
        } else if (UIScreen.main.scale == 3.0) {
            rect = CGRect(x: 0, y: 0, width: size.width/3, height: size.width/3)
        }
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    func image(byDrawingImage image: UIImage, inRect rect: CGRect) -> UIImage! {
        UIGraphicsBeginImageContext(size)

        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

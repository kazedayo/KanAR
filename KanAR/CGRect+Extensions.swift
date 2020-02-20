//
//  CGRect+Extensions.swift
//  KanAR
//
//  Created by Kin Wa Lam on 20/2/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}

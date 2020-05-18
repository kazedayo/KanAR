//
//  DailyRecord.swift
//  KanAR
//
//  Created by Kin Wa Lam on 18/5/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import RealmSwift

class DailyRecord: Object {
    @objc dynamic var date = Date()
    @objc dynamic var writeCount = 0
    @objc dynamic var correctWriteCount = 0
    @objc dynamic var speakCount = 0
    @objc dynamic var correctSpeakCount = 0
}

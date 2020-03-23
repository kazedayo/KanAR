//
//  ProgressRecord.swift
//  KanAR
//
//  Created by Kin Wa Lam on 21/3/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import RealmSwift

class ProgressRecord: Object {
    @objc dynamic var characterName = ""
    @objc dynamic var character = ""
    @objc dynamic var writeCount = 0
    @objc dynamic var speakCount = 0
    
    override static func primaryKey() -> String? {
        return "characterName"
    }
}

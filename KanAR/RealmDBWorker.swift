//
//  RealmDBWorker.swift
//  KanAR
//
//  Created by Kin Wa Lam on 21/3/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class RealmDBWorker {
    let realm = try! Realm()
    
    private func createRecord(name: String,char: String) {
        let newRecord = ProgressRecord()
        newRecord.characterName = name
        newRecord.character = char
        newRecord.writeCount = 0
        newRecord.speakCount = 0
        
        try! realm.write {
            realm.add(newRecord)
        }
    }
    
    public func initRecords() {
        //load KanaData.json
        let path = Bundle.main.path(forResource: "KanaData", ofType: "json")
        let jsonString = try! String(contentsOfFile: path!, encoding: .utf8)
        let recordSet = JSON(parseJSON: jsonString)
        for (_,object) in recordSet["Kana"] {
            createRecord(name: object["name"].stringValue, char: object["char"].stringValue)
        }
    }
    
    func updateRecord(name: String,type: String) {
        let targetRecord = realm.objects(ProgressRecord.self).filter("characterName = '\(name)'")
        let record = targetRecord.first!
        try! realm.write {
            if type == "write" {
                record.writeCount+=1
            } else if type == "speak" {
                record.speakCount+=1
            }
            realm.add(record,update: .modified)
        }
    }
    
    func retrieveRecords(type: String) -> Results<ProgressRecord> {
        return realm.objects(ProgressRecord.self).filter("characterName CONTAINS '\(type)'")
    }
}

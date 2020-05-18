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
    static let sharedInstance = RealmDBWorker()
    
    let realm = try! Realm()
    
    private func createRecord(name: String,char: String) {
        let newRecord = ProgressRecord()
        newRecord.characterName = name
        newRecord.character = char
        let dailyRecord = DailyRecord()
        dailyRecord.date = Date().onlyDate!
        newRecord.dailyRecords.append(dailyRecord)
        
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
    
    func updateRecord(name: String,type: String,correct: Bool) {
        let targetRecord = realm.objects(ProgressRecord.self).filter("characterName = '\(name)'")
        let record = targetRecord.first!
        try! realm.write {
            if (record.dailyRecords.filter("date = %@", Date().onlyDate!).count == 0) {
                let dailyRecord = DailyRecord()
                dailyRecord.date = Date().onlyDate!
                record.dailyRecords.append(dailyRecord)
            }
            if type == "write" {
                record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.writeCount += 1
                if correct == true {
                    record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.correctWriteCount += 1
                }
            } else if type == "speak" {
                record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.speakCount += 1
                if correct == true {
                    record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.correctSpeakCount += 1
                }
            }
            realm.add(record,update: .modified)
        }
    }
    
    func retrieveRecords(type: String) -> Results<ProgressRecord> {
        return realm.objects(ProgressRecord.self).filter("characterName CONTAINS '\(type)'")
    }
}

extension Date {

    var onlyDate: Date? {
        get {
            let calender = Calendar.current
            var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system
            return calender.date(from: dateComponents)
        }
    }
    
    static func changeDaysBy(days : Int) -> Date {
      let currentDate = Date()
      var dateComponents = DateComponents()
      dateComponents.day = days
      return Calendar.current.date(byAdding: dateComponents, to: currentDate)!
    }

}

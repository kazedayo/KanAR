//
//  ProgressDetailViewController.swift
//  KanAR
//
//  Created by Kin Wa Lam on 25/3/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import UIKit
import RealmSwift

class ProgressDetailViewController: UIViewController {
    
    @IBOutlet weak var charLabel: UILabel!
    @IBOutlet weak var writeCountLabel: UILabel!
    @IBOutlet weak var speakCountLabel: UILabel!
    @IBOutlet weak var correctWriteCountLabel: UILabel!
    @IBOutlet weak var correctSpokeCountLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    var char = ""
    var record = ProgressRecord()
    var writeCount = 0
    var speakCount = 0
    var correctWriteCount = 0
    var correctSpeakCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        charLabel.text = char
        setTexts()
        setConfidence()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func switchDate(_ sender: UISegmentedControl) {
        reset()
        switch sender.selectedSegmentIndex {
        case 0:
            writeCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.writeCount
            speakCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.speakCount
            correctWriteCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.correctWriteCount
            correctSpeakCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.correctSpeakCount
            setTexts()
            setConfidence()
            break
        case 1:
            let startDate = Date.changeDaysBy(days: -7)
            let endDate = Date().onlyDate!
            let records = record.dailyRecords.filter("date BETWEEN %@", [startDate,endDate])
            for r in records {
                writeCount += r.writeCount
                speakCount += r.speakCount
                correctWriteCount += r.correctWriteCount
                correctSpeakCount += r.correctSpeakCount
            }
            setTexts()
            setConfidence()
            break
        case 2:
            let startDate = Date.changeDaysBy(days: -30)
            let endDate = Date().onlyDate!
            let records = record.dailyRecords.filter("date BETWEEN %@", [startDate,endDate])
            for r in records {
                writeCount += r.writeCount
                speakCount += r.speakCount
                correctWriteCount += r.correctWriteCount
                correctSpeakCount += r.correctSpeakCount
            }
            setTexts()
            setConfidence()
            break
        default:
            break
        }
    }
    
    private func reset() {
        writeCount = 0
        speakCount = 0
        correctWriteCount = 0
        correctSpeakCount = 0
    }
    
    private func setTexts() {
        writeCountLabel.text = "Total Times Wrote: \(writeCount)"
        speakCountLabel.text = "Total Times Spoke: \(speakCount)"
        correctWriteCountLabel.text = "Times Correctly Wrote: \(correctWriteCount)"
        correctSpokeCountLabel.text = "Times Correctly Spoke: \(correctSpeakCount)"
    }
    
    private func setConfidence() {
        let write = Double(correctWriteCount) / (Double(writeCount) + Double(speakCount))
        let speak = Double(correctSpeakCount) / (Double(writeCount) + Double(speakCount))
        let confidence = (write + speak) * 100
        if (writeCount == 0 || speakCount == 0) {
            confidenceLabel.text = "Confidence: 0%"
        } else {
            confidenceLabel.text = "Confidence: \(Int(confidence.rounded(.toNearestOrAwayFromZero)))%"
        }
    }
    
}

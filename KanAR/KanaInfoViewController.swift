//
//  KanaInfoViewController.swift
//  KanAR
//
//  Created by Kin Wa Lam on 16/1/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftEntryKit
import Speech

class KanaInfoViewController: UIViewController {
    
    @IBOutlet weak var kanaLabel: UILabel!
    @IBOutlet weak var kanaDescriptionLabel: UILabel!
    @IBOutlet weak var pronounceButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var kanaData: JSON = []
    var currentIndex = 0
    
    let audioPlaybackWorker = AudioPlaybackWorker()
    let speechRecognizerWorker = SpeechRecognizerWorker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //load KanaData.json
        let path = Bundle.main.path(forResource: "KanaData", ofType: "json")
        let jsonString = try! String(contentsOfFile: path!, encoding: .utf8)
        kanaData = JSON(parseJSON: jsonString)
        //check for speech recognizer permission
        recordButton.isEnabled = false
        SFSpeechRecognizer.requestAuthorization{
            authStatus in
            var isButtonEnabled = false
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
            case .restricted:
                isButtonEnabled = false
            case .notDetermined:
                isButtonEnabled = false
            @unknown default:
                isButtonEnabled = false
            }
            OperationQueue.main.addOperation {
                self.recordButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    //MARK: Update View Text Lables
    func setInfo(key: String) {
        //get data from JSON
        var character = ""
        var description = ""
        for (index,object) in kanaData["Kana"] {
            if (object["name"].stringValue == key) {
                character = object["char"].stringValue
                description = object["desc"].stringValue
                speechRecognizerWorker.currentCharacterName = object["name"].stringValue
                if (object["name"].stringValue.contains("Katakana")) {
                    self.currentIndex = Int(index)! - 46
                } else {
                    self.currentIndex = Int(index)!
                }
            }
        }
        kanaLabel.text = character
        kanaDescriptionLabel.text = description
        view.layoutIfNeeded()
    }
    
    //MARK: Show/Hide View w/ Animation
    
    func setViewHidden(_ hide:Bool) {
        if (hide == true) {
            view.isHidden = true
        } else {
            view.isHidden = false
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.view.alpha = hide ? 0 : 1
        }, completion: nil)
    }
    
    @IBAction func playPronounciation(_ sender: UIButton) {
        audioPlaybackWorker.play(char: kanaLabel.text!)
    }
    
    @IBAction func recordButtonHold(_ sender: UIButton) {
        let char = kanaData["Kana"][currentIndex]["char"].stringValue
        speechRecognizerWorker.startSpeechRecognition(recChar: char, displayChar: kanaLabel.text!)
    }
    
    @IBAction func recordButtonRelease(_ sender: UIButton) {
        //SwiftEntryKit.dismiss()
        speechRecognizerWorker.stopSpeechRecognition()
    }
}

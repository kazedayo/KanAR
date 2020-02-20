//
//  KanaInfoViewController.swift
//  KanAR
//
//  Created by Kin Wa Lam on 16/1/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation

class KanaInfoViewController: UIViewController {
    
    @IBOutlet weak var kanaLabel: UILabel!
    @IBOutlet weak var kanaDescriptionLabel: UILabel!
    @IBOutlet weak var pronounceButton: UIButton!
    var kanaData: JSON = []
    var kyokoInstalled = false
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //load KanaData.json
        let path = Bundle.main.path(forResource: "KanaData", ofType: "json")
        let jsonString = try! String(contentsOfFile: path!, encoding: .utf8)
        kanaData = JSON(parseJSON: jsonString)
        //check if enhanced voice is installed in user's device
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if (voice.identifier == "com.apple.ttsbundle.Kyoko-premium") {
                kyokoInstalled = true
            }
        }
    }
    
    //MARK: Update View Text Lables
    func setInfo(key: String) {
        //get data from JSON
        var character = ""
        var description = ""
        for (_,object) in kanaData["Kana"] {
            if (object["name"].stringValue == key) {
                character = object["char"].stringValue
                description = object["desc"].stringValue
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
        let speechUtterance = AVSpeechUtterance(string: kanaLabel.text!)
        if (kyokoInstalled == true) {
            speechUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Kyoko-premium")
        } else {
            speechUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_ja-JP_compact")
        }
        speechUtterance.rate = AVSpeechUtteranceMinimumSpeechRate
        speechSynthesizer.speak(speechUtterance)
    }
}

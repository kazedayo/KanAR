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
import SwiftEntryKit
import Speech

class KanaInfoViewController: UIViewController {
    
    @IBOutlet weak var kanaLabel: UILabel!
    @IBOutlet weak var kanaDescriptionLabel: UILabel!
    @IBOutlet weak var pronounceButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var kanaData: JSON = []
    var kyokoInstalled = false
    
    let speechSynthesizer = AVSpeechSynthesizer()
    let speechRecognizer = SFSpeechRecognizer(locale: .init(identifier: "ja-JP"))
    let audioEngine = AVAudioEngine()
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
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
    
    @IBAction func recordButtonHold(_ sender: UIButton) {
        showPopup(title: "I'm listening...", desc: "Keep holding the button.", bgcolor: .standardBackground, fontcolor: .standardContent, duration: .infinity)
        startSpeechRecognizer()
    }
    
    @IBAction func recordButtonRelease(_ sender: UIButton) {
        //SwiftEntryKit.dismiss()
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    func startSpeechRecognizer() {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(.playAndRecord,mode: .default,options: .defaultToSpeaker)
        try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        })
        
        audioEngine.prepare()
        try! audioEngine.start()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {fatalError("Unable to create SFSpeechAudioBufferRecognitionRequest Object")}
        //recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) {
            (result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    print(result.transcriptions)
                    var matched = false
                    for transcript in result.transcriptions {
                        if (transcript.formattedString.contains(self.kanaLabel.text!)) {
                            matched = true
                        }
                    }
                    if (matched==false) {
                        self.showPopup(title: "Incorrect input!🙁", desc: "The app didn't match any input, try again!", bgcolor: .init(.systemRed), fontcolor: .white, duration: 3)
                    } else {
                        self.showPopup(title: "You are correct!🎉", desc: "You spoke the word \(self.kanaLabel.text!) correct!", bgcolor: .init(.systemGreen), fontcolor: .white, duration: 3)
                    }
                }
            }
            if error != nil {
                self.showPopup(title: "Incorrect input!🙁", desc: "The app didn't match any input, try again!", bgcolor: .init(.systemRed), fontcolor: .white, duration: 3)
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }
    
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

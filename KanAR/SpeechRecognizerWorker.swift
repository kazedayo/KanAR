//
//  SpeechRecognizerWorker.swift
//  KanAR
//
//  Created by Kin Wa Lam on 10/3/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import Foundation
import AVFoundation
import Speech

class SpeechRecognizerWorker {
    let speechRecognizer = SFSpeechRecognizer(locale: .init(identifier: "ja-JP"))
    let audioEngine = AVAudioEngine()
    
    var currentCharacterName: String = ""
    
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    func startSpeechRecognition(recChar: String, displayChar: String) {
        DispatchQueue.main.async {
            PopupWorker.sharedInstance.showPopup(title: "I'm listening...", desc: "Keep holding the button.\nRelease to end recording.", bgcolor: .standardBackground, fontcolor: .standardContent, duration: .infinity)
        }
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
        recognitionRequest.requiresOnDeviceRecognition = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) {
            (result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    print(result.transcriptions)
                    var matched = false
                    for transcript in result.transcriptions {
                        if (transcript.formattedString.contains(recChar)) {
                            matched = true
                        }
                    }
                    if (matched==false) {
                        PopupWorker.sharedInstance.showPopup(title: "Incorrect input!🙁", desc: "The app didn't match any input, try again!", bgcolor: .init(.systemRed), fontcolor: .white, duration: 3)
                        RealmDBWorker.sharedInstance.updateRecord(name: self.currentCharacterName, type: "speak", correct: false)
                    } else {
                        PopupWorker.sharedInstance.showPopup(title: "You are correct!🎉", desc: "You spoke the word \(displayChar) correct!", bgcolor: .init(.systemGreen), fontcolor: .white, duration: 3)
                        RealmDBWorker.sharedInstance.updateRecord(name: self.currentCharacterName, type: "speak", correct: true)
                    }
                }
            }
            if error != nil {
                PopupWorker.sharedInstance.showPopup(title: "Incorrect input!🙁", desc: "The app didn't match any input, try again!", bgcolor: .init(.systemRed), fontcolor: .white, duration: 3)
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }
    
    func stopSpeechRecognition() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}

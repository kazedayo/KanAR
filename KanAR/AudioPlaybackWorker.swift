//
//  AudioPlaybackWorker.swift
//  KanAR
//
//  Created by Kin Wa Lam on 10/3/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlaybackWorker {
    var kyokoInstalled = false
    let speechSynthesizer = AVSpeechSynthesizer()
    
    init() {
        //check if enhanced voice is installed in user's device
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if (voice.identifier == "com.apple.ttsbundle.Kyoko-premium") {
                kyokoInstalled = true
            }
        }
    }
    
    func play(char: String) {
        let speechUtterance = AVSpeechUtterance(string: char)
        if (kyokoInstalled == true) {
            speechUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Kyoko-premium")
        } else {
            speechUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_ja-JP_compact")
        }
        speechUtterance.rate = AVSpeechUtteranceMinimumSpeechRate
        speechSynthesizer.speak(speechUtterance)
    }
}

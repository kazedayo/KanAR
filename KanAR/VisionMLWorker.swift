//
//  VisionMLWorker.swift
//  KanAR
//
//  Created by Kin Wa Lam on 10/3/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import Foundation
import UIKit
import Vision

class VisionMLWorker {
    var currentCharacterName: String = ""
    var currentCharacter: String = ""
    var characterType: String = ""
    
    lazy var hiraganaRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: hiraganaModel3().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] r,e in
                self?.processResults(for: r, error: e)
            })
            request.imageCropAndScaleOption = .scaleFit
            return request
        } catch {
            fatalError("Failed to load Vision ML Model: \(error)")
        }
    }()
    lazy var katakanaRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: katakanaModel().model)
            let request = VNCoreMLRequest (model: model, completionHandler: { [weak self] r,e in
                self?.processResults(for: r, error: e)
            })
            request.imageCropAndScaleOption = .scaleFit
            return request
        } catch {
            fatalError("Failed to load Vision ML Model: \(error)")
        }
    }()
    
    func predictKana(image: UIImage) {
        
        guard let cgImage = image.cgImage else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                if (self.characterType == "Hiragana") {
                    try handler.perform([self.hiraganaRequest])
                } else if (self.characterType == "Katakana") {
                    try handler.perform([self.katakanaRequest])
                }
            } catch {
                print("Failed to perform Vision ML request.")
            }
        }
    }
    
    func processResults(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("unable to classify character");
                return
            }
            
            let observations = results as! [VNClassificationObservation]
            let bestObservation = observations.first!.identifier
            print(bestObservation)
            if (bestObservation == self.currentCharacter) {
                PopupWorker.sharedInstance.showPopup(title: "You are correct!🎉", desc: "You wrote the word \(self.currentCharacter) correct!", bgcolor: .init(.systemGreen), fontcolor: .white, duration: 3)
                RealmDBWorker.sharedInstance.updateRecord(name: self.currentCharacterName, type: "write",correct: true)
            } else {
                PopupWorker.sharedInstance.showPopup(title: "Incorrect input!🙁", desc: "The app thinks that you wrote \(bestObservation) , try again!", bgcolor: .init(.systemRed), fontcolor: .white, duration: 3)
                RealmDBWorker.sharedInstance.updateRecord(name: self.currentCharacterName, type: "write",correct: false)
            }
        }
    }
}

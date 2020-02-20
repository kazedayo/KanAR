//
//  CanvasViewController.swift
//  KanAR
//
//  Created by Kin Wa Lam on 19/2/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import UIKit
import PencilKit
import Vision
import SwiftEntryKit
import SwiftyJSON

class CanvasViewController: UIViewController,PKCanvasViewDelegate {

    var canvasView: PKCanvasView!
    var kanaData: JSON = []
    var currentCharacter: String = ""
    var characterType: String = ""
    var timer = Timer()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let path = Bundle.main.path(forResource: "KanaData", ofType: "json")
        let jsonString = try! String(contentsOfFile: path!, encoding: .utf8)
        kanaData = JSON(parseJSON: jsonString)
        canvasView = PKCanvasView(frame: view.bounds)
        canvasView.delegate = self
        canvasView.allowsFingerDrawing = true
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.overrideUserInterfaceStyle = .light
        view.addSubview(canvasView)
        canvasView.tool = PKInkingTool(.pencil, color: .white, width: 60)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Show/Hide View w/ Animation
    
    func setViewHidden(_ hide:Bool) {
        if (hide == true) {
            view.isHidden = true
        } else {
            view.isHidden = false
        }
        //clears drawing
        canvasView.drawing = PKDrawing()
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.view.alpha = hide ? 0 : 1
        }, completion: nil)
    }
    
    //MARK: Setter function for local variables
    func setInfo(key: String) {
        //get data from JSON
        for (_,object) in kanaData["Kana"] {
            if (object["name"].stringValue == key) {
                currentCharacter = object["char"].stringValue
                characterType = object["type"].stringValue
            }
        }
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        timer.invalidate()
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    }
    
    @objc func timerAction() {
        predictKana(drawing: canvasView.drawing)
        canvasView.drawing = PKDrawing()
    }
    
    //add black backround to user's input
    func preprocessImage() -> UIImage
    {
        var image = canvasView.drawing.image(from: canvasView.drawing.bounds, scale: 10.0)
        if let newImage = UIImage(color: .black, size: CGSize(width: 500, height: 500)){

            if let overlayedImage = newImage.image(byDrawingImage: image, inRect: CGRect(x: 125, y: 125, width: 250, height: 250)){
                image = overlayedImage
            }
        }
        
        return image
    }
    
    func predictKana(drawing: PKDrawing) {
        var image = UIImage()
        
        //fix for dark mode drawing capture
        canvasView.traitCollection.performAsCurrent {
            image = preprocessImage()
        }
        
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
                self.showPopup(success: true, character: bestObservation)
            } else {
                self.showPopup(success: false, character: bestObservation)
            }
        }
    }
    
    func showPopup(success: Bool, character: String) {
        var attributes = EKAttributes.topFloat
        var titleText = ""
        var descText = ""
        
        if (success == true) {
            titleText = "You are correct!🎉"
            descText = "You got the word \(character) correct!"
            attributes.entryBackground = .color(color: EKColor(.systemGreen))
        } else {
            titleText = "Incorrect input!🙁"
            descText = "The app thinks that you wrote \(character) , try again!"
            attributes.entryBackground = .color(color: EKColor(.systemRed))
        }
        attributes.displayDuration = 3
        attributes.screenInteraction = .forward
        attributes.roundCorners = .all(radius: 10)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))

        let title = EKProperty.LabelContent(text: titleText, style: .init(font: .preferredFont(forTextStyle: .title1), color: .white))
        let description = EKProperty.LabelContent(text: descText, style: .init(font: .preferredFont(forTextStyle: .body), color: .white))
        let simpleMessage = EKSimpleMessage(title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}

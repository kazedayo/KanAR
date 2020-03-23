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
    var timer = Timer()
    let visionMLWorker = VisionMLWorker()
    
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
                visionMLWorker.currentCharacterName = object["name"].stringValue
                visionMLWorker.currentCharacter = object["char"].stringValue
                visionMLWorker.characterType = object["type"].stringValue
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
        var image = UIImage()
        //fix for dark mode drawing capture
        canvasView.traitCollection.performAsCurrent {
            image = preprocessImage()
        }
        visionMLWorker.predictKana(image: image)
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
}

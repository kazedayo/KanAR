//
//  CanvasViewController.swift
//  KanAR
//
//  Created by Kin Wa Lam on 19/2/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import UIKit
import PencilKit

class CanvasViewController: UIViewController,PKCanvasViewDelegate {

    var canvasView: PKCanvasView!
    var currentCharacter: String = ""
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        canvasView = PKCanvasView(frame: view.bounds)
        canvasView.delegate = self
        canvasView.allowsFingerDrawing = true
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        view.addSubview(canvasView)
        canvasView.tool = PKInkingTool(.marker, color: .white, width: 20)
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
            //clears drawing
            canvasView.drawing = PKDrawing()
        } else {
            view.isHidden = false
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.view.alpha = hide ? 0 : 1
        }, completion: nil)
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        timer.invalidate()
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    }
    
    @objc func timerAction() {
        canvasView.drawing = PKDrawing()
    }
}

//
//  ViewController.swift
//  KanAR
//
//  Created by Kin Wa Lam on 15/11/2019.
//  Copyright © 2019 Kin Wa Lam. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftyJSON

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")
    
    var session: ARSession {
        return sceneView.session
    }
    
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    lazy var kanaInfoViewController: KanaInfoViewController = {
        return children.lazy.compactMap({ $0 as? KanaInfoViewController }).first!
    }()
    
    lazy var canvasViewController: CanvasViewController = {
        return children.lazy.compactMap({ $0 as? CanvasViewController }).first!
    }()
    
    var kanaData: JSON = []
    
    var currentCard = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        //Enable environment-based lighting
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
  
    var isRestartAvailable = true
    
    func resetTracking() {
        
        guard let refImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        //load KanaData.json
        let path = Bundle.main.path(forResource: "KanaData", ofType: "json")
        let jsonString = try! String(contentsOfFile: path!, encoding: .utf8)
        kanaData = JSON(parseJSON: jsonString)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = refImages
        configuration.maximumNumberOfTrackedImages = 1
        //people occluding
        if #available(iOS 13.0, *), ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            // Fallback on earlier versions
        }

        // Run the view's session
        sceneView.session.run(configuration, options: ARSession.RunOptions(arrayLiteral: .resetTracking, .removeExistingAnchors))

        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 3, messageType: .contentPlacement)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        let imageName = referenceImage.name ?? ""
        
        updateQueue.async {
            let physicalWidth = imageAnchor.referenceImage.physicalSize.width
            let physicalHeight = imageAnchor.referenceImage.physicalSize.height
            
            let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight)
            
            mainPlane.firstMaterial?.colorBufferWriteMask = .alpha
            
            let mainNode = SCNNode(geometry: mainPlane)
            mainNode.eulerAngles.x = -.pi / 2
            mainNode.renderingOrder = -1
            mainNode.opacity = 1
            
            node.addChildNode(mainNode)
            
            self.highlightDetection(on: mainNode, width: physicalWidth, height: physicalHeight, completionHandler: {
                self.displayWebView(on: mainNode, width: physicalWidth, height: physicalHeight, imageName: referenceImage.name!)
            })
            
        }
        
        DispatchQueue.main.async {
            self.setupSubviews(imageName: imageName)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        let imageName = referenceImage.name ?? ""
        
        if (currentCard != imageName) {
            DispatchQueue.main.async {
                self.setupSubviews(imageName: imageName)
            }
        }
    }
    
    func setupSubviews(imageName: String) {
        currentCard = imageName
        statusViewController.cancelAllScheduledMessages()
        statusViewController.showMessage("Detected image “\(imageName)”")
        kanaInfoViewController.setInfo(key: imageName)
        kanaInfoViewController.setViewHidden(false)
        canvasViewController.setInfo(key: imageName)
        canvasViewController.setViewHidden(false)
    }
    
    func highlightDetection(on rootNode: SCNNode, width: CGFloat, height: CGFloat, completionHandler block: @escaping (() -> Void)) {
        let planeNode = SCNNode(geometry: SCNPlane(width: width, height: height))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        planeNode.position.z += 0.1
        planeNode.opacity = 0
        
        rootNode.addChildNode(planeNode)
        planeNode.runAction(self.imageHighlightAction) {
            block()
        }
    }
    
    func displayWebView(on rootNode: SCNNode, width: CGFloat, height: CGFloat, imageName: String) {
        DispatchQueue.main.async {
            //find JSON Object correspond to the detected image
            var svgName = ""
            for (_,object) in self.kanaData["Kana"] {
                if (object["name"].stringValue == imageName) {
                    svgName = object["svg"].stringValue
                }
            }
            let pathURL = Bundle.main.url(forResource: svgName, withExtension: "svg", subdirectory: "svgsKana")
            let request = URLRequest(url: pathURL!)
            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: width * 100, height: height * 100))
            webView.delegate = self
            webView.clipsToBounds = false
            webView.scrollView.contentInset = UIEdgeInsets(top: -self.sceneView.safeAreaInsets.top, left: 0, bottom: -self.sceneView.safeAreaInsets.bottom, right: 0)
            webView.isUserInteractionEnabled = false
            webView.loadRequest(request)
                        
            let webViewPlane = SCNPlane(width: width, height: height)
            //webViewPlane.cornerRadius = 0.25
            
            let webViewNode = SCNNode(geometry: webViewPlane)
            webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
            webViewNode.position.z = 0.01
            webViewNode.opacity = 0
            
            rootNode.addChildNode(webViewNode)
            webViewNode.runAction(.fadeOpacity(to: 1.0, duration: 0.5))
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.1),
            .fadeOpacity(to: 0.15, duration: 0.1),
            .fadeOpacity(to: 0.85, duration: 0.1),
            .fadeOut(duration: 0.25),
            .removeFromParentNode()
            ])
    }
}

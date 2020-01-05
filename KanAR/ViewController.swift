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

class ViewController: UIViewController, ARSCNViewDelegate, UIWebViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")
    
    var session: ARSession {
        return sceneView.session
    }
    
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    var kanaSet = ["Mutsu":"12416","Naganami":"12394","Takao":"12383"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
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
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = refImages
        configuration.maximumNumberOfTrackedImages = 1

        // Run the view's session
        sceneView.session.run(configuration, options: ARSession.RunOptions(arrayLiteral: .resetTracking, .removeExistingAnchors))

        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 3, messageType: .contentPlacement)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        
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
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
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
        // Xcode yells at us about the deprecation of UIWebView in iOS 12.0, but there is currently
        // a bug that does now allow us to use a WKWebView as a texture for our webViewNode
        // Note that UIWebViews should only be instantiated on the main thread!
        DispatchQueue.main.async {
            let path = Bundle.main.path(forResource: self.kanaSet[imageName], ofType: "svg", inDirectory: "svgsKana")
            let pathURL = URL(fileURLWithPath: path!)
            let request = URLRequest(url: pathURL)
            print(width)
            print(height)
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
            webViewNode.runAction(.sequence([
                //.wait(duration: 3.0),
                .fadeOpacity(to: 1.0, duration: 0.5),
                //.moveBy(x: xOffset * 1.1, y: 0, z: -0.05, duration: 1),
                //.moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
                ])
            )
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let contentSize = webView.scrollView.contentSize
        let webViewSize = webView.bounds.size
        let scaleFactor = webViewSize.width / contentSize.width

        webView.scrollView.minimumZoomScale = scaleFactor
        webView.scrollView.maximumZoomScale = scaleFactor
        webView.scrollView.zoomScale = scaleFactor
    }
}

//
//  RKViewController.swift
//  ARKit-Video
//
//  Created by JING TIAN on 7/2/19.
//  Copyright © 2019 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit
import ARKit
import RealityKit
import ARVideoKit
import Photos


class RKViewController : UIViewController, ARSessionDelegate, RenderARDelegate, RecordARDelegate {
    
    var frameCount = 0
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {
        frameCount+=1
        if (frameCount % 300 == 0) {
            print("frame rendered: \(frameCount)")
        }
    }
    
    func recorder(didEndRecording path: URL, with noError: Bool) {
        
        print("end recording at: \(path), no error: \(noError)")
    }
    
    func recorder(didFailRecording error: Error?, and status: String) {
        print("recording failed, error: \(String(describing: error)), status: \(status)")
        
    }
    
    func recorder(willEnterBackground status: RecordARStatus) {
        print("recorder will enter background with status: \(status)")
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func toggleRecord(_ sender: UIButton) {
        //Record
        if recorder?.status == .readyToRecord {
            recordBtn.setTitle("Stop", for: .normal)
            recordingQueue.async {
                self.recorder?.record()
            }
        }else if recorder?.status == .recording {
            recordBtn.setTitle("Record", for: .normal)
            recorder?.stop() { path in
                self.recorder?.export(video: path) { saved, status in
                    DispatchQueue.main.sync {
                        self.exportMessage(success: saved, status: status)
                    }
                }
            }
        }
    }
    
    @IBOutlet var rkView: ARView!
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var dismissBtn: UIButton!
    
    let recordingQueue = DispatchQueue(label: "recordingThread", attributes: .concurrent)
    let caprturingQueue = DispatchQueue(label: "capturingThread", attributes: .concurrent)
    
    var recorder:RecordAR?
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("reality-kit arview instance: \(String(describing: rkView))")
        configuration.planeDetection = [.horizontal, .vertical]
        rkView.session.delegate = self
        rkView.debugOptions = [
            .showPhysics,
            //            .showStatistics,
            .showWorldOrigin,
            //            .showAnchorOrigins,
            //            .showAnchorGeometry,
            .showFeaturePoints
        ]
//        rkView.renderOptions = []
        // Initialize ARVideoKit recorder
        
        
        recorder = RecordAR(RealityKit: rkView)
        
        /*----👇---- ARVideoKit Configuration ----👇----*/
        
        // Set the recorder's delegate
        recorder?.delegate = self
        
        // Set the renderer's delegate
        recorder?.renderAR = self
        
        // Configure the renderer to perform additional image & video processing 👁
        recorder?.onlyRenderWhileRecording = false
        
        // Configure ARKit content mode. Default is .auto
        recorder?.contentMode = .aspectFill
        
        //record or photo add environment light rendering, Default is false
        recorder?.enableAdjustEnvironmentLighting = true
        
        // Set the UIViewController orientations
        recorder?.inputViewOrientations = [.landscapeLeft, .landscapeRight, .portrait]
        // Configure RecordAR to store media files in local app directory
        recorder?.deleteCacheWhenExported = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Run a body tracking configration.
        rkView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        rkView.session.pause()
        
        if recorder?.status == .recording {
            recorder?.stopAndExport()
        }
        recorder?.onlyRenderWhileRecording = true
        recorder?.prepare(configuration)
        
        // Switch off the orientation lock for UIViewControllers with AR Scenes
        recorder?.rest()
        
        super.viewWillDisappear(animated)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//        for anchor in anchors {
//            print("reality-kit anchor got: \(anchor)")
//        }
    }
    
    // MARK: - Hide Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Exported UIAlert present method
    func exportMessage(success: Bool, status:PHAuthorizationStatus) {
        if success {
            let alert = UIAlertController(title: "Exported", message: "Media exported to camera roll successfully!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Awesome", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if status == .denied || status == .restricted || status == .notDetermined {
            let errorView = UIAlertController(title: "😅", message: "Please allow access to the photo library in order to save this media file.", preferredStyle: .alert)
            let settingsBtn = UIAlertAction(title: "Open Settings", style: .cancel) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    } else {
                        UIApplication.shared.openURL(URL(string:UIApplication.openSettingsURLString)!)
                    }
                }
            }
            errorView.addAction(UIAlertAction(title: "Later", style: UIAlertAction.Style.default, handler: {
                (UIAlertAction)in
            }))
            errorView.addAction(settingsBtn)
            self.present(errorView, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Exporting Failed", message: "There was an error while exporting your media file.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

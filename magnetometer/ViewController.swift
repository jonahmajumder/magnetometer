//
//  ViewController.swift
//  magnetometer
//
//  Created by Jonah Majumder on 6/11/18.
//  Copyright © 2018 Jonah Majumder. All rights reserved.
//

import UIKit
import CoreMotion

func BG(_ block: @escaping ()->Void) {
    DispatchQueue.global(qos: .default).async(execute: block)
}

func UI(_ block: @escaping ()->Void) {
    DispatchQueue.main.async(execute: block)
}

class ViewController: UIViewController {
    @IBOutlet weak var BnetValue: UILabel!
    @IBOutlet weak var BzValue: UILabel!
    @IBOutlet weak var ByValue: UILabel!
    @IBOutlet weak var BxValue: UILabel!
    
    let motionManager = CMMotionManager()
    let refFrame : CMAttitudeReferenceFrame = CMAttitudeReferenceFrame()
    
    let Fs : Double = 10.0
    
    private func updateMagData() {
        let _:CMMagnetometerData!
        let _:Error!
        
        if motionManager.isDeviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 1.0 / Fs
            motionManager.showsDeviceMovementDisplay = true
            
            motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical, to: OperationQueue(), withHandler: {
                (motion, error) in
                
                if error != nil {
                    print("error=\(error)")
                }
                
                let BxData = motion?.magneticField.field.x ?? 0.0
                let ByData = motion?.magneticField.field.y ?? 0.0
                let BzData = motion?.magneticField.field.z ?? 0.0
                let BnetData = sqrt(BxData*BxData + ByData*ByData + BzData*BzData)
                
                let BxStr : String? = String(format: "%.3f", BxData)
                let ByStr : String? = String(format: "%.3f", ByData)
                let BzStr : String? = String(format: "%.3f", BzData)
                let BnetStr : String? = String(format: "%.3f", BnetData)
                
                UI() {
                self.BxValue.text = BxStr
                self.ByValue.text = ByStr
                self.BzValue.text = BzStr
                self.BnetValue.text = BnetStr
                }
                
            })
        }
//        motionManager.stopDeviceMotionUpdates() // does this fire immediately?
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.updateMagData()
        print("Mag data fcn returned.")
        print(String(format: "Fs set to %.2f Hz.", Fs))

    }

}


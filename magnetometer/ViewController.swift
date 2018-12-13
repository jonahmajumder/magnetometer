//
//  ViewController.swift
//  magnetometer
//
//  Created by Jonah Majumder on 6/11/18.
//  Copyright © 2018 Jonah Majumder. All rights reserved.
//

import UIKit
import CoreMotion
import Charts

func BG(_ block: @escaping ()->Void) {
    DispatchQueue.global(qos: .default).async(execute: block)
}

func UI(_ block: @escaping ()->Void) {
    DispatchQueue.main.async(execute: block)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var timePlotView: LineChartView!
    
    @IBOutlet weak var BnetValue: UILabel!
    @IBOutlet weak var BzValue: UILabel!
    @IBOutlet weak var ByValue: UILabel!
    @IBOutlet weak var BxValue: UILabel!
    
    let motionManager = CMMotionManager()
    let refFrame : CMAttitudeReferenceFrame = CMAttitudeReferenceFrame()
    
    let Fs : Double = 1.0
    
    private var BxChartEntryArray: [ChartDataEntry] = []
    private var ByChartEntryArray: [ChartDataEntry] = []
    private var BzChartEntryArray: [ChartDataEntry] = []
    private var BnetChartEntryArray: [ChartDataEntry] = []
    private var dataPts: Int = 0
    
    private func startMagUpdates() {
        let _:CMMagnetometerData!
        let _:Error!
        
        let Ts : Double = 1.0 / Fs
        var timeElapsed = Double()
        
        let BxSet : LineChartDataSet = LineChartDataSet(values: self.BxChartEntryArray, label: "Bx")
        BxSet.drawCirclesEnabled = false
        BxSet.setColor(UIColor.red)
        BxSet.axisDependency = YAxis.AxisDependency.left
        BxSet.drawValuesEnabled = false
        
        let BySet : LineChartDataSet = LineChartDataSet(values: self.ByChartEntryArray, label: "By")
        BySet.drawCirclesEnabled = false
        BySet.setColor(UIColor.green)
        BySet.axisDependency = YAxis.AxisDependency.left
        BySet.drawValuesEnabled = false
        
        let BzSet : LineChartDataSet = LineChartDataSet(values: self.BzChartEntryArray, label: "Bz")
        BzSet.drawCirclesEnabled = false
        BzSet.setColor(UIColor.yellow)
        BzSet.axisDependency = YAxis.AxisDependency.left
        BzSet.drawValuesEnabled = false
        
        let BnetSet : LineChartDataSet = LineChartDataSet(values: self.BnetChartEntryArray, label: "Bnet")
        BnetSet.drawCirclesEnabled = false
        BnetSet.setColor(UIColor.black)
        BnetSet.axisDependency = YAxis.AxisDependency.right
        BnetSet.drawValuesEnabled = false
        
        if motionManager.isDeviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = Ts
            motionManager.showsDeviceMovementDisplay = true
            
            motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical, to: OperationQueue(), withHandler: {
                (motion, error) in
                
                if error != nil {
                    print("error=\(String(describing: error))")
                }
                
                let BxData = motion?.magneticField.field.x ?? 0.0
                let ByData = motion?.magneticField.field.y ?? 0.0
                let BzData = motion?.magneticField.field.z ?? 0.0
                let BnetData = sqrt(BxData*BxData + ByData*ByData + BzData*BzData)
                
                self.dataPts += 1
                timeElapsed = Double(self.dataPts) * Ts
                
                // update data set arrays
                BxSet.addEntry(ChartDataEntry(x: timeElapsed, y: BxData))
                BySet.addEntry(ChartDataEntry(x: timeElapsed, y: ByData))
                BzSet.addEntry(ChartDataEntry(x: timeElapsed, y: BzData))
                BnetSet.addEntry(ChartDataEntry(x: timeElapsed, y: BnetData))
                
                var BdataSetArray : [LineChartDataSet] = [BxSet, BySet, BzSet, BnetSet]
                
                let BLineChartData = LineChartData(dataSets: BdataSetArray)
                
                let BxStr : String? = String(format: "%.3f uT", BxData)
                let ByStr : String? = String(format: "%.3f uT", ByData)
                let BzStr : String? = String(format: "%.3f uT", BzData)
                let BnetStr : String? = String(format: "%.3f uT", BnetData)
                
                UI() {
                self.BxValue.text = BxStr
                self.ByValue.text = ByStr
                self.BzValue.text = BzStr
                self.BnetValue.text = BnetStr
                    
                self.timePlotView.data = BLineChartData
                }
                
            })
        }
//        motionManager.stopDeviceMotionUpdates() // does this fire immediately?
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.startMagUpdates()
    }

}


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

//public func fft(x: [Double]) -> ([Double],[Double]) {
//    let N = x.count
//    let dN = Double(N)
//    var Xre: [Double] = Array(repeating:0, count:N)
//    var Xim: [Double] = Array(repeating:0, count:N)
//
//    var dk : Double = 0.0
//    var dn : Double
//    for k in 0..<N
//    {
//        Xre[k] = 0
//        Xim[k] = 0
//        let kfactor = (dk*2.0*Double.pi)/dN
//        dn = 0.0
//        for n in 0..<N {
//            let q = kfactor*dn
//            Xre[k] += x[n]*cos(q) // Real part of X[k]
//            Xim[k] -= x[n]*sin(q) // Imag part of X[k]
//            dn += 1
//        }
//        dk += 1.0
//    }
//    return (Xre, Xim)
//}

class ViewController: UIViewController {
    
    @IBOutlet weak var timePlotView: LineChartView!
    
    @IBOutlet weak var BnetValue: UILabel!
    @IBOutlet weak var BzValue: UILabel!
    @IBOutlet weak var ByValue: UILabel!
    @IBOutlet weak var BxValue: UILabel!
    
    let motionManager = CMMotionManager()
    let refFrame : CMAttitudeReferenceFrame = CMAttitudeReferenceFrame()
    
    let Fs : Double = 10.0
    
    private var BxChartEntryArray: [ChartDataEntry] = []
    private var ByChartEntryArray: [ChartDataEntry] = []
    private var BzChartEntryArray: [ChartDataEntry] = []
    private var BnetChartEntryArray: [ChartDataEntry] = []
    private var dataPts: Int = 0
    
    private var BxSet : LineChartDataSet = LineChartDataSet()
    private var BySet : LineChartDataSet = LineChartDataSet()
    private var BzSet : LineChartDataSet = LineChartDataSet()
    private var BnetSet : LineChartDataSet = LineChartDataSet()
    
    private func startMagUpdates() {
        let _:CMMagnetometerData!
        let _:Error!
        
        self.BxSet = LineChartDataSet(values: BxChartEntryArray, label: "Bx")
        BxSet.drawCirclesEnabled = false
        BxSet.setColor(UIColor.red)
        BxSet.axisDependency = YAxis.AxisDependency.left
        BxSet.drawValuesEnabled = false
        
        self.BySet = LineChartDataSet(values: self.ByChartEntryArray, label: "By")
        BySet.drawCirclesEnabled = false
        BySet.setColor(UIColor.green)
        BySet.axisDependency = YAxis.AxisDependency.left
        BySet.drawValuesEnabled = false
        
        self.BzSet = LineChartDataSet(values: self.BzChartEntryArray, label: "Bz")
        BzSet.drawCirclesEnabled = false
        BzSet.setColor(UIColor.blue)
        BzSet.axisDependency = YAxis.AxisDependency.left
        BzSet.drawValuesEnabled = false
        
        self.BnetSet = LineChartDataSet(values: self.BnetChartEntryArray, label: "Bnet")
        BnetSet.drawCirclesEnabled = false
        BnetSet.setColor(UIColor.black)
        BnetSet.axisDependency = YAxis.AxisDependency.right
        BnetSet.drawValuesEnabled = false
        
        let Ts : Double = 1.0 / Fs
        var timeElapsed = Double()
        var xAxisMin : Double = 0.0
        
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
                xAxisMin = Double.maximum(Ts, timeElapsed-10)
                
                // update data set arrays
                _ = self.BxSet.addEntry(ChartDataEntry(x: timeElapsed, y: BxData))
                _ = self.BySet.addEntry(ChartDataEntry(x: timeElapsed, y: ByData))
                _ = self.BzSet.addEntry(ChartDataEntry(x: timeElapsed, y: BzData))
                _ = self.BnetSet.addEntry(ChartDataEntry(x: timeElapsed, y: BnetData))
                
                let BdataSetArray : [LineChartDataSet] = [self.BxSet, self.BySet, self.BzSet, self.BnetSet]
                let BLineChartData = LineChartData(dataSets: BdataSetArray)
                
                print(BLineChartData)
                
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
                    self.timePlotView.xAxis.axisMinimum = xAxisMin
                    
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


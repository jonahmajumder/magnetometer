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

@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var timePlotView: LineChartView!
    @IBOutlet weak var timeContainer: DesignableView!
    @IBOutlet weak var updateContainer: DesignableView!
    
    @IBOutlet weak var freqPlotView: LineChartView!
    
    
//    @IBOutlet var swiper: UISwipeGestureRecognizer!
    
    @IBOutlet weak var leftYlabel: UILabel!
    @IBOutlet weak var rightYlabel: UILabel!
    
    @IBOutlet weak var BnetValue: UILabel!
    @IBOutlet weak var BzValue: UILabel!
    @IBOutlet weak var ByValue: UILabel!
    @IBOutlet weak var BxValue: UILabel!
    
    @objc let motionManager = CMMotionManager()
    @objc let refFrame : CMAttitudeReferenceFrame = CMAttitudeReferenceFrame()
    
    private var Fs : Double = 10.0
    
    @objc let EmptyChartEntryArray: [ChartDataEntry] = []
    private var dataPts: Int = 0
    
    private var BxSet : LineChartDataSet = LineChartDataSet()
    private var BySet : LineChartDataSet = LineChartDataSet()
    private var BzSet : LineChartDataSet = LineChartDataSet()
    private var BnetSet : LineChartDataSet = LineChartDataSet()
    
    private var BnetFFTSet : LineChartDataSet = LineChartDataSet()
    
    private var BnetDoubleArray : [Double] = []
    
    private func startMagUpdates() {
        let _:CMMagnetometerData!
        let _:Error!
        
//        self.swiper.addTarget(self, action: #selector(ViewController.swipeReset))
//        self.swiper.direction = .left
//        self.timeContainer.addGestureRecognizer(swiper)
        
        self.leftYlabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2.0)
        self.rightYlabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2.0)
        
        self.timePlotView.legend.drawInside = false
        self.timePlotView.legend.form = Legend.Form.circle
        self.timePlotView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        self.timePlotView.chartDescription?.enabled = false
        
        self.freqPlotView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        self.freqPlotView.rightAxis.enabled = false
        self.freqPlotView.leftAxis.axisMinimum = 0
        self.freqPlotView.chartDescription?.enabled = false
        
        self.BxSet = LineChartDataSet(values: EmptyChartEntryArray, label: "Bx")
        BxSet.drawCirclesEnabled = false
        BxSet.setColor(UIColor.red)
        BxSet.axisDependency = YAxis.AxisDependency.left
        BxSet.drawValuesEnabled = false
        
        self.BySet = LineChartDataSet(values: EmptyChartEntryArray, label: "By")
        BySet.drawCirclesEnabled = false
        BySet.setColor(UIColor.green)
        BySet.axisDependency = YAxis.AxisDependency.left
        BySet.drawValuesEnabled = false
        
        self.BzSet = LineChartDataSet(values: EmptyChartEntryArray, label: "Bz")
        BzSet.drawCirclesEnabled = false
        BzSet.setColor(UIColor.blue)
        BzSet.axisDependency = YAxis.AxisDependency.left
        BzSet.drawValuesEnabled = false
        
        self.BnetSet = LineChartDataSet(values: EmptyChartEntryArray, label: "Bnet")
        BnetSet.drawCirclesEnabled = false
        BnetSet.setColor(UIColor.black)
        BnetSet.axisDependency = YAxis.AxisDependency.right
        BnetSet.drawValuesEnabled = false
        
        self.BnetFFTSet = LineChartDataSet(values: EmptyChartEntryArray, label: "Bnet FFT")
        BnetFFTSet.drawCirclesEnabled = false
        BnetFFTSet.setColor(UIColor.black)
        BnetFFTSet.axisDependency = YAxis.AxisDependency.left
        BnetFFTSet.drawValuesEnabled = false
        
        let Ts : Double = 1.0 / MagConstants.DAQ.SampleFrequency
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
                
                self.BnetDoubleArray.append(BnetData)
                
                let BnetAvg : Double = self.BnetDoubleArray.reduce(0, +) / Double(self.BnetDoubleArray.count)
                
                let fftmag = Helper.fft(self.BnetDoubleArray.map{$0 - BnetAvg})
                let fftaxis = Array(0...self.dataPts).map{Double($0) * MagConstants.DAQ.SampleFrequency / Double(self.dataPts+1)}
                
//                print(fftaxis)
                
//                print(self.BnetDoubleArray.count)
//                print("---")
//                print(fftmag.count)
//                print(fftmag.count/2)
                
                timeElapsed = Double(self.dataPts) * Ts
                xAxisMin = Double.maximum(Ts, timeElapsed - (Ts * MagConstants.DAQ.MaxDataPtsOnScreen))
                
                // update data set arrays
                _ = self.BxSet.addEntry(ChartDataEntry(x: timeElapsed, y: BxData))
                _ = self.BySet.addEntry(ChartDataEntry(x: timeElapsed, y: ByData))
                _ = self.BzSet.addEntry(ChartDataEntry(x: timeElapsed, y: BzData))
                _ = self.BnetSet.addEntry(ChartDataEntry(x: timeElapsed, y: BnetData))
                
                let BdataSetArray : [LineChartDataSet] = [self.BxSet, self.BySet, self.BzSet, self.BnetSet]
                let BLineChartData = LineChartData(dataSets: BdataSetArray)
                
                self.BnetFFTSet.values = self.EmptyChartEntryArray
                for i in 0..<fftmag.count/2+1 {
                    _ = self.BnetFFTSet.addEntry(ChartDataEntry(x: fftaxis[i], y: fftmag[i]))
                }
                
                let BnetFFTData = LineChartData(dataSet: self.BnetFFTSet)
                
                let BxStr : String? = String(format: "%.3f uT", BxData)
                let ByStr : String? = String(format: "%.3f uT", ByData)
                let BzStr : String? = String(format: "%.3f uT", BzData)
                let BnetStr : String? = String(format: "%.3f uT", BnetData)
                
                self.dataPts += 1
                                
                UI() {
                    self.BxValue.text = BxStr
                    self.ByValue.text = ByStr
                    self.BzValue.text = BzStr
                    self.BnetValue.text = BnetStr
                    
                    self.timePlotView.data = BLineChartData
                    self.timePlotView.xAxis.axisMinimum = xAxisMin
                    
                    self.freqPlotView.data = BnetFFTData
                    
                }
                
            })
        }
//        motionManager.stopDeviceMotionUpdates() // does this fire immediately?
        
    }
    
//    @objc func swipeReset() {
//        self.resetData()
//    }
    
    private func resetData() {
        print("got reset signal")
        self.BxSet.values = EmptyChartEntryArray
        self.BySet.values = EmptyChartEntryArray
        self.BzSet.values = EmptyChartEntryArray
        self.BnetSet.values = EmptyChartEntryArray
        
        self.dataPts = 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.startMagUpdates()
    }

}


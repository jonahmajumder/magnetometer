//
//  MagConstants.swift
//  
//
//  Created by Jonah Majumder on 4/14/19.
//

import Foundation

struct MagConstants {
    
    struct DAQ {
        static let SampleFrequency : Double = 10
        static let MaxDataPtsOnScreen : Double = 100
        static let MaxDataPtsRemembered : Double = 1000
    }
    
    struct StringConstants {
        
//        let strAttrs = [NSAttributedStringKey.baselineOffset : -10.0] as [NSAttributedStringKey : Any]
    }
    
}

struct Helper {
    static func fft(_ x: [Double]) -> [Double] {
        let N = x.count
        let dN = Double(N)
        //    var Xre: [Double] = Array(repeating:0, count:N)
        //    var Xim: [Double] = Array(repeating:0, count:N)
        var Xmag: [Double] = Array(repeating:0, count:N)
        
        var Xre : Double
        var Xim : Double
        
        var dk : Double = 0.0
        var dn : Double
        for k in 0..<N
        {
            Xre = 0
            Xim = 0
            let kfactor = (dk*2.0*Double.pi)/dN
            dn = 0.0
            for n in 0..<N {
                let q = kfactor*dn
                Xre += x[n]*cos(q) // Real part of X[k]
                Xim -= x[n]*sin(q) // Imag part of X[k]
                dn += 1.0
            }
            Xmag[k] = sqrt(Xre*Xre + Xim*Xim) / dN
            dk += 1.0
        }
        return Xmag
    }
    
    static func autoLimit(_ argin : Double) -> (Double, Double) {
        
        if (argin) <= 0 {
            return (1.0, 1.0)
        }
        
        let logfloor = pow(10, floor(log10(argin)))
        let argin110 = Double( argin / logfloor )
        
        let testvals = [2.0, 5.0, 10.0]
        let chosenval = testvals.filter{ argin110 < $0 }.min() ?? -1
        
        let limit = chosenval * logfloor
        
        let limitIncr = limit / 5
        
        return (limit, limitIncr)
        
    }
    
    
}

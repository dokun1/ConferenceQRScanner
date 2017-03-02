//
//  QRScanner.swift
//  IBMQRScanner
//
//  Created by David Okun IBM on 3/1/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import Foundation

let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow])

public enum ScannerError : Error {
    case CouldNotProcess
    case DuplicateBadge
    case MoreThanOneFeature
    case ParsingIssue
}

class Scanner {
    class func scan(_ image: UIImage) throws -> Record {
        guard let ciimg: CIImage = CIImage(image: image) else {
            throw ScannerError.CouldNotProcess
        }
        guard let features = qrDetector?.features(in: ciimg) else {
            throw ScannerError.CouldNotProcess
        }
        if features.count > 1 {
            throw ScannerError.MoreThanOneFeature
        }
        guard let feature = features.first else {
            throw ScannerError.CouldNotProcess
        }
        guard let record = extractRecord(feature as! CIQRCodeFeature) else {
            throw ScannerError.ParsingIssue
        }
        if record.isUnique == false {
            throw ScannerError.DuplicateBadge
        }
        return record
    }
    
    fileprivate class func extractRecord(_ feature: CIQRCodeFeature) -> Record? {
        guard let string = feature.messageString else {
            return nil
        }
        let components = string.components(separatedBy: "\r")
        if components.count == 0 {
            return nil
        }
        guard let name = extractValue(components[1]), let email = extractValue(components[2]) else {
            return nil
        }
        let record = Record()
        record.name = name
        record.email = email
        return record
    }
    
    fileprivate class func extractValue(_ string: String) -> String? {
        let components = string.components(separatedBy: ":")
        if components.count != 2 {
            return nil
        }
        guard let email = components.last else {
            return nil
        }
        return email
    }
}

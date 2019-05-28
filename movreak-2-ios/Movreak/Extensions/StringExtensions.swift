//
//  StringExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 9/23/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import Foundation
import Security

extension String {
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func date(withFormat format: String? = nil) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = .autoupdatingCurrent
        
        if let format = format {
            dateFormatter.dateFormat = format
            
            if let date = dateFormatter.date(from: self) {
                return date
            }
        }
        else {
            
            for dateFormat in kDateFormats {
                dateFormatter.dateFormat = dateFormat
                if let date = dateFormatter.date(from: self) {
                    return date
                }
            }
        }
        
        return nil
    }
    
    var md5: String {
        
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = self.data(using: String.Encoding.utf8) {
            CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    var stringByDecodingHTMLEntities: String {
        
        if let encodedData = self.data(using: String.Encoding.utf8) {
            let attributedOptions: [String: Any] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
            ]
            
            do {
                let attributedString =
                    try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
                
                let decodedString = attributedString.string
                return decodedString
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return self
    }
    
    var isPhoneNumber: Bool {
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            if let match = matches.first {
                return match.resultType == .phoneNumber
                    && match.range.location == 0
                    && match.range.length == characters.count
            }
            else {
                return false
            }
        }
        catch {
            return false
        }
    }
    
    var isLink: Bool {
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            if let match = matches.first {
                return match.resultType == .link
                    && match.range.location == 0
                    && match.range.length == characters.count
            }
            else {
                return false
            }
        }
        catch {
            return false
        }
    }
    
    var isEmail: Bool {
        
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count)) != nil
        }
        catch {
            return false
        }
    }
    
    var isValidReviewText: Bool {
        
        do {
            let regex = try NSRegularExpression(pattern: "[a-zA-Z0-9_.'\"!\\?]{3,} [a-zA-Z0-9_.'\"!\\?]{3,} .+", options: .caseInsensitive)
            
            return regex.firstMatch(in: self, options: .reportCompletion, range: NSMakeRange(0, characters.count)) != nil
        }
        catch {
            return false
        }
    }
}

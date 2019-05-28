//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, (playground)"

extension String {
    
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

print("\n".isValidReviewText)



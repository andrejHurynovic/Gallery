//
//  UIColor+initHexadecimalColorCode.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 04.03.2025.
//

import UIKit

extension UIColor {
    public convenience init?(hexadecimalColorCode code: String) {
        let red, green, blue, alpha: CGFloat

        guard code.hasPrefix("#") else { return nil }
        let start = code.index(code.startIndex, offsetBy: 1)
        let numberText = String(code[start...])
        guard numberText.count == 6 || numberText.count == 8 else { return nil }
        
        var number = UInt64()
        let scanner = Scanner(string: numberText)
        guard scanner.scanHexInt64(&number) else { return nil }
        
        switch numberText.count {
        case 6:
            red = CGFloat((number & 0xFF0000) >> 16) / 255
            green = CGFloat((number & 0x00FF00) >> 8) / 255
            blue = CGFloat(number & 0x0000FF) / 255
            alpha = 1.0
        case 8:
            red = CGFloat((number & 0xFF000000) >> 24) / 255
            green = CGFloat((number & 0x00FF0000) >> 16) / 255
            blue = CGFloat((number & 0x0000FF00) >> 8) / 255
            alpha = CGFloat(number & 0x000000FF) / 255
        default:
            return nil
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

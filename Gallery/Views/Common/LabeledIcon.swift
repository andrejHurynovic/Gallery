//
//  LabeledIcon.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

final class LabeledIcon: UILabel {
    private let iconText: NSAttributedString
    private let placeholderText: String
    
    override var text: String? {
        didSet { updateAttributedText() }
    }
    
    // MARK: - Initialization
    
    init(icon: UIImage,
         font: UIFont = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 14)),
         color: UIColor = .secondaryLabel,
         placeholderText: String = "-") {
        
        self.iconText = Self.createIconText(icon: icon, font: font, color: color)
        self.placeholderText = placeholderText
        super.init(frame: .zero)
        
        setupLabel(font: font, color: color)
        updateAttributedText()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Private
    
    private func setupLabel(font: UIFont, color: UIColor) {
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
        self.font = font
        textColor = color
        textAlignment = .center
    }
    
    private func updateAttributedText() {
        let mutableIconText = NSMutableAttributedString(attributedString: iconText)
        let textToAppend = text ?? placeholderText
        mutableIconText.append(NSAttributedString(string: " " + textToAppend))
        self.attributedText = mutableIconText
    }
    
    private static func createIconText(icon: UIImage, font: UIFont, color: UIColor) -> NSAttributedString {
        let iconSize = Constants.UserInterface.largeIconSize
        let attachment = NSTextAttachment(image: icon.withTintColor(color))
        attachment.bounds = CGRect(x: 0, y: (font.capHeight - iconSize) / 2, width: iconSize, height: iconSize)
        return NSAttributedString(attachment: attachment)
    }
}

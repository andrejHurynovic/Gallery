//
//  PersistentPost.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 08.03.2025.
//

import CoreData
import UIKit

@objc(PersistentPost)
final class PersistentPost: NSManagedObject, Identifiable {
    @NSManaged public var id: String
    @NSManaged var dateOfInsertion: Date
    
    var isPersistent: Bool { return true }
    
    @NSManaged var width: Int32
    @NSManaged var height: Int32
    @NSManaged var hexadecimalColorCode: String
    
    @NSManaged var publicationDate: Date
    @NSManaged var descriptionText: String?
    @NSManaged var alternativeDescriptionText: String?
    
    @NSManaged private var backingViews: Int32
    @NSManaged var likes: Int32
    @NSManaged private var backingDownloads: Int32
    
    @NSManaged var imageURL: String
    @NSManaged var downloadURL: String
    
    @NSManaged private var backingImage: Data?
}

// MARK: - Accessors
// It's impossible to use KeyPath here to retrieve keys. NSExpression(forKeyPath: keyPath).keyPath produces a fatal error "Could not extract a String from KeyPath \PersistentPost.views" for Int32? because it is not available in the Objective-C environment... Sadly...
extension PersistentPost {
    var views: Int32? {
        get {
            willAccessValue(forKey: "backingViews")
            defer { didAccessValue(forKey: "backingViews") }
            return optional(from: backingViews)
        }
        set {
            willAccessValue(forKey: "backingViews")
            backingViews = unwrappedOptional(from: newValue)
            didAccessValue(forKey: "backingViews")
        }
    }
    var downloads: Int32? {
        get {
            willAccessValue(forKey: "backingDownloads")
            defer { didAccessValue(forKey: "backingDownloads") }
            return optional(from: backingDownloads)
        }
        set {
            willAccessValue(forKey: "backingDownloads")
            backingDownloads = unwrappedOptional(from: newValue)
            didAccessValue(forKey: "backingDownloads")
        }
    }
    var imageBox: (any ImageBoxProtocol)? {
        get {
            guard let backingImage else { return nil }
            return ImageBox(from: backingImage)
        }
        set {
            backingImage = (newValue?.image as? UIImage)?.pngData()
        }
    }
}

private extension PersistentPost {
    static let optionalInt32Value: Int32 = -1
    
    func optional(from number: Int32) -> Int32? {
        guard number != Self.optionalInt32Value else { return nil }
        return number
    }
    func unwrappedOptional(from number: Int32?) -> Int32 {
        if let number { return number } else { return Self.optionalInt32Value }
    }
}

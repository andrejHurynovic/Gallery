//
//  ServiceLocating.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 01.03.2025.
//

protocol ServiceLocating {
    func register<T>(_ closure: @escaping @autoclosure () -> (T))
    func resolve<T>() -> T?
    func removeInstance<T>(of type: T)
}

//
//  Injected.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 02.03.2025.
//

@propertyWrapper
struct Injected<T> {
    let wrappedValue: T? = ServiceLocator.shared.resolve()
}

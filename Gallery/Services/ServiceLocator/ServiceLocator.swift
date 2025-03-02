//
//  ServiceLocator.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 01.03.2025.
//

final class ServiceLocator: ServiceLocating {
    private var instances: [String: Any] = [:]
    private var formulas: [String: () -> Any] = [:]
    
    private init() { }
    
    static private(set) var shared: any ServiceLocating = ServiceLocator()
    
    func resolve<T>() -> T? {
        let identifier = String(describing: T.self)
        if let instance = instances[identifier] as? T { return instance }
        guard let formula = formulas[identifier] else { return nil }
        let instance = formula()
        instances[identifier] = instance
        return instance as? T
        
    }
    func register<T>(_ closure: @escaping @autoclosure () -> (T)) {
        let identifier = String(describing: T.self)
        formulas[identifier] = closure
    }
    
    func removeInstance<T>(of type: T) {
        let identifier = String(describing: T.self)
        instances.removeValue(forKey: identifier)
    }
}

//
//  UserDefaultsExtension.swift
//  NiuNiuRent
//
//  Created by 张泉 on 2023/4/19.
//

import Foundation

// MARK: - KeyNamespaceable

public protocol KeyNamespaceable {
    static func namespaced<T: RawRepresentable>(_ key: T) -> String
}

extension KeyNamespaceable {
    static func namespaced<T: RawRepresentable>(_ key: T) -> String {
        return "\(Self.self).\(key.rawValue)"
    }
}

// MARK: - DataDefaultSettable

public protocol DataDefaultSettable: KeyNamespaceable {
    associatedtype DataKey: RawRepresentable
}

extension DataDefaultSettable where DataKey.RawValue == String {

    static func set(_ data: Data?, forKey key: DataKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func data(forKey key: DataKey) -> Data? {
        let key = namespaced(key)
        return UserDefaults.standard.data(forKey: key)
    }
    
    static func encodedData<T: Codable>(_ data: T, forKey key: DataKey) {
        do {
            let data = try JSONEncoder().encode(data)
            self.set(data, forKey: key)
        } catch {
        }
    }
    
    static func decodedData<T: Codable>(forKey key: DataKey) -> T? {
        guard let data = Self.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }

}

// MARK: - StringDefaultSettable

public protocol StringDefaultSettable: KeyNamespaceable {
    associatedtype StringKey: RawRepresentable
}

extension StringDefaultSettable where StringKey.RawValue == String {

    static func set(_ string: String?, forKey key: StringKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(string, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func string(forKey key: StringKey) -> String? {
        let key = namespaced(key)
        return UserDefaults.standard.string(forKey: key)
    }
}

// MARK: - URLDefaultSettable

public protocol URLDefaultSettable: KeyNamespaceable {
    associatedtype URLKey: RawRepresentable
}

extension URLDefaultSettable where URLKey.RawValue == String {

    static func set(_ url: URL?, forKey key: URLKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(url, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func url(forKey key: URLKey) -> URL? {
        let key = namespaced(key)
        return UserDefaults.standard.url(forKey: key)
    }
}

// MARK: - IntArrayDefaultSettable

public protocol IntArrayDefaultSettable: KeyNamespaceable {
    associatedtype IntArrayKey: RawRepresentable
}

extension IntArrayDefaultSettable where IntArrayKey.RawValue == String {

    static func set(_ intArray: [Int]?, forKey key: IntArrayKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(intArray, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func intArray(forKey key: IntArrayKey) -> [Int]? {
        let key = namespaced(key)

        guard let array = UserDefaults.standard.array(forKey: key) else {
            return nil
        }

        guard let intArray = array as? [Int] else {
            return nil
        }

        return intArray
    }
}

// MARK: - StringArrayDefaultSettable

public protocol StringArrayDefaultSettable: KeyNamespaceable {
    associatedtype StringArrayKey: RawRepresentable
}

extension StringArrayDefaultSettable where StringArrayKey.RawValue == String {

    static func set(_ stringArray: [String]?, forKey key: StringArrayKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(stringArray, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func stringArray(forKey key: StringArrayKey) -> [String]? {
        let key = namespaced(key)

        guard let array = UserDefaults.standard.array(forKey: key) else {
            return nil
        }

        guard let stringArray = array as? [String] else {
            return nil
        }

        return stringArray
    }
}

// MARK: - ArrayDefaultSettable

public protocol ArrayDefaultSettable: ObjectDefaultSettable {
    associatedtype ArrayKey: RawRepresentable
}

extension ArrayDefaultSettable where ArrayKey.RawValue == String {

    static func set(_ array: [Any]?, forKey key: ArrayKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(array, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func array(forKey key: ArrayKey) -> [Any]? {
        let key = namespaced(key)
        return UserDefaults.standard.array(forKey: key)
    }
}

// MARK: - ObjectDefaultSettable

public protocol ObjectDefaultSettable: KeyNamespaceable {
    associatedtype ObjectKey: RawRepresentable
}

extension ObjectDefaultSettable where ObjectKey.RawValue == String {

    static func set(_ object: Any?, forKey key: ObjectKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func object(forKey key: ObjectKey) -> Any? {
        let key = namespaced(key)
        return UserDefaults.standard.object(forKey: key)
    }
}

// MARK: - BoolDefaultSettable

public protocol BoolDefaultSettable: KeyNamespaceable {
    associatedtype BoolKey: RawRepresentable
}

extension BoolDefaultSettable where BoolKey.RawValue == String {

    static func set(_ bool: Bool, forKey key: BoolKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(bool, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func bool(forKey key: BoolKey) -> Bool {
        let key = namespaced(key)
        return UserDefaults.standard.bool(forKey: key)
    }
}

// MARK: - IntegerDefaultSettable

public protocol IntegerDefaultSettable: KeyNamespaceable {
    associatedtype IntegerKey: RawRepresentable
}

extension IntegerDefaultSettable where IntegerKey.RawValue == String {

    static func set(_ integer: Int, forKey key: IntegerKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(integer, forKey: key)
    }

    static func integer(forKey key: IntegerKey) -> Int {
        let key = namespaced(key)
        return UserDefaults.standard.integer(forKey: key)
    }
}

// MARK: - DoubleDefaultSettable

public protocol DoubleDefaultSettable: KeyNamespaceable {
    associatedtype DoubleKey: RawRepresentable
}

extension DoubleDefaultSettable where DoubleKey.RawValue == String {

    static func set(_ double: Double, forKey key: DoubleKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(double, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func double(forKey key: DoubleKey) -> Double {
        let key = namespaced(key)
        return UserDefaults.standard.double(forKey: key)
    }
}

// MARK: - FloatDefaultSettable

public protocol FloatDefaultSettable: KeyNamespaceable {
    associatedtype FloatKey: RawRepresentable
}

extension FloatDefaultSettable where FloatKey.RawValue == String {

    static func set(_ float: Float, forKey key: FloatKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(float, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func float(forKey key: FloatKey) -> Float {
        let key = namespaced(key)
        return UserDefaults.standard.float(forKey: key)
    }
}

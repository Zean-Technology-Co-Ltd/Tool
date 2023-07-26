//
//  JSONRepresentable.swift
//  NiuNiuRent
//
//  Created by Q Z on 2023/4/28.
//

import Foundation

protocol JSONRepresentable {
    var JSONRepresentation: AnyObject { get }
}

protocol JSONSerializable: JSONRepresentable {

}

extension JSONSerializable {

    var JSONRepresentation: AnyObject {
        var representation = [String: AnyObject]()

        for case let (label?, value) in Mirror(reflecting: self).children {
            switch value {
            case let value as JSONRepresentable:
                representation[label] = value.JSONRepresentation

            case let value as NSObject:
                representation[label] = value

            default:
                // Ignore any unserializable properties
                break
            }
        }
        return representation as AnyObject
    }
}

extension JSONSerializable {

    func toJSON() -> String? {
        let representation = JSONRepresentation

        guard JSONSerialization.isValidJSONObject(representation) else {
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: representation, options: [])
            return String(data: data, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }

    func toJSONData() -> Data? {
        let representation = JSONRepresentation

        guard JSONSerialization.isValidJSONObject(representation) else {
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: representation, options: [])
            return data
        } catch {
            return nil
        }
    }
}

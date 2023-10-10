//
//  Message.swift
//  Flow Work
//
//  Created by Allen Lin on 10/10/23.
//

import Foundation

struct Message {
    var topic: String
    var event: String
    var payload: [String: Any]
    var ref: String
    
    func toDictionary() -> [String: Any] {
        return ["topic": topic, "event": event, "payload": payload, "ref": ref]
    }
}

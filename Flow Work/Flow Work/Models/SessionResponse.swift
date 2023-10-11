//
//  SessionResponse.swift
//  Flow Work
//
//  Created by Allen Lin on 10/11/23.
//

import Foundation

struct SessionResponse: Decodable {
    var ref: String
    var payload: ResponsePayload
    var topic: String
    var event: String
}

struct ResponsePayload: Decodable {
    var status: String
    var response: Response
}

struct Response: Decodable {
    var createTime: String
    var fields: ResponseFields
    var name: String
    var updateTime: String?
}

struct ResponseFields: Decodable {
    var description: StringValue?
    var joinCode: StringValue?
    var name: StringValue
    var users: ArrayValue
}

struct StringValue: Decodable {
    let stringValue: String
}

struct ArrayValue: Decodable {
    let arrayValue: ArrayValueObject
}

struct ArrayValueObject: Decodable {
    let values: [StringValue]
}

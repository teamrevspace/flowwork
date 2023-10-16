//
//  Response.swift
//  Flow Work
//
//  Created by Allen Lin on 10/11/23.
//

import Foundation

struct LobbyResponse: Decodable {
    var ref: String?
    var payload: LobbyResponsePayload
    var topic: String
    var event: String
}

struct LobbyResponsePayload: Decodable {
    var userIds: [String]
}

struct ErrorResponse: Decodable {
    var ref: String?
    var payload: ErrorResponsePayload
    var topic: String
    var event: String
}

struct ErrorResponsePayload: Decodable {
    var status: String
    var response: String
}

struct SessionResponse: Decodable {
    var ref: String?
    var payload: SessionResponsePayload
    var topic: String
    var event: String
}

struct SessionResponsePayload: Decodable {
    var status: String
    var response: SessionResponseBody
}

struct SessionResponseBody: Decodable {
    var createTime: String
    var fields: SessionResponseFields
    var name: String
    var updateTime: String?
}

struct SessionResponseFields: Decodable {
    var description: StringValue?
    var password: StringValue?
    var name: StringValue
    var userIds: ArrayValue
}

struct SocketResponse: Decodable {
    var ref: String?
    var payload: SocketResponsePayload
    var topic: String
    var event: String
}

struct SocketResponsePayload: Decodable {
    var status: String
    var response: [String: String]?
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

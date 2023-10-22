//
//  APIServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/22/23.
//

protocol APIServiceProtocol {
    func getUserCounts(sessionIds: String, completion: @escaping (Result<[String: Int], Error>) -> Void)
}

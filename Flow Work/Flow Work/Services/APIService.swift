//
//  APIService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/22/23.
//

import Foundation
import Combine
import Swinject

class APIService: APIServiceProtocol, ObservableObject {
    private let resolver: Resolver
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func getUserCounts(sessionIds: String, completion: @escaping (Result<[String: Int], Error>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.flowwork.xyz"
        urlComponents.path = "/api/user_counts"
        urlComponents.queryItems = [URLQueryItem(name: "session_ids", value: sessionIds)]
        
        guard let url = urlComponents.url else {
            completion(.failure(APIError.urlError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { response -> Data in
                guard let httpResponse = response.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw APIError.serverError
                }
                return response.data
            }
            .decode(type: [String: Int].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { phase in
                switch phase {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    break
                }
            }, receiveValue: { userCountsResponse in
                completion(.success(userCountsResponse))
            })
            .store(in: &cancellables)
    }
    
}

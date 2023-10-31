//
//  StorageServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/30/23.
//

import Foundation

protocol StorageServiceProtocol {
    func uploadProfilePicture(imageData: Data, completion: @escaping (URL) -> Void)
}

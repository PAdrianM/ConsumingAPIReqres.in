//
//  UserListResponse.swift
//  practiceConsumeAPI
//
//  Created by Andrea Hernandez on 1/24/24.
//

import Foundation

struct UserListResponse: Decodable {
    let page: Int
    let per_page: Int
    let total: Int
    let total_pages: Int
    let data: [User]
    let support: Support

    struct Support: Decodable {
        let url: String
        let text: String
    }
}

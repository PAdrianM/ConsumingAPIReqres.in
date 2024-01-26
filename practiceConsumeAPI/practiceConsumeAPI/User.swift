//
//  User.swift
//  practiceConsumeAPI
//
//  Created by Andrea Hernandez on 1/24/24.
//

import Foundation


struct User: Codable {
    
    let id: Int
    let email: String
    let first_name: String
    let last_name: String
    let avatar: String
    
}

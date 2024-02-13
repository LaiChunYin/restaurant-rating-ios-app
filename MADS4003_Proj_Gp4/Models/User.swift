//
//  User.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import Foundation

class User {
    let username: String
    let password: String
    let favRestaurants: [Restaurant] = []
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    
    func addToFavRestaurant() {
        
    }
    
    func removeFavRestaurant() {
        
    }
}

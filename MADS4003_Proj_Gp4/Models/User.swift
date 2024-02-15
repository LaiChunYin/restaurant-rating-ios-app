//
//  User.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import Foundation

class User: ObservableObject {
    let username: String
    let password: String
    var rememberMe: Bool
    var favRestaurants: [Restaurant] = []
    var restaurantRatings: [String: Int] = [:]
    
    // for signing up
    init(username: String, password: String, rememberMe: Bool) {
        self.username = username
        self.password = password
        self.rememberMe = rememberMe
    }
    
    init(username: String, data: [String: Any]){
        self.username = username
        self.password = data["password"] as! String
        self.rememberMe = data["remember_me"] as! Bool
        self.favRestaurants = data["fav_restaurants"] as? [Restaurant] ?? []
        self.restaurantRatings = data["ratings"] as? [String: Int] ?? [:]
    }
    
    
    
    // for preview testing
    init() {
        self.username = "tester"
        self.password = "12345678"
        self.rememberMe = false
    }
}

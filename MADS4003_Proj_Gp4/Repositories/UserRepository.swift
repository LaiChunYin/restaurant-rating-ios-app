//
//  UserRepository.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 16/2/2024.
//

import Foundation


class UserRepository {
    private var users: [String: [String: Any]] = [:]  // structure [username: [password: Int, remember_me: Bool, fav_restaurant_ids: [restaurant ids], restaurant_rating: [restaurantid: rating]]]
    private var currentUser: [String: [String: Any]]? = nil
    private var user_ratings: [String: [String: Int]] = [:]  // structure [username: [restaurant id: rating]]
    private let restaurantRepository: RestaurantRepository
    
    init(restaurantRepository: RestaurantRepository) {
        self.restaurantRepository = restaurantRepository
        self.user_ratings = self.getUserRatings()
        self.users = self.getAllUsers()
    }
    
    func getCurrentUser() -> User? {
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULT_VAL.CURRENT_USER.rawValue) {
            var currentUserDict = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] ?? [:]
            
            let username = currentUserDict.keys.first!
            var userData = currentUserDict[username]!
            currentUser = [username: userData]
            
            userData[USER_KEY.FAV.rawValue] = restaurantRepository.getFavRestaurantsByIds(ids: userData[USER_KEY.FAV_IDS.rawValue] as! [String])

            return User(username: username, data: userData)
        }
        return nil
    }
    
    private func getAllUsers() -> [String: [String: Any]] {
        
        
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULT_VAL.USERS.rawValue) {
            users = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] ?? [:]
            
            for username in users.keys {
                if let data = users[username],
                   let password = data[USER_KEY.PWD.rawValue] as? String,
                   let rememberMe = data[USER_KEY.REMEMBER_ME.rawValue] as? Bool,
                   let fav_list = data[USER_KEY.FAV_IDS.rawValue] as? [String],
                   let restaurantRating = data[USER_KEY.RATINGS.rawValue] as? [String: Int]
                {
                    users[username] = [USER_KEY.PWD.rawValue: password, USER_KEY.REMEMBER_ME.rawValue: rememberMe, USER_KEY.FAV_IDS.rawValue: fav_list, USER_KEY.RATINGS.rawValue: restaurantRating]
                }
            }
            print("get user defaults users \(users)")
        }
        return users
    }
    
    private func getUserRatings() -> [String: [String: Int]] {
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULT_VAL.USER_RATINGS.rawValue) {
            user_ratings = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Int]] ?? [:]
            print("get user defaults user ratings \(user_ratings)")
        }
        return user_ratings
    }
    
    
    func addUser(user: User) {
        let newUserData: [String: Any] = [USER_KEY.PWD.rawValue: user.password, USER_KEY.FAV_IDS.rawValue: [], USER_KEY.REMEMBER_ME.rawValue: false, USER_KEY.RATINGS.rawValue: [:]]
        users[user.username] = newUserData
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_VAL.USERS.rawValue)
            print("saved users")
        }
    }
    
    func getUserByUsername(username: String) -> User? {
        // get user's fav list
        if var userData = users[username] {
            userData[CURRENT_USER_KEY.FAV.rawValue] = restaurantRepository.getFavRestaurantsByIds(ids: userData[CURRENT_USER_KEY.FAV_IDS.rawValue] as! [String])
            print("user data is \(userData)")
            
            return User(username: username, data: userData)
        }
        return nil
        
    }
    
    func getAllUserNames() -> [String] {
        return Array(users.keys)
    }
    
    
    func saveCurrentUser(user: User) {
        if let data = try? JSONSerialization.data(withJSONObject: [user.username: users[user.username]!], options: []) {
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_VAL.CURRENT_USER.rawValue)
            print("saved current user")
        }
    }
    
    func removeCurrentUser() {
        UserDefaults.standard.set(nil, forKey: USER_DEFAULT_VAL.CURRENT_USER.rawValue)
    }
    
    func addFavRestaurantToUser(username: String, restaurant: Restaurant) {
        if var user = users[username],
           var restaurantIds = user[USER_KEY.FAV.rawValue] as? [String]
        {
            restaurantIds.append(restaurant.id)
            user[USER_KEY.FAV.rawValue] = restaurantIds
            users[username] = user
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_VAL.USERS.rawValue)
        }
    }
    
    func removeFavRestaurantsFromUser(user: User, restaurants: [Restaurant]) {
        let restaurantIds = user.favRestaurants.map {$0.id}
        let restaurantIdsToBeDeleted = restaurants.map {$0.id}
        
        var userData = users[user.username]!
        userData[USER_KEY.FAV.rawValue] = restaurantIds.filter({ !restaurantIdsToBeDeleted.contains($0) })
        users[user.username] = userData
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_VAL.USERS.rawValue)
        }
    }
    
    func addUserRatings(user: User, restaurant: Restaurant, rating: Int) {
        var userData = users[user.username]!
        var ratings: [String: Int] = userData[USER_KEY.RATINGS.rawValue] as! [String: Int]
        ratings[restaurant.id] = rating
        userData[USER_KEY.RATINGS.rawValue] = ratings
        users[user.username]! = userData
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_VAL.USERS.rawValue)
            print("saved users")
        }
    }
}

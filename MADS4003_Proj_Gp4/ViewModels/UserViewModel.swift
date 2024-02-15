//
//  UserViewModel.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import Foundation


class UserViewModel: ObservableObject {
    private var users: [String: [String: Any]] = [:]  // structure [username: [password: Int, remember_me: Bool, fav_restaurant_ids: [restaurant ids], restaurant_rating: [restaurantid: rating]]]
    private var all_fav: [String: [String: Any]] = [:] // structure [restaurant id: [name: String, location: String, category: String]]
    private var comments_and_ratings: [String: [String: Any]] = [:]  // structure [restaurant ids: [number of raters: Int, total rating: Int, comment_and_commenter: [commenter: comment]]]
    private var user_ratings: [String: [String: Int]] = [:]  // structure [username: [restaurant id: rating]]
    @Published var currentUser: User? = nil
    @Published var favList: [Restaurant] = []
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "FAV") {
            all_fav = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] ?? [:]
        }
        
        if let data = UserDefaults.standard.data(forKey: "CURRENT_USER") {
            var currentUserDict = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] ?? [:]
            
            let username = currentUserDict.keys.first!
            var userData = currentUserDict[username]!
            
            userData["fav_restaurants"] = getFavRestaurants(ids: userData["fav_restaurant_ids"] as! [String])

            currentUser = User(username: username, data: userData)
        }
        
        if let data = UserDefaults.standard.data(forKey: "USERS") {
            users = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] ?? [:]
            
            for username in users.keys {
                if let data = users[username],
                   let password = data["password"] as? String,
                   let rememberMe = data["remember_me"] as? Bool,
                   let fav_list = data["fav_restaurant_ids"] as? [String],
                   let restaurantRating = data["ratings"] as? [String: Int]
                {
                    users[username] = ["password": password, "remember_me": rememberMe, "fav_restaurant_ids": fav_list, "ratings": restaurantRating]
                }
            }
            print("get user defaults users \(users)")
        }
        
        if let data = UserDefaults.standard.data(forKey: "COMMENTS_AND_RATINGS") {
            comments_and_ratings = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] ?? [:]
            
            for id in comments_and_ratings.keys {
                if let data = comments_and_ratings[id],
                   let numOfRaters = data["number_of_raters"] as? Int,
                   let totalRating = data["total_rating"] as? Int,
                   let comments = data["comments"] as? [String: String]
                {
                    comments_and_ratings[id] = ["number_of_raters": numOfRaters, "total_rating": totalRating, "comments": comments]
                }
            }
            print("get user defaults comments and ratings \(comments_and_ratings)")
        }
        
        if let data = UserDefaults.standard.data(forKey: "USER_RATINGS") {
            user_ratings = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Int]] ?? [:]
            print("get user defaults comments and ratings \(comments_and_ratings)")
        }

    }
    
    func signUp(username: String, password: String, confirmPassword: String) -> Result {
        guard !username.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            print("empty value")
            return .error(type: IdentifiableError(error: SignUpError.emptyInputs))
        }
        guard password == confirmPassword else {
            print("password not match")
            return .error(type: IdentifiableError(error: SignUpError.confirmPwdNotMatch))
        }

        guard !users.keys.contains(username) else {
            print("user already exist")
            return .error(type: IdentifiableError(error: SignUpError.alreadyExist))
        }
        guard password.count >= 8 else {
            return .error(type: IdentifiableError(error: SignUpError.weakPassword))
        }
        
        print("\(#function), \(username), \(password)")
        let newUserData: [String: Any] = ["password": password, "fav_restaurant_ids": [], "remember_me": false, "ratings": [:]]
        users[username] = newUserData
        
        // login directly after signing up
        currentUser = User(username: username, data: newUserData)
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            UserDefaults.standard.set(data, forKey: "USERS")
            print("saved users")
        }
        return .success
    }
    
    func login(username: String, password: String, rememberMe: Bool) -> Result {
        guard !username.isEmpty && !password.isEmpty else {
            print("empty username or password")
            return .error(type: IdentifiableError(error: LoginError.emptyUsernameOrPwd))
        }
        guard users.keys.contains(username) else {
            print("invalid user")
            return .error(type: IdentifiableError(error: LoginError.invalidUser))
        }
        guard password == users[username]!["password"] as? String else {
            print("wrong password")
            return .error(type: IdentifiableError(error: LoginError.wrongPwd))
        }
        
        print("\(#function), \(username), \(password)")
        
        // get user's fav list
        var favRestaurants: [Restaurant] = []
        var userData = users[username]
        
        for id in users[username]!["fav_restaurant_ids"] as! [String] {
            favRestaurants.append(Restaurant(id: id, data: all_fav[id]!))
        }
        userData!["fav_restaurants"] = getFavRestaurants(ids: userData!["fav_restaurant_ids"] as! [String])
        print("user data is \(userData)")
        
        currentUser = User(username: username, data: userData!)
        print("\(#function), current user is \(self.currentUser?.username)")
        
        if rememberMe {
            print("remember me, no need to login next time")
            
            if let data = try? JSONSerialization.data(withJSONObject: [username: users[username]!], options: []) {
                UserDefaults.standard.set(data, forKey: "CURRENT_USER")
                print("saved current user")
            }
        }
        
        return .success
    }
    
    func logout() -> Result {
        currentUser = nil
        UserDefaults.standard.set(nil, forKey: "CURRENT_USER")
        return .success
    }
    
    func addToFav(restaurant: Restaurant) {
        print("users before adding \(currentUser!.username), \(users)")
        guard !currentUser!.favRestaurants.map({$0.id}).contains(restaurant.id) else {
            print("restaurant already added")
            return
        }
        
        if var user = users[currentUser!.username],
           var restaurantIds = user["fav_restaurant_ids"] as? [String]
        {
            restaurantIds.append(restaurant.id)
            user["fav_restaurant_ids"] = restaurantIds
            users[currentUser!.username] = user
        }
        
        var data: [String: Any] = ["name": restaurant.name, "location": restaurant.location, "category": restaurant.category]
        if restaurant
            .iconUrl != nil {
            data["iconUrl"] = restaurant.iconUrl!.absoluteString
        }
        all_fav[restaurant.id] = data
        
        // notify change on the fav list page
        var newFavList = currentUser!.favRestaurants
        newFavList.append(restaurant)
        currentUser!.favRestaurants = newFavList
        currentUser = currentUser
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            UserDefaults.standard.set(data, forKey: "USERS")
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: all_fav, options: []) {
            UserDefaults.standard.set(data, forKey: "FAV")
        }
    }
        
    
    func removeFromFav(restaurants: [Restaurant]) {
    
        if var user = users[currentUser!.username],
           var restaurantIds = user["fav_restaurant_ids"] as? [String]
        {
            let restaurantIdsToBeDeleted = restaurants.map { $0.id }
            user["fav_restaurant_ids"] = restaurantIds.filter({ !restaurantIdsToBeDeleted.contains($0) })
            users[currentUser!.username] = user
            
            // notify change on the fav list page
            var newFavList = currentUser!.favRestaurants
            newFavList = newFavList.filter { !restaurantIdsToBeDeleted.contains($0.id)}
            currentUser!.favRestaurants = newFavList
            currentUser = currentUser
        }
        
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            UserDefaults.standard.set(data, forKey: "USERS")
        }
    }
    
    
    func getFavRestaurants(ids: [String]) -> [Restaurant] {
        return ids.compactMap {
            guard all_fav.keys.contains($0) else {
                return nil
            }
            return Restaurant(id: $0, data: all_fav[$0]!)
        }
    }
    
    func rate(restaurant: Restaurant, rating: Int, currentUser: User?) {
        if currentUser!.restaurantRatings.keys.contains(restaurant.id) {
            currentUser!.restaurantRatings[restaurant.id] = rating
        }
        else {
            currentUser!.restaurantRatings[restaurant.id] = rating
        }
        
        var userData = users[currentUser!.username]!
        var ratings: [String: Int] = userData["ratings"] as! [String: Int]
        ratings[restaurant.id] = rating
        userData["ratings"] = ratings
        users[currentUser!.username]! = userData
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            UserDefaults.standard.set(data, forKey: "USERS")
            print("saved users")
        }
    }
    
    
//    // for preview testing
//    init() {
//        self.currentUser = User()
//        self.favList = [Restaurant()]
//    }
}

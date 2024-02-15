//
//  UserViewModel.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import Foundation


class UserViewModel: ObservableObject {
//    private var userPasswords: [String : String] = UserDefaults.standard.dictionary(forKey: "USER_PWD") as? [String : String] ?? [:]

//    private var users = UserDefaults.standard.dictionary(forKey: "USERS") as? [String: [String: Any]] ?? [:]
//    private var all_fav = UserDefaults.standard.dictionary(forKey: "FAV") as? [String: [String: Any]] ?? [:]
    private var users: [String: [String: Any]] = [:]  // structure [username: [password: Int, remember_me: Bool, fav_restaurant_ids: [restaurant ids], restaurant_rating: [restaurantid: rating]]]
    private var all_fav: [String: [String: Any]] = [:] // structure [restaurant id: [name: String, location: String, category: String]]
    private var comments_and_ratings: [String: [String: Any]] = [:]  // structure [restaurant ids: [number of raters: Int, total rating: Int, comment_and_commenter: [commenter: comment]]]
    private var user_ratings: [String: [String: Int]] = [:]  // structure [username: [restaurant id: rating]]
    @Published var currentUser: User? = nil
    @Published var favList: [Restaurant] = []
    
    init() {
        print("init user view model")
        if let data = UserDefaults.standard.data(forKey: "FAV") {
            all_fav = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] ?? [:]
            print("get user defaults all_fav \(all_fav)")
            
        }
        
        if let data = UserDefaults.standard.data(forKey: "CURRENT_USER") {
            var currentUserDict = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] ?? [:]
            print("current user dict is \(currentUserDict)")
            
            let username = currentUserDict.keys.first!
//            var favRestaurants: [Restaurant] = []
            var userData = currentUserDict[username]!
            
//            for id in currentUserDict[username]!["fav_restaurant_ids"] as! [String] {
//                favRestaurants.append(Restaurant(id: id, data: all_fav[id]!))
//            }
//            userData["fav_restaurants"] = favRestaurants
            userData["fav_restaurants"] = getFavRestaurants(ids: userData["fav_restaurant_ids"] as! [String])
            print("user data is \(userData)")
//            currentUserDict[username] = userData
            
//            currentUser = User(username: username, data: currentUserDict[username]!)
            currentUser = User(username: username, data: userData)
            print("get user defaults current users \(currentUser?.username)")
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
            
//            for username in user_ratings.keys {
//                if let data = user_ratings[username]
//                {
//                    user_ratings[username] = ["password": password, "remember_me": rememberMe, "fav_restaurant_ids": fav_list, "restaurant_ratings": restaurantRatings]
//                }
//            }
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
//        guard !userPasswords.keys.contains(username) else {
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
//        UserDefaults.standard.set(users, forKey: "USERS")
        
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
//        userData!["fav_restaurants"] = favRestaurants
        userData!["fav_restaurants"] = getFavRestaurants(ids: userData!["fav_restaurant_ids"] as! [String])
        print("user data is \(userData)")
//        users[username] = userData
        
        
        currentUser = User(username: username, data: userData!)
//        currentUser = User(username: username, data: users[username]!)
        print("\(#function), current user is \(self.currentUser?.username)")
        
        if rememberMe {
            print("remember me, no need to login next time")
            
            if let data = try? JSONSerialization.data(withJSONObject: [username: users[username]!], options: []) {
                UserDefaults.standard.set(data, forKey: "CURRENT_USER")
                print("saved current user")
            }
//            UserDefaults.standard.set([username, users[username]!], forKey: "CURRENT_USER")
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
            print("restaurantIds is \(restaurantIds)")
            restaurantIds.append(restaurant.id)
            user["fav_restaurant_ids"] = restaurantIds
            users[currentUser!.username] = user
        }
        print("users after adding \(users)")
        
        print("all_fav before adding \(all_fav)")
//        all_fav[restaurant.id] = ["name": restaurant.name, "location": restaurant.location, "category": restaurant.category, "iconUrl": restaurant.iconUrl as Any]
        var data: [String: Any] = ["name": restaurant.name, "location": restaurant.location, "category": restaurant.category]
        if restaurant
            .iconUrl != nil {
            data["iconUrl"] = restaurant.iconUrl!.absoluteString
        }
        all_fav[restaurant.id] = data
        print("all_fav after adding \(all_fav)")
        
        // notify change on the fav list page
        var newFavList = currentUser!.favRestaurants
        newFavList.append(restaurant)
        currentUser!.favRestaurants = newFavList
        currentUser = currentUser

        
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            print("saving users")
            UserDefaults.standard.set(data, forKey: "USERS")
            print("in add saved users")
        }
        print("done with users")
        if let data = try? JSONSerialization.data(withJSONObject: all_fav, options: []) {
            print("saving fav")
            UserDefaults.standard.set(data, forKey: "FAV")
            print("in add saved fav")
        }
        
//        UserDefaults.standard.set(users, forKey: "USERS")
//        UserDefaults.standard.set(all_fav, forKey: "FAV")
    }
        
    
    func removeFromFav(restaurants: [Restaurant]) {
        print("users before removing \(users)")
    
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
        
//        var userData = users[currentUser!.username]
//        userData.removeValue(forKey: "fav_restaurants")  // objects cannot be encoded
        print("users after removing \(users)")
        
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            UserDefaults.standard.set(data, forKey: "USERS")
            print("in remove saved users")
        }
//        UserDefaults.standard.set(users, forKey: "USERS")
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
            print("rerating")
//            restaurant.totalRatings -= currentUser!.restaurantRatings[restaurant.id]!
//            restaurant.totalRatings += rating
            currentUser!.restaurantRatings[restaurant.id] = rating
        }
        else {
            print("new rating")
//            restaurant.numOfRaters += 1
//            restaurant.totalRatings += rating
            currentUser!.restaurantRatings[restaurant.id] = rating
        }
        
        
//        print("before comments and ratings \(comments_and_ratings)")
////        var commentAndRating = comments_and_ratings[restaurant.id]!
////        commentAndRating["number_of_raters"] = restaurant.numOfRaters
////        commentAndRating["total_rating"] = restaurant.totalRatings
//        comments_and_ratings[restaurant.id] = ["number_of_raters": restaurant.numOfRaters, "total_rating": restaurant.totalRatings, "comments": restaurant.comments]
//        print("after comments and ratings \(comments_and_ratings)")
//        
//
//        if let data = try? JSONSerialization.data(withJSONObject: comments_and_ratings, options: []) {
//            UserDefaults.standard.set(data, forKey: "COMMENTS_AND_RATINGS")
//            print("saved comments and ratings")
//        }
        

        
        print("before updating users rating \(users)")
        var userData = users[currentUser!.username]!
        var ratings: [String: Int] = userData["ratings"] as! [String: Int]
        ratings[restaurant.id] = rating
        userData["ratings"] = ratings
        users[currentUser!.username]! = userData
        print("after updating users rating \(users)")
        
        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
            UserDefaults.standard.set(data, forKey: "USERS")
            print("saved users")
        }
    }
    
    func comment(restaurant: Restaurant, comment: String) {
        
    }
    
    
//    // for preview testing
//    init() {
//        self.currentUser = User()
//        self.favList = [Restaurant()]
//    }
}

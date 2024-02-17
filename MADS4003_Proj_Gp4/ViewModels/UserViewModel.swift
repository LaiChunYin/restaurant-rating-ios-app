//
//  UserViewModel.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import Foundation


class UserViewModel: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var favList: [Restaurant] = []
    private let restaurantRepository: RestaurantRepository
    private let userRepository: UserRepository
    
    init() {
        self.restaurantRepository = RestaurantRepository()
        self.userRepository = UserRepository(restaurantRepository: restaurantRepository)
        currentUser = userRepository.getCurrentUser()
    }
    
    func signUp(username: String, password: String, confirmPassword: String) -> Result<Void, SignUpError> {
        guard !username.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            print("empty value")
            return .failure(SignUpError.emptyInputs)
        }
        guard password == confirmPassword else {
            print("password not match")
            return .failure(SignUpError.confirmPwdNotMatch)
        }

        guard !userRepository.getAllUserNames().contains(username) else {
            print("user already exist")
            return .failure(SignUpError.alreadyExist)
        }
        guard password.count >= 8 else {
            return .failure(SignUpError.weakPassword)
        }
        
        print("\(#function), \(username), \(password)")
        
        // login directly after signing up
        currentUser = User(username: username, password: password, rememberMe: false)

        userRepository.addUser(user: currentUser!)
        return .success(())
    }
    
    func login(username: String, password: String, rememberMe: Bool) -> Result<Void, LoginError> {
        guard !username.isEmpty && !password.isEmpty else {
            print("empty username or password")
            return .failure(LoginError.emptyUsernameOrPwd)
        }
        guard userRepository.getAllUserNames().contains(username) else {
            print("invalid user")
            return .failure(LoginError.invalidUser)
        }
        
        currentUser = userRepository.getUserByUsername(username: username)
        
        guard password == currentUser!.password else {
            print("wrong password")
            return .failure(LoginError.wrongPwd)
        }
        
        print("\(#function), \(username), \(password)")
        
        print("\(#function), current user is \(self.currentUser?.username)")
        
        if rememberMe {
            print("remember me, no need to login next time")
            userRepository.saveCurrentUser(user: currentUser!)
        }
        
        return .success(())
    }
    
    func logout() -> Result<Void, Error> {
        currentUser = nil
        userRepository.removeCurrentUser()
        return .success(())
    }
    
    func addToFav(restaurant: Restaurant) {
        print("users before adding \(currentUser!.username)")
        guard !currentUser!.favRestaurants.map({$0.id}).contains(restaurant.id) else {
            print("restaurant already added")
            return
        }
        
        // notify change on the fav list page
        var newFavList = currentUser!.favRestaurants
        newFavList.append(restaurant)
        self.objectWillChange.send()
        currentUser!.favRestaurants = newFavList
        
        userRepository.addFavRestaurantToUser(username: currentUser!.username, restaurant: restaurant)
        restaurantRepository.addAllFavRestaurants(restaurant: restaurant)
    }
        
    
    func removeFromFav(restaurants: [Restaurant]) {
    
        if var user = currentUser {
            let restaurantIdsToBeDeleted = restaurants.map { $0.id }
            userRepository.removeFavRestaurantsFromUser(user: user, restaurants: restaurants)
            
            // notify change on the fav list page
            var newFavList = currentUser!.favRestaurants
            newFavList = newFavList.filter { !restaurantIdsToBeDeleted.contains($0.id)}
            self.objectWillChange.send()
            currentUser!.favRestaurants = newFavList
        }
        

    }
    
    
    func rate(restaurant: Restaurant, rating: Int, currentUser: User?) {
        if currentUser!.restaurantRatings.keys.contains(restaurant.id) {
            currentUser!.restaurantRatings[restaurant.id] = rating
        }
        else {
            currentUser!.restaurantRatings[restaurant.id] = rating
        }
                
        userRepository.addUserRatings(user: currentUser!, restaurant: restaurant, rating: rating)
    }
    

}

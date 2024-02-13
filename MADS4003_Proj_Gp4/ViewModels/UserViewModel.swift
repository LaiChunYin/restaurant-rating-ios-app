//
//  UserViewModel.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import Foundation


class UserViewModel: ObservableObject {
    
    func signUp(username: String, password: String, confirmPassword: String) -> Result {
        guard !username.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            return .error(type: IdentifiableError(error: SignUpError.emptyInputs))
        }
        
        print("\(#function), \(username), \(password)")
        return .success
    }
    
    func login(username: String, password: String) -> Result {
        guard !username.isEmpty && !password.isEmpty else {
            return .error(type: IdentifiableError(error: LoginError.emptyUsernameOrPwd))
        }
        
        print("\(#function), \(username), \(password)")
        return .success
    }

    func save() {
        
    }
    
    func logout(){
        
    }
    
    func addToFav() {
        
    }
    
    func removeFromFav() {
        
    }
    
    func share() {
        
    }
    
    func getFavRestaurants() {
        
    }
}

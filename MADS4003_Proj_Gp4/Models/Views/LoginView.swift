//
//  LoginView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var viewSelection: Int? = nil
    @ObservedObject private var userViewModel = UserViewModel()
    @State private var loginError: IdentifiableError? = nil
    

    var body: some View {
        
        NavigationStack {
            NavigationLink(destination: RestaurantListView(), tag: 1, selection: $viewSelection){}
            NavigationLink(destination: SignupView(), tag: 2, selection: $viewSelection){}
            
            
            Text("User name:")
            TextField("Enter your user name", text: $username)
            
            Text("Password:")
            TextField("Enter your password", text: $password)
            
            Button {
                print("login clicked")
                
                let loginResult: Result = userViewModel.login(username: username, password: password)
                
                switch loginResult {
                    case Result.success:
                        viewSelection = 1
                    case Result.error(let error):
                        print("login failed")
                        loginError = error
                }
            } label: {
                Text("Login")
            }
            .alert(item: $loginError) { error in
                let errorType: LoginError = error.error as! LoginError
                let errMsg: String
                switch errorType {
                 case .emptyUsernameOrPwd:
                     errMsg = "Please enter both username and password."
                 case .invalidUser, .wrongPwd:
                     errMsg = "Invalid username or password."
//                 default:
//                     errMsg = "An unknown error occurred."
                 }
                return Alert(title: Text("Error"), message: Text(errMsg))
            }

            Button {
                print("signup clicked")
                viewSelection = 2
            } label: {
                Text("Sign up")
            }
            
        }
        .navigationTitle("Restaurant Rating App")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

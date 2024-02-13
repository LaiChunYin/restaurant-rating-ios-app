//
//  SignupView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import SwiftUI

struct SignupView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var viewSelection: Int? = nil
    @ObservedObject private var userViewModel = UserViewModel()
    @State private var signUpError: IdentifiableError? = nil
    
    var body: some View {
        NavigationStack {
            NavigationLink(destination: RestaurantListView(), tag: 1, selection: $viewSelection){}
            
            
            Text("User name:")
            TextField("Enter your user name", text: $username)
            
            Text("Password:")
            TextField("Enter your password", text: $password)
            
            Text("Confirm Password:")
            TextField("Confirm your password", text: $confirmPassword)
            

            Button {
                print("login clicked")
                
                let signUpResult: Result = userViewModel.signUp(username: username, password: password, confirmPassword: confirmPassword)
                
                switch signUpResult {
                    case Result.success:
                        viewSelection = 1
                    case Result.error(let error):
                        print("login failed")
                        signUpError = error
                }
            } label: {
                Text("Create Account")
            }
            .alert(item: $signUpError) { error in
                let errorType: SignUpError = error.error as! SignUpError
                let errMsg: String
                switch errorType {
                    case .alreadyExist:
                        errMsg = "The username is already used."
                    case .weakPassword:
                        errMsg = "Password is too weak."
                    case .confirmPwdNotMatch:
                        errMsg = "Password does not match with the confirm password."
                    case .emptyInputs:
                        errMsg = "All Input fields are mandatory."
                 }
                return Alert(title: Text("Error"), message: Text(errMsg))
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}


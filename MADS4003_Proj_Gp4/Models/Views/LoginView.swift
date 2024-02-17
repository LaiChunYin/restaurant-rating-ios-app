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
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var loginError: LoginError? = nil
    @State private var rememberMe: Bool = false
    

    var body: some View {
        
        GeometryReader{ geo in
            
            NavigationStack {
                
                NavigationLink(destination: RestaurantListView(), tag: 1, selection: $viewSelection){}
                NavigationLink(destination: SignupView(), tag: 2, selection: $viewSelection){}
                
                ZStack{
                    
                    Image(.imageLogin2).resizable()
                                       .aspectRatio(contentMode: .fill)
                                       .frame(width: geo.size.width, height: geo.size.height)
                                       .edgesIgnoringSafeArea(.all)
                                       .opacity(1)
                                       .blur(radius: 1)
                                       .clipShape(.rect(cornerRadius: 15))
                    
                    LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom)
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .opacity(0.8)
                    
                    VStack(alignment: .center){
                        Text("User Name")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        
                        TextField("Enter your user name", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding()
                        
                        Text("Password")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding()
                            .padding(.bottom, 20)
                        
                        HStack {
                            Button{
                                rememberMe.toggle()
                            } label: {
                                Image(systemName: rememberMe ? "checkmark.square" : "square")
                                    .foregroundColor(rememberMe ? .blue : .gray)
                                    .font(.system(size: 20))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text("Remember Me")
                        }
                        
                        HStack {
                            Button {
                                let loginResult = userViewModel.login(username: username, password: password, rememberMe: rememberMe)
                                
                                switch loginResult {
                                case .success:
                                    viewSelection = 1
                                case .failure(let error):
                                    print("login failed")
                                    loginError = error
                                }
                            } label: {
                                Text("Login")
                                    .foregroundStyle(.white)
                                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    .fontWeight(.semibold)
                            }
                            .tint(.green)
                            .buttonStyle(.borderedProminent)
                            .alert(item: $loginError){ error in
                                let errMsg: String
                                switch error {
                                case .emptyUsernameOrPwd:
                                    errMsg = "Please enter both username and password."
                                case .invalidUser, .wrongPwd:
                                    errMsg = "Invalid username or password."
                                }
                                return Alert(title: Text("Error"), message: Text(errMsg))
                            }
                            
                            Spacer()
                            
                            Button {
                                print("signup clicked")
                                viewSelection = 2
                            } label: {
                                Text("Sign up")
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            }
                            .tint(.indigo)
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .background(.ultraThinMaterial.opacity(1))
                    .clipShape(.rect(cornerRadius: 15))
                    .frame(width: geo.size.width/1.2)
                }
                .navigationTitle("Restaurant App")
                .tint(.orange)
                .ignoresSafeArea()
            }
        }
        .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        .edgesIgnoringSafeArea(.all)

    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(UserViewModel())
    }
}

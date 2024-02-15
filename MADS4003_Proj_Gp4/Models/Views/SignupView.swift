import SwiftUI

struct SignupView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var signUpError: IdentifiableError? = nil
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("imageLogin2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(1)
                    .blur(radius: 1)
                    .clipShape(RoundedRectangle(cornerRadius: 15))


                LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom)
                    .opacity(0.8)
                    VStack(alignment: .center, spacing: 10) {
                        Text("User Name")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        TextField("Enter your user name", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding()
                        
                        Text("Password")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding()
                        
                        Text("Confirm Password")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        SecureField("Confirm your password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding()
                        
                        Button(action: {
                            let signUpResult: Result = userViewModel.signUp(username: username, password: password, confirmPassword: confirmPassword)
                            
                            switch signUpResult {
                            case Result.success:
                                print("sign up success")
                            case Result.error(let error):
                                print("sign up failed")
                                signUpError = error
                            }
                        }) {
                            Text("Create Account")
                                .foregroundColor(.white)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(10)
                                .background(Color.green)
                                .cornerRadius(10)
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
                                errMsg = "All input fields are mandatory."
                            }
                            return Alert(title: Text("Error"), message: Text(errMsg))
                        }
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .background(.ultraThinMaterial.opacity(1))
                    .clipShape(.rect(cornerRadius: 15))
                .frame(width: geo.size.width/1.2)
                .padding(.trailing, geo.size.width/5)
                    
                
            }
            
        }
        .preferredColorScheme(.dark)
        .edgesIgnoringSafeArea(.all)
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView().environmentObject(UserViewModel())
    }
}

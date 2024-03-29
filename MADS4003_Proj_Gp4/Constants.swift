//
//  Errors.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import Foundation

enum LoginError: Error, Identifiable {
    var id: Self {self}
    
    case emptyUsernameOrPwd
    case invalidUser
    case wrongPwd
}

enum SignUpError: Error,Identifiable {
    var id: Self {self}
    
    case alreadyExist
    case weakPassword
    case confirmPwdNotMatch
    case emptyInputs
}

let weekDays: [Int: String] = [0: "Monday", 1: "Tuesday", 2: "Wednesday", 3: "Thursday", 4: "Friday", 5: "Saturday", 6: "Sunday"]

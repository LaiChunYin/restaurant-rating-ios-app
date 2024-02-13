//
//  Errors.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import Foundation

struct IdentifiableError: Identifiable {
    let id = UUID()
    let error: any AppError
}

enum Result {
    case success
    case error(type: IdentifiableError)
}

protocol AppError: Error {}

enum LoginError: AppError {
    case emptyUsernameOrPwd
    case invalidUser
    case wrongPwd
}

enum SignUpError: AppError {
    case alreadyExist
    case weakPassword
    case confirmPwdNotMatch
    case emptyInputs
}

//enum WeekDay: String {
//    case mon = "Monday", tue = "Tuesday", wed = "Wednesday", thu = "Thursday", fri = "Friday", sat = "Saturday", sun = "Sunday"
//}

let weekDays: [Int: String] = [0: "Monday", 1: "Tuesday", 2: "Wednesday", 3: "Thursday", 4: "Friday", 5: "Saturday", 6: "Sunday"]

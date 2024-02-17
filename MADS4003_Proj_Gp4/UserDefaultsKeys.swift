//
//  UserDefaultsKeys.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 14/2/2024.
//

import Foundation


enum USER_DEFAULT_VAL: String {
    case CURRENT_USER = "CURRENT_USER"
    case USERS = "USERS"
    case ALL_FAV_RESTAURANT = "FAV"
    case COMMENTS_AND_RATINGS = "COMMENTS_AND_RATINGS"
    case USER_RATINGS = "USER_RATINGS"
}

enum CURRENT_USER_KEY: String {
    case PWD = "password"
    case REMEMBER_ME = "remember_me"
    case FAV_IDS = "fav_restaurant_ids"
    case FAV = "fav_restaurants"
    case RES_RATING = "ratings"
}

enum USER_KEY: String {
    case FAV_IDS = "fav_restaurant_ids"
    case FAV = "fav_restaurants"
    case PWD = "password"
    case REMEMBER_ME = "remember_me"
    case RATINGS = "ratings"
}

enum ALL_FAV_RESTAURANT_KEY: String {
    case NAME = "name"
    case LOCATION = "location"
    case CATEGORY = "category"
    case ICON = "iconUrl"
}

enum COMMENTS_AND_RATINGS_KEY: String {
    case NUM_OF_RATERS = "number_of_raters"
    case TOTAL_RATING = "total_rating"
    case COMMENTS = "comments"
}


//
//  RestaurantModel.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class RestaurantViewModel: ObservableObject {
    private let API_KEY = "te5I4gQj31fvEDkqW41F6SDGf2Y8kbM1ezn26t-E_nKaasKhUxsAbLgJbQC0ylC21reOOznUWGjGWxQTazLhqA62aURluhO0XhDkQulRxkGfLoHY08aG-nspvErJZXYx"
    @Published var restaurants : [Restaurant] = []
//    @Published var restaurant: Restaurant? = nil  // current restaurant shown on the detail page
    private var comments_and_ratings: [String: [String: Any]] = [:]  // structure [restaurant ids: [number of raters: Int, total rating: Int, comment_and_commenter: [commenter: comment]]]
        
    init(){
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
        
        getRestaurants()
    }
    
    func getRestaurants(){
        let apiURL = "https://api.yelp.com/v3/businesses/search?term=restaurants&location=Toronto"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(API_KEY)",
                                   "Content-Type": "application/json"]
        
        AF.request(apiURL, headers: headers).responseJSON{ response in
            print("response is \(response)")
            switch response.result {
            case .success(let responseData):
                let json = JSON(responseData)
                
                self.restaurants = json["businesses"].arrayValue.map{ restaurantJSON in
                    print("restaurant json is \(restaurantJSON)")
                    
                    let id: String = restaurantJSON["id"].stringValue
                    print("1")
                    let name: String = restaurantJSON["name"].stringValue
                    print("2")
                    let location: String = restaurantJSON["location"]["display_address"].arrayValue.reduce("", {$0 + $1.stringValue})
                    print("3")
                    let iconUrl: URL? = restaurantJSON["image_url"].url
                    print("4")
                    let cateogory: String = restaurantJSON["categories"].arrayValue.first!.dictionaryValue["title"]!.stringValue
                    
                    print("json parsed \(id), \(name), \(location), \(iconUrl), \(cateogory)")
                    
                    return Restaurant(id: id,
                                      name: name,
                                      location: location,
                                      iconUrl: iconUrl,
                                      category: cateogory)
                }
                
                print(#function, "restaurants - \(self.restaurants)")
                
            case .failure(let error):
                print(#function, "Unsuccessful response from server : \(error)")
            }
        }
    }
    
    func searchRestaurants(for searchTerm: String) -> [Restaurant]{
        if searchTerm.isEmpty{
            return restaurants
        }else{
            return restaurants.filter{ restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }
    
    
    func getRestaurantDetails(restaurant: Restaurant) {
//    func getRestaurantDetails() {
        print("restauring to be found is \(restaurant.id)")
        let apiURL = "https://api.yelp.com/v3/businesses/\(restaurant.id)"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(API_KEY)","Content-Type": "application/json"]
        
        AF.request(apiURL, headers: headers).responseJSON{ response in
            print("response is \(response)")
            switch response.result {
            case .success(let responseData):
                let restaurantJSON = JSON(responseData)
                
//                self.restaurants = json["businesses"].arrayValue.map{ restaurantJSON in
                    print("restaurant detail json is \(restaurantJSON)")
                    
//                    let id: String = restaurantJSON["id"].stringValue
                    print("1")
                    let name: String = restaurantJSON["name"].stringValue
                    print("2")
                    let location: String = restaurantJSON["location"]["display_address"].arrayValue.reduce("", {$0 + $1.stringValue})
                    print("3")
                    let restaurantUrl = try? restaurantJSON["url"].stringValue.asURL()
                    let iconUrl: URL? = restaurantJSON["image_url"].url
                    print("4")
                    let cateogory: String = restaurantJSON["categories"].arrayValue.first!.dictionaryValue["title"]!.stringValue
                    print("5")
                    let photoUrls: [URL] = restaurantJSON["photos"].arrayValue.map {$0.url!}
                    print("6")
                let hours = restaurantJSON["hours"].arrayValue.first?.dictionaryValue["open"]!.arrayValue.map {$0.dictionaryValue} ?? []
                    print("7")
                    let price: String = restaurantJSON["price"].stringValue
                
                    print("json parsed \(name), \(location), \(iconUrl), \(cateogory), \(photoUrls), \(hours), \(price)")
                    
//                    var openingHours: [String: String] = [:]
                    var openingHours: [Int: String] = [:]
                
                    for hour in hours {
//                        let weekDay = weekDays[hour["day"]!.intValue]!
//                        print("weekday is \(hour), \(weekDay)")
                        print("weekday is \(hour)")
                        openingHours[hour["day"]!.intValue] = "\(hour["start"] ?? "0000") - \(hour["end"] ?? "2400")"
                    }
                
//                    restaurant.objectWillChange.send()
                
                    restaurant.name = name
                    restaurant.location = location
                    restaurant.restaurantUrl = restaurantUrl
                    restaurant.iconUrl = iconUrl
                    restaurant.photoUrls = photoUrls
                    restaurant.category = cateogory
                    restaurant.openingHours = openingHours
                    restaurant.price = price
                
                    if let commentAndRating = self.comments_and_ratings[restaurant.id] {
                        print("getting comment and rating \(commentAndRating)")
                        restaurant.numOfRaters = commentAndRating["number_of_raters"] as! Int
                        restaurant.totalRatings = commentAndRating["total_rating"] as! Int
                        restaurant.comments = commentAndRating["comments"] as! [String : String]
                    }
                    
                    self.restaurants = self.restaurants
                
                
                print(#function, "restaurants - \(restaurant.openingHours), \(restaurant.photoUrls), \(restaurant.price)")
                
                case .failure(let error):
                    print(#function, "Unsuccessful response from server : \(error)")
            }
            
        }
    }
    
    func rate(restaurant: Restaurant, rating: Int, currentUser: User?) {
        if currentUser!.restaurantRatings.keys.contains(restaurant.id) {
            print("before rerating \(restaurant.totalRatings), \(rating), \(currentUser!.restaurantRatings[restaurant.id]!)")
            restaurant.totalRatings -= currentUser!.restaurantRatings[restaurant.id]!
            restaurant.totalRatings += rating
//            currentUser!.restaurantRatings[restaurant.id] = rating
            print("after rerating \(restaurant.totalRatings)")
        }
        else {
            print("before new rating \(restaurant.numOfRaters), \(restaurant.totalRatings)")
            restaurant.numOfRaters += 1
            restaurant.totalRatings += rating
//            currentUser!.restaurantRatings[restaurant.id] = rating
            print("after new rating \(restaurant.numOfRaters), \(restaurant.totalRatings)")
        }
        
        
        print("before comments and ratings \(comments_and_ratings)")
//        var commentAndRating = comments_and_ratings[restaurant.id]!
//        commentAndRating["number_of_raters"] = restaurant.numOfRaters
//        commentAndRating["total_rating"] = restaurant.totalRatings
        comments_and_ratings[restaurant.id] = ["number_of_raters": restaurant.numOfRaters, "total_rating": restaurant.totalRatings, "comments": restaurant.comments]
        print("after comments and ratings \(comments_and_ratings)")
        

        if let data = try? JSONSerialization.data(withJSONObject: comments_and_ratings, options: []) {
            UserDefaults.standard.set(data, forKey: "COMMENTS_AND_RATINGS")
            print("saved comments and ratings")
        }
        

        
//        print("before updating users rating \(users)")
//        var userData = users[currentUser!.username]!
//        var ratings: [String: Int] = userData["ratings"] as! [String: Int]
//        ratings[restaurant.id] = rating
//        userData["rating"] = ratings
//        users[currentUser!.username]! = userData
//        print("after updating users rating \(users)")
//        
//        if let data = try? JSONSerialization.data(withJSONObject: users, options: []) {
//            UserDefaults.standard.set(data, forKey: "USERS")
//            print("saved users")
//        }
    }
    
    func comment(restaurant: Restaurant, comment: String, username: String) {
        var allComments = restaurant.comments
        allComments[username] = comment
        restaurant.comments = allComments
        
        print("before comments and ratings \(comments_and_ratings)")
        comments_and_ratings[restaurant.id] = ["number_of_raters": restaurant.numOfRaters, "total_rating": restaurant.totalRatings, "comments": restaurant.comments]
        print("after comments and ratings \(comments_and_ratings)")
        

        if let data = try? JSONSerialization.data(withJSONObject: comments_and_ratings, options: []) {
            UserDefaults.standard.set(data, forKey: "COMMENTS_AND_RATINGS")
            print("saved comments and ratings")
        }
    }
    
    
}

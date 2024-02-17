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
    private let API_KEY = ""
    @Published var restaurants : [Restaurant] = []
    private let restaurantRepository = RestaurantRepository()
        
    init(){
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
                    let name: String = restaurantJSON["name"].stringValue
                    let location: String = restaurantJSON["location"]["display_address"].arrayValue.reduce("", {$0 + $1.stringValue})
                    let iconUrl: URL? = restaurantJSON["image_url"].url
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
    
    func searchRestaurants(for searchTerm: String, in restaurants: [Restaurant]) -> [Restaurant] {        
        if searchTerm.isEmpty{
            return restaurants
        }else{
            return restaurants.filter{ restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }
    
    
    func getRestaurantDetails(restaurant: Restaurant) {
        let apiURL = "https://api.yelp.com/v3/businesses/\(restaurant.id)"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(API_KEY)","Content-Type": "application/json"]
        
        AF.request(apiURL, headers: headers).responseJSON{ response in
            print("response is \(response)")
            switch response.result {
            case .success(let responseData):
                let restaurantJSON = JSON(responseData)
                    print("restaurant detail json is \(restaurantJSON)")
                    
                    let name: String = restaurantJSON["name"].stringValue
                    let location: String = restaurantJSON["location"]["display_address"].arrayValue.reduce("", {$0 + $1.stringValue})
                    let restaurantUrl = try? restaurantJSON["url"].stringValue.asURL()
                    let iconUrl: URL? = restaurantJSON["image_url"].url
                    let cateogory: String = restaurantJSON["categories"].arrayValue.first!.dictionaryValue["title"]!.stringValue
                    let photoUrls: [URL] = restaurantJSON["photos"].arrayValue.map {$0.url!}
                    let hours = restaurantJSON["hours"].arrayValue.first?.dictionaryValue["open"]!.arrayValue.map {$0.dictionaryValue} ?? []
                    let price: String = restaurantJSON["price"].stringValue
                
                    print("json parsed \(name), \(location), \(iconUrl), \(cateogory), \(photoUrls), \(hours), \(price)")
                    
                    var openingHours: [Int: String] = [:]
                
                    for hour in hours {
                        print("weekday is \(hour)")
                        openingHours[hour["day"]!.intValue] = "\(hour["start"] ?? "0000") - \(hour["end"] ?? "2400")"
                    }
                
                
                    self.objectWillChange.send()
                    restaurant.name = name
                    restaurant.location = location
                    restaurant.restaurantUrl = restaurantUrl
                    restaurant.iconUrl = iconUrl
                    restaurant.photoUrls = photoUrls
                    restaurant.category = cateogory
                    restaurant.openingHours = openingHours
                    restaurant.price = price
                    self.restaurantRepository.populateCommentsAndRatings(restaurant: restaurant)
                
                
                print(#function, "restaurants - \(restaurant.openingHours), \(restaurant.photoUrls), \(restaurant.price)")
                
                case .failure(let error):
                    print(#function, "Unsuccessful response from server : \(error)")
            }
            
        }
    }
    
    func rate(restaurant: Restaurant, rating: Int, currentUser: User?) {
        if currentUser!.restaurantRatings.keys.contains(restaurant.id) {
            restaurant.totalRatings -= currentUser!.restaurantRatings[restaurant.id]!
            restaurant.totalRatings += rating
        }
        else {
            restaurant.numOfRaters += 1
            restaurant.totalRatings += rating
        }
        
        restaurantRepository.updateRating(restaurant: restaurant, rating: rating)
        
    }
    
    func comment(restaurant: Restaurant, comment: String, username: String) {
        var allComments = restaurant.comments
        allComments[username] = comment
        restaurant.comments = allComments
        
        restaurantRepository.updateComment(restaurant: restaurant, comment: comment)
    }
    
    
}

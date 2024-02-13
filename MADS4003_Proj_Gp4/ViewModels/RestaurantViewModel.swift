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
                    print("1")
                    let name: String = restaurantJSON["name"].stringValue
                    print("2")
                    let location: String = restaurantJSON["location"]["display_address"].arrayValue.reduce("", {$0 + $1.stringValue})
                    print("3")
                    let iconUrl: URL? = restaurantJSON["image_url"].url
                    print("4")
                    let cateogory: String = restaurantJSON["categories"].arrayValue.first!.dictionaryValue["title"]!.stringValue
                    
                    print("json parsed \(id), \(name), \(location), \(String(describing: iconUrl)), \(cateogory)")
                    
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
                    let iconUrl: URL? = restaurantJSON["image_url"].url
                    print("4")
                    let cateogory: String = restaurantJSON["categories"].arrayValue.first!.dictionaryValue["title"]!.stringValue
                    print("5")
                    let photoUrls: [URL] = restaurantJSON["photos"].arrayValue.map {$0.url!}
                    print("6")
                    let hours = restaurantJSON["hours"].arrayValue.first!.dictionaryValue["open"]!.arrayValue.map {$0.dictionaryValue}
                    print("7")
                    let price: String = restaurantJSON["price"].stringValue
                
                    print("json parsed \(name), \(location), \(iconUrl), \(cateogory), \(photoUrls), \(hours), \(price)")
                    
                    var openingHours: [String: String] = [:]
                
                    for hour in hours {
                        let weekDay = weekDays[hour["day"]!.intValue]!
                        print("weekday is \(hour), \(weekDay)")
                        openingHours[weekDay] = "\(hour["start"]) - \(hour["end"])"
                    }
                
                    restaurant.openingHours = openingHours
                    restaurant.photoUrls = photoUrls
                    restaurant.price = price
                
                
                print(#function, "restaurants - \(restaurant)")
                
                case .failure(let error):
                    print(#function, "Unsuccessful response from server : \(error)")
            }
            
        }
    }
}

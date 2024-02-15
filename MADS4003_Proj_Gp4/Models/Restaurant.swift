//
//  restaurant.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import Foundation


class Restaurant: Identifiable, ObservableObject {
    let id: String
    var name: String
    var location: String
    var restaurantUrl: URL?
    
    var iconUrl: URL?
    var photoUrls: [URL]?
    var category: String
//    var openingHours: [WeekDay: String]? = nil
//    var openingHours: [String: String]? = nil
    var openingHours: [Int: String]? = nil
    var price: String? = nil
    @Published var numOfRaters: Int = 0
    @Published var totalRatings: Int = 0
    @Published var comments: [String: String] = [:]
 
    init(id: String, name: String, location: String, iconUrl: URL?, category: String) {
        self.id = id
        self.name = name
        self.location = location
        self.iconUrl = iconUrl
        self.category = category
    }
    
    init(id: String, data: [String: Any]){
        self.id = id
        self.name = data["name"] as! String
        self.location = data["location"] as! String
        self.iconUrl = data["iconUrl"] as? URL
        self.category = data["category"] as! String
    }
    
    // For preview testing
    init() {
        self.id = "QWkibGOZrgrPLx_WRwcciw"
        self.name = "testing"
        self.location = "here"
        self.restaurantUrl = try! "https://www.yelp.com/biz/mira-toronto?adjust_creative=1fOYSSwCXzn7QqX8cf0bDw&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=1fOYSSwCXzn7QqX8cf0bDw".asURL()
        self.iconUrl = try? "https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg".asURL()
        self.photoUrls = [try! "https://t3.ftcdn.net/jpg/03/24/73/92/360_F_324739203_keeq8udvv0P2h1MLYJ0GLSlTBagoXS48.jpg".asURL(), try! "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cmVzdGF1cmFudHxlbnwwfHwwfHx8MA%3D%3D".asURL()]
        self.category = "fast food"
        self.price = "$$$"
//        self.openingHours = [.mon: "0000-2000", .wed: "0100-2100", .fri: "0200-2200"]
//        self.openingHours = ["Monday": "0000-2000", "Wednesday": "0100-2100", "Friday": "0200-2200"]
        self.openingHours = [1: "0000-2000", 3: "0100-2100", 5: "0200-2200"]
    }
}

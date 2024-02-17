//
//  RestaurantRepository.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 16/2/2024.
//

import Foundation



class RestaurantRepository {
    private var all_fav: [String: [String: Any]] = [:] // structure [restaurant id: [name: String, location: String, category: String]]
    private var comments_and_ratings: [String: [String: Any]] = [:]  // structure [restaurant ids: [number of raters: Int, total rating: Int, comment_and_commenter: [commenter: comment]]]
    
    init() {
        self.comments_and_ratings = self.getCommentsAndRatings()
        self.all_fav = self.getAllFavRestaurants()
    }
    
    func getFavRestaurantsByIds(ids: [String]) -> [Restaurant] {
        return ids.compactMap {
            guard all_fav.keys.contains($0) else {
                return nil
            }
            return Restaurant(id: $0, data: all_fav[$0]!)
        }
    }
    
    private func getAllFavRestaurants() -> [String: [String: Any]] {
        
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULT_VAL.ALL_FAV_RESTAURANT.rawValue) {
            all_fav = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] ?? [:]
        }
        
        return all_fav
    }
    
    private func getCommentsAndRatings() -> [String: [String: Any]]{
        
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULT_VAL.COMMENTS_AND_RATINGS.rawValue) {
            comments_and_ratings = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] ?? [:]
            
            for id in comments_and_ratings.keys {
                if let data = comments_and_ratings[id],
                   let numOfRaters = data[COMMENTS_AND_RATINGS_KEY.NUM_OF_RATERS.rawValue] as? Int,
                   let totalRating = data[COMMENTS_AND_RATINGS_KEY.TOTAL_RATING.rawValue] as? Int,
                   let comments = data[COMMENTS_AND_RATINGS_KEY.COMMENTS.rawValue] as? [String: String]
                {
                    comments_and_ratings[id] = [COMMENTS_AND_RATINGS_KEY.NUM_OF_RATERS.rawValue: numOfRaters, COMMENTS_AND_RATINGS_KEY.TOTAL_RATING.rawValue: totalRating, COMMENTS_AND_RATINGS_KEY.COMMENTS.rawValue: comments]
                }
            }
            print("get user defaults comments and ratings \(comments_and_ratings)")
        }
        
        return comments_and_ratings
    }
    
    func populateCommentsAndRatings(restaurant: Restaurant) {
        if let commentAndRating = self.comments_and_ratings[restaurant.id] {
            print("getting comment and rating \(commentAndRating)")
            restaurant.numOfRaters = commentAndRating[COMMENTS_AND_RATINGS_KEY.NUM_OF_RATERS.rawValue] as! Int
            restaurant.totalRatings = commentAndRating[COMMENTS_AND_RATINGS_KEY.TOTAL_RATING.rawValue] as! Int
            restaurant.comments = commentAndRating[COMMENTS_AND_RATINGS_KEY.COMMENTS.rawValue] as! [String : String]
        }
    }
    
    func addAllFavRestaurants(restaurant: Restaurant) {
        var data: [String: Any] = [ALL_FAV_RESTAURANT_KEY.NAME.rawValue: restaurant.name, ALL_FAV_RESTAURANT_KEY.LOCATION.rawValue: restaurant.location, ALL_FAV_RESTAURANT_KEY.CATEGORY.rawValue: restaurant.category]
        if restaurant.iconUrl != nil {
            data["iconUrl"] = restaurant.iconUrl!.absoluteString
        }
        all_fav[restaurant.id] = data
        
        if let data = try? JSONSerialization.data(withJSONObject: all_fav, options: []) {
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_VAL.ALL_FAV_RESTAURANT.rawValue)
        }
    }
    
    func updateRating(restaurant: Restaurant, rating: Int) {
        comments_and_ratings[restaurant.id] = [COMMENTS_AND_RATINGS_KEY.NUM_OF_RATERS.rawValue: restaurant.numOfRaters, COMMENTS_AND_RATINGS_KEY.TOTAL_RATING.rawValue: restaurant.totalRatings, COMMENTS_AND_RATINGS_KEY.COMMENTS.rawValue: restaurant.comments]

        if let data = try? JSONSerialization.data(withJSONObject: comments_and_ratings, options: []) {
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_VAL.COMMENTS_AND_RATINGS.rawValue)
            print("saved comments and ratings")
        }
    }
    
    func updateComment(restaurant: Restaurant, comment: String) {
        comments_and_ratings[restaurant.id] = [COMMENTS_AND_RATINGS_KEY.NUM_OF_RATERS.rawValue: restaurant.numOfRaters, COMMENTS_AND_RATINGS_KEY.TOTAL_RATING.rawValue: restaurant.totalRatings, COMMENTS_AND_RATINGS_KEY.COMMENTS.rawValue: restaurant.comments]

        if let data = try? JSONSerialization.data(withJSONObject: comments_and_ratings, options: []) {
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_VAL.COMMENTS_AND_RATINGS.rawValue)
            print("saved comments and ratings")
        }
    }
}

//
//  RestaurantDetailView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import SwiftUI

struct RestaurantDetailView: View {
//    @ObservedObject var userViewModel = UserViewModel()
//    @ObservedObject var restaurantViewModel = RestaurantViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
//    @EnvironmentObject private var restaurant: Restaurant
    var restaurant: Restaurant
    
    var body: some View {
        
        VStack {
            
            ForEach(restaurant.photoUrls ?? [], id: \.self) { imageUrl in
                AsyncImage(url: imageUrl){ phase in
                    
                    switch phase{
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    
                    @unknown default:
                        Image(systemName: "broken_image")
                            .onAppear(){
                                print("\(#function) cannot show image")
                            }
                    }
                }
            }

        
        
            Text("\(restaurant.name)")
            Text("Address: \(restaurant.location)")
            Text("Category: \(restaurant.category)")
            
            if restaurant.price != nil {
                Text("Price: \(restaurant.price!)")
            }
        
            ForEach(weekDays.keys.sorted(), id: \.self) { key in
                Text("\(weekDays[key]!): \(restaurant.openingHours?[key] ?? "Close")")
            }
        
        
            /*    TODO: 5 Star rating bar and comment session */
            
            HStack {
//                Button {
//                    userViewModel.share()
//                } label: {
//                    Text("Share")
//                }
                if restaurant.restaurantUrl != nil {
                    ShareLink(item: restaurant.restaurantUrl!) {
                        Label(restaurant.name, systemImage: "swift")
                    }
                }
                
                
                Button {
                    userViewModel.addToFav(restaurant: restaurant)
                } label: {
                    Text("Favourite")
                }
            }

        }
        .onAppear(){
            print("getting restaurant details: \(restaurant)")
            
            restaurantViewModel.getRestaurantDetails(restaurant: restaurant)
            
            print("after update \(restaurant.id), \(restaurant.photoUrls), \(restaurant.openingHours)")
        }
    }
}


struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
//        RestaurantDetailView(restaurant: Restaurant())
        
        
        UserDefaults.standard.set(["tester": ["passoword": 12345678, "remember_me": false, "fav_restaurant_ids": []]], forKey: "CURRENT_USER")
        
        return RestaurantDetailView(restaurant: Restaurant()).environmentObject(UserViewModel()).environmentObject(RestaurantViewModel())
            .onAppear {
                // Optionally clear or reset UserDefaults after previewing
//                UserDefaults(suiteName: UserDefaults.preview)?.removePersistentDomain(forName: UserDefaults.preview)
                
                // Reset UserDefaults value after previewing
                  UserDefaults.standard.removeObject(forKey: "CURRENT_USER")
            }
    }
}

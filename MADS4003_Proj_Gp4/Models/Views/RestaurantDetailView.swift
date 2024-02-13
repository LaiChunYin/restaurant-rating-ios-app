//
//  RestaurantDetailView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import SwiftUI

struct RestaurantDetailView: View {
    @ObservedObject var userViewModel = UserViewModel()
    @ObservedObject var restaurantViewModel = RestaurantViewModel()
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
                        
                    case .failure:
                        Text("Error")
                            .font(.headline)
                        
                        
                        
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
        
        
            /*    TODO: Opening hours */
        
        
            /*    TODO: 5 Star rating bar and comment session */
            
            HStack {
                Button {
                    userViewModel.share()
                } label: {
                    Text("Share")
                }
                
                
                Button {
                    userViewModel.addToFav()
                } label: {
                    Text("Favourite")
                }
            }

        }
        .onAppear(){
            print("getting restaurant details: \(restaurant)")
            
            restaurantViewModel.getRestaurantDetails(restaurant: restaurant)
        }
    }
}


struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(restaurant: Restaurant())
    }
}

//
//  RestaurantListView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import SwiftUI

struct RestaurantListView: View {
    @ObservedObject private var restaurantViewModel = RestaurantViewModel()
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            

            Text("testing")
            

            List(restaurantViewModel.restaurants) {restaurant in
//                RestaurantItemView().environmentObject(restaurant)
                
                NavigationLink {
                    RestaurantDetailView(restaurant: restaurant)
                } label: {
                    RestaurantItemView(restaurant: restaurant)
                }
                
            }
        }
        .onAppear(){
            print("getting from api")
            restaurantViewModel.getRestaurants()
        }
        .searchable(text: $searchText, prompt: "Search Restaurant")
    }
}


struct RestaurantListView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantListView()
    }
}

//
//  RestaurantListView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import SwiftUI

struct RestaurantListView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var restaurantViewModel: RestaurantViewModel
    @State private var searchText: String = ""
    
    private var filteredRestaurant: [Restaurant]? {
        return restaurantViewModel.searchRestaurants(for: searchText, in: restaurantViewModel.restaurants)
    }
    
    var body: some View {
        NavigationStack {
            
            List(filteredRestaurant ?? []) { restaurant in
                NavigationLink {
                    RestaurantDetailView(restaurant: restaurant)
                } label: {
                    RestaurantItemView(restaurant: restaurant)
                }
            }
            .searchable(text: $searchText, prompt: "Search Restaurants")
            .autocorrectionDisabled()
        }
    }
}


struct RestaurantListView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantListView().environmentObject(RestaurantViewModel())
    }
}

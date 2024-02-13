//
//  RestaurantListView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import SwiftUI

struct RestaurantListView: View {
    @ObservedObject private var restaurantViewModel = RestaurantViewModel()
    @State var searchText: String = ""
    
    var filteredRestaurant: [Restaurant] {
        print("searching for: \(searchText)")
        return restaurantViewModel.searchRestaurants(for: searchText)
    }
    
    var body: some View {
        NavigationStack {
            
            List(filteredRestaurant) { restaurant in
                NavigationLink {
                    RestaurantDetailView(restaurant: restaurant)
                } label: {
                    RestaurantItemView(restaurant: restaurant)
                }
            }
            .searchable(text: $searchText)
            .autocorrectionDisabled()
        }
        .onAppear(){
            print("getting from api")
        }
    }
}


struct RestaurantListView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantListView()
    }
}

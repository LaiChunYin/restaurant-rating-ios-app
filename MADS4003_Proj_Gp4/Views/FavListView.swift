//
//  FavListView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 12/2/2024.
//

import SwiftUI

struct FavListView: View {
    @State private var searchText: String = ""
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject private var restaurantViewModel: RestaurantViewModel
    
    private var filteredRestaurant: [Restaurant]? {
        return restaurantViewModel.searchRestaurants(for: searchText, in: userViewModel.currentUser?.favRestaurants ?? [])
    }
    
    var body: some View {
        
        NavigationStack {
            List {
                
                ForEach(filteredRestaurant ?? []) { restaurant in
                    NavigationLink {
                        RestaurantDetailView(restaurant: restaurant)
                    } label: {
                        RestaurantItemView(restaurant: restaurant)
                    }
                    
                }
                .onDelete(perform: { indexSet in
                    let favList: [Restaurant] = userViewModel.currentUser!.favRestaurants
                    let restaurantsToBeRemoved = indexSet.map { favList[$0] }
                    userViewModel.removeFromFav(restaurants: restaurantsToBeRemoved)
                })
                
            }
            
        }
        .searchable(text: $searchText, prompt: "Search Fav Restaurants")
        .autocorrectionDisabled()
    }
}

struct FavListView_Previews: PreviewProvider {
    static var previews: some View {
        FavListView().environmentObject(UserViewModel()).environmentObject(RestaurantViewModel())
    }
}

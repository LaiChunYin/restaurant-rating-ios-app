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
    
    var body: some View {
        
        NavigationStack {
            List {
                
                ForEach(userViewModel.currentUser?.favRestaurants ?? []) { restaurant in
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
//        .searchable(text: $searchText, prompt: "Search Fav Restaurant")
    }
}

struct FavListView_Previews: PreviewProvider {
    static var previews: some View {
//        FavListView(userViewModel: UserViewModel())
        FavListView().environmentObject(UserViewModel())
    }
}

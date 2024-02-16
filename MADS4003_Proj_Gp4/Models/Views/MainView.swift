//
//  MainView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 12/2/2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        
        NavigationView {
            
            TabView {
                RestaurantListView().tabItem {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text("Explore")
                }
                
                FavListView().tabItem {
                    Image(systemName: "heart.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text("My Favorites")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            userViewModel.logout()
                        } label: {
                            Text("Logout")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("Welcome!")
            .font(.largeTitle)
            .foregroundColor(.blue))

        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(UserViewModel()).environmentObject(RestaurantViewModel())
    }
}


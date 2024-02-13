//
//  MainView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 12/2/2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        
        VStack {
            Text("Main View")
            
            TabView {
                RestaurantListView().tabItem {
                    Image(systemName: "explore")
                        .foregroundColor(.blue)
                    
                    Text("Explore")
                }
                
                FavListView().tabItem {
                    Image(systemName: "favorite")
                        .foregroundColor(.blue)
                    
                    Text("My Favorites")
                }
            }
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


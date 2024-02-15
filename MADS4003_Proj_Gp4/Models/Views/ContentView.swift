//
//  ContentView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 8/2/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var userViewModel = UserViewModel()
    @StateObject var restaurantViewModel = RestaurantViewModel()
//    @State private var currentUser: [String: [String: Any]]? = nil
    
    var body: some View {
        VStack {
            if $userViewModel.currentUser != nil {
                MainView().environmentObject(userViewModel).environmentObject(restaurantViewModel)
            }
            else {
                LoginView().environmentObject(userViewModel).environmentObject(restaurantViewModel)
            }
        }
        .padding()

    }
}

#Preview {
    ContentView()
}

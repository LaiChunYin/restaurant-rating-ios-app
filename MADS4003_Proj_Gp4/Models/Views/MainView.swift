//
//  MainView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 12/2/2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userViewModel: UserViewModel
//    @State private var showAlert: Bool = false
//    @State private var logoutResult: Result? = nil
    
    var body: some View {
        
        NavigationStack {
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
//                            showAlert = true
                            userViewModel.logout()
                        } label: {
                            Text("Logout")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
            }
            .navigationTitle("Welcome!")
//            .alert(isPresented: $showAlert) {
////                let msg: String
////                switch logoutResult {
////                    case .success:
////                        msg = "Logout Sucessful"
////                    default:
////                        msg = "Logout Failed"
////                 }
////                return Alert(title: Text("Logout"), message: Text(msg))
//                Alert(title: Text("Logout"), message: Text("testing"))
//                
//            }

        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


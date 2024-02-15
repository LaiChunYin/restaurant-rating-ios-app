//
//  RestaurantItemView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 11/2/2024.
//

import SwiftUI

struct RestaurantItemView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    var restaurant: Restaurant
    
    var body: some View {
        HStack {
            
            AsyncImage(url: restaurant.iconUrl){ phase in
                
                switch phase{
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                
                default:
                    Image(systemName: "broken_image")
                        .onAppear(){
                            print("\(#function) cannot show image")
                        }
                }
            }
            
            VStack {
                Text("\(restaurant.name)")
                Text("\(restaurant.category)").foregroundColor(.red)
            }
            
        }
    }
}


struct RestaurantItemView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantItemView(restaurant: Restaurant())
    }
}

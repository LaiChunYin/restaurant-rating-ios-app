//
//  RestaurantDetailView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import SwiftUI

struct RestaurantDetailView: View {
//    @ObservedObject var userViewModel = UserViewModel()
//    @ObservedObject var restaurantViewModel = RestaurantViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
//    @EnvironmentObject private var restaurant: Restaurant
    @ObservedObject var restaurant: Restaurant
    @State var rating = 0
    @State private var currentIndex: Int = 0
    @State private var averageRating: String = "No Data"
    @State private var comment: String = ""
    private let images: [Image] = [Image(.restaurant1), Image(.restaurant2), Image(.restaurant3)]

    struct OpeningHoursView: View {
        let openingHours: [String: String] = [
            "Monday": "10:00 AM - 4:00 PM",
            "Tuesday": "Closed",
            "Wednesday": "Closed",
            "Thursday": "Closed",
            "Friday": "10:00 AM - 4:00 PM",
            "Saturday": "10:00 AM - 4:00 PM",
            "Sunday": "10:00 AM - 4:00 PM"
        ]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(openingHours.sorted(by: { $0.key < $1.key }), id: \.key) { day, hours in
                    Text("\(day.capitalized): \(hours)")
                        .font(.body)
                }
            }
        }
    }

    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(restaurant.photoUrls ?? [], id: \.self) { imageUrl in
                    AsyncImage(url: imageUrl){ phase in
                        
                        switch phase{
                        case .success(let image):
                            image.resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        
                        default:
                            Image(systemName: "broken_image")
                                .onAppear(){
                                    print("\(#function) cannot show image")
                                }
                        }
                    }
                }
//                TabView(selection: $currentIndex) {
////                    ForEach(images.indices, id: \.self) { index in
////                        images[index]
////                            .resizable()
////                            .aspectRatio(contentMode: .fill)
////                            .cornerRadius(10)
////                            .padding()
////                            .tag(index)
////                    }
//                    ForEach(restaurant.photoUrls ?? [], id: \.self) { imageUrl in
//                        AsyncImage(url: imageUrl){ phase in
//                            
//                            switch phase{
//                            case .success(let image):
//                                image.resizable()
//                                .scaledToFit()
//                                .frame(width: 50, height: 50)
//                            
//                            default:
//                                Image(systemName: "broken_image")
//                                    .onAppear(){
//                                        print("\(#function) cannot show image")
//                                    }
//                            }
//                        }
//                    }
//                }
//                .frame(width: .infinity, height: 200)
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                //            ForEach(restaurant.photoUrls ?? [], id: \.self) { imageUrl in
                //                AsyncImage(url: imageUrl){ phase in
                //
                //                    switch phase{
                //                    case .success(let image):
                //                        image
                //                            .resizable()
                //                            .scaledToFit()
                //                            .frame(width: 50, height: 50)
                //
                //                    case .failure:
                //                        Text("Error")
                //                            .font(.headline)
                //
                //
                //
                //                    @unknown default:
                //                        Image(systemName: "broken_image")
                //                            .onAppear(){
                //                                print("\(#function) cannot show image")
                //                            }
                //                    }
                //                }
                //            }
                
                
                Spacer()
                
                
                
                Text("\(restaurant.name)")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Address:")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text(restaurant.location)
                        .font(.body)
                    
                    Text("Category:")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text(restaurant.category)
                        .font(.body)
                    
                    if restaurant.price != nil {
                        Text("Price:")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text(restaurant.price!)
                            .font(.body)
                    }
                
                    
                    
                    Divider()
                    
                    Text("Opening Hours:")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    
//                    OpeningHoursView()
//                        .padding(.top, 5)
                    ForEach(weekDays.keys.sorted(), id: \.self) { key in
                        Text("\(weekDays[key]!): \(restaurant.openingHours?[key] ?? "Close")")
                    }
                    
                    if(!restaurant.comments.isEmpty) {
                        VStack {
                            Text("Users' Comments:")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            ForEach(restaurant.comments.keys.map {$0}, id: \.self) { commenter in
                                
                                HStack(alignment: .top) {
                                    Text("\(commenter)")
                                    Text("\(restaurant.comments[commenter]!)")
                                }
                            }
                        }
                    }
                }.padding()
                    
                
                StarRatingView(rating: $rating, maxRating: 5)
                    .padding()
                    .onChange(of: rating) {
                        print("changing star rating")
                        restaurantViewModel.rate(restaurant: restaurant, rating: rating, currentUser: userViewModel.currentUser)
                        userViewModel.rate(restaurant: restaurant, rating: rating, currentUser: userViewModel.currentUser)
          
                        
                        averageRating = restaurant.numOfRaters != 0 ? String(format: "%.1f", Double(restaurant.totalRatings) / Double(restaurant.numOfRaters)) : "No data"
                        
                    }
//                    .onAppear(){
//                        print("initializing star rating")
//                        
//                        if restaurant.numOfRaters != 0 && restaurant.totalRatings != nil {
//                            rating = restaurant.totalRatings / restaurant.numOfRaters
//                        }
//                    }
                
                Text("Average rating by users: \(averageRating)")
                    .fontWeight(.light)
                    .foregroundColor(.gray)
            
            
                CommentSectionView(comment: $comment)
                Button {
                    restaurantViewModel.comment(restaurant: restaurant, comment: comment, username: userViewModel.currentUser!.username)
                    comment = ""
                } label: {
                    Text("Submit")
                }
                
                Spacer()
                
                
                HStack {
//                    Button {
//                        userViewModel.share()
//                    } label: {
//                        Text("Share")
//                        Image(systemName: "square.and.arrow.up")
//                            .foregroundColor(.white)
//                    }
//                    .buttonStyle(.borderedProminent)
                    
                    if restaurant.restaurantUrl != nil {
                        ShareLink(item: restaurant.restaurantUrl!) {
                            Label(restaurant.name, systemImage: "swift")
                        }
                    }
                    
                    Spacer()
                    
                    if !userViewModel.currentUser!.favRestaurants.map({$0.id}).contains(restaurant.id) {
                        Button {
                            userViewModel.addToFav(restaurant: restaurant)
                        } label: {
                            Text("Favourite")
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    else {
                        Button {
                            userViewModel.removeFromFav(restaurants: [restaurant])
                        } label: {
                            Text("Remove From Fav")
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    
                }
                .padding(.horizontal, 40)
                
            }
            .padding(.bottom, 40)
            
        }
        .onAppear(){
            print("getting restaurant details: \(restaurant)")
            
            restaurantViewModel.getRestaurantDetails(restaurant: restaurant)
            averageRating = restaurant.numOfRaters != 0 ? String(restaurant.totalRatings / restaurant.numOfRaters) : "No data"
            
            print("after update \(restaurant.id), \(restaurant.photoUrls), \(restaurant.openingHours), \(restaurant.totalRatings), \(restaurant.numOfRaters)")
        }
    }
    
}



struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(restaurant: Restaurant())
    }
}

struct StarRatingView: View {
    @Binding var rating: Int
    let maxRating: Int
    
    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundColor(index <= rating ? .yellow : .gray)
                    .font(.title)
                    .onTapGesture {
                        self.rating = index
                    }
            }
        }
    }
}

struct CommentSectionView: View {
//    @State private var comment: String = ""
    @Binding var comment: String
    @State private var isTappedOnRating: Bool = false
    
    var body: some View {
        VStack {
            Text("Leave a Comment:")
                .font(.headline)
            TextEditor(text: $comment)
                .frame(height: 100)
                .border(Color.gray, width: 1)
                .padding()
                .onTapGesture {
                    if !isTappedOnRating {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            isTappedOnRating = false
                        }
                )
        }

    }
}

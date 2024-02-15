//
//  RestaurantDetailView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import SwiftUI

struct RestaurantDetailView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var restaurantViewModel: RestaurantViewModel
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
                VStack {
                    HStack {
                        ForEach(restaurant.photoUrls ?? [], id: \.self) { imageUrl in
                            AsyncImage(url: imageUrl){ phase in
                                
                                switch phase{
                                case .success(let image):
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width * 0.3, height: 100)
                                    
                                default:
                                    Image(systemName: "broken_image")
                                        .onAppear(){
                                            print("\(#function) cannot show image")
                                        }
                                }
                            }
                        }
                    }.padding(0)
                    
                    
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
                        
                        if restaurant.price != nil && restaurant.price != "" {
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
                            restaurantViewModel.rate(restaurant: restaurant, rating: rating, currentUser: userViewModel.currentUser)
                            userViewModel.rate(restaurant: restaurant, rating: rating, currentUser: userViewModel.currentUser)
                            
                            
                            averageRating = restaurant.numOfRaters != 0 ? String(format: "%.1f", Double(restaurant.totalRatings) / Double(restaurant.numOfRaters)) : "No data"
                            
                        }
                    
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
                restaurantViewModel.getRestaurantDetails(restaurant: restaurant)
                averageRating = restaurant.numOfRaters != 0 ? String(restaurant.totalRatings / restaurant.numOfRaters) : "No data"
                
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
}

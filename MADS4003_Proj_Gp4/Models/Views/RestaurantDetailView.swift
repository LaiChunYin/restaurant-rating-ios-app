//
//  RestaurantDetailView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 10/2/2024.
//

import SwiftUI

struct RestaurantDetailView: View {
    @ObservedObject var userViewModel = UserViewModel()
    @ObservedObject var restaurantViewModel = RestaurantViewModel()
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
    
    //    @EnvironmentObject private var restaurant: Restaurant
    
    @State var rating = 0
    @State private var currentIndex: Int = 0
    private let images: [Image] = [Image(.restaurant1), Image(.restaurant2), Image(.restaurant3)]
    
    var restaurant: Restaurant
    
    var body: some View {
        
        ScrollView {
            
            
            VStack {
                TabView(selection: $currentIndex) {
                    ForEach(images.indices, id: \.self) { index in
                        images[index]
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(10)
                            .padding()
                            .tag(index)
                    }
                }
                .frame(width: .infinity, height: 200)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
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
                    
                    Text("Price:")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("restaurant.price")
                        .font(.body)
                    
                    Divider()
                    
                    Text("Opening Hours:")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    /*    TODO: Opening hours */
                    
                    OpeningHoursView()
                        .padding(.top, 5)
                    
                    
                }.padding()
                    
                     
                
                
             
                
                
                
                
                /*  MARK: 5 Star rating bar and comment session */
                
                StarRatingView(rating: $rating, maxRating: 5)
                                .padding()
                
                CommentSectionView()
                
                Spacer()
                
                /* MARK: Share and Favourite Button */
                
                HStack {
                    Button {
                        userViewModel.share()
                    } label: {
                        Text("Share")
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                    
                    Button {
                        userViewModel.addToFav()
                    } label: {
                        Text("Favourite")
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                }
                .padding(.horizontal, 40)
                
            }
            .padding(.bottom, 40)
            
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
    @State private var comment: String = ""
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

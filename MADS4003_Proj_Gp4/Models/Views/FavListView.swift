//
//  FavListView.swift
//  MADS4003_Proj_Gp4
//
//  Created by macbook on 12/2/2024.
//

import SwiftUI

struct FavListView: View {
    @State private var searchText: String = ""
    
    var body: some View {
        
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .searchable(text: $searchText, prompt: "Search Fav Restaurant")
    }
}

struct FavListView_Previews: PreviewProvider {
    static var previews: some View {
        FavListView()
    }
}

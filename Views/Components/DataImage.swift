//
//  DataImage.swift
//  SimPOS
//
//  Created by Dong on 2024/2/4.
//

import SwiftUI

struct DataImage: View {
    let data: Data?
    
    var body: some View {
        if let data = data,
           let uiImage = UIImage(data: data) {
            Rectangle()
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray)
                .scaledToFit()
                .overlay {
                    Image(systemName: "photo.fill")
                        .imageScale(.large)
                        .font(.title)
                        .foregroundStyle(.white)
                }
        }
    }
}

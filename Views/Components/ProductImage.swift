//
//  ProductImage.swift
//  SimPOS
//
//  Created by Dong on 2024/2/4.
//

import SwiftUI

struct ProductImage: View {
    let data: Data?
    
    var body: some View {
        if let data = data,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
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

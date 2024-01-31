//
//  CreateProductSheet.swift
//  SimPOS
//
//  Created by Dong on 2024/2/1.
//

import PhotosUI
import SwiftUI

struct CreateProductSheet: View {
    @State var name: String = ""
    @State var price: Float = 0
    @State var cost: Float = 0
    @State var storage: Int = 0
    @State var selectedImage: PhotosPickerItem? = nil
    @State var selectedImageData: Data? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                productInfo
                imageSelector
            }
            .multilineTextAlignment(.trailing)
            .navigationTitle("Create product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button {} label: {
                        Text("Save")
                    }
                }
            })
        }
    }
    
    @ViewBuilder
    var productInfo: some View {
        HStack {
            Text("Name")
            TextField("Name", text: $name)
        }
        HStack {
            Text("Price")
            TextField("Price", value: $price, format: .number)
        }
        HStack {
            Text("Cost")
            TextField("Price", value: $price, format: .number)
        }
        HStack {
            Text("Storage")
            TextField("Price", value: $price, format: .number)
        }
    }
    
    var imageSelector: some View {
        VStack(alignment: .leading) {
            PhotosPicker("Select a photo", selection: $selectedImage)
                .onChange(of: selectedImage) { _, image in
                    Task {
                        if let data = try? await image?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
            if let selectedImageData,
               let image = UIImage(data: selectedImageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}

#Preview {
    CreateProductSheet()
}

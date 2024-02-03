//
//  CreateProductSheet.swift
//  SimPOS
//
//  Created by Dong on 2024/2/1.
//

import PhotosUI
import SwiftUI

struct CreateProductSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var name: String = ""
    @State var price: Float?
    @State var cost: Float?
    @State var storage: Int?
    @State var selectedImage: PhotosPickerItem? = nil
    @State var selectedImageData: Data? = nil
    @State var validation = ProductValidation()
    
    
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
                    Button {
                        createProduct()
                    } label: {
                        Text("Save")
                    }
                    .disabled(name.isEmpty || price == nil || validation.hasNameError || validation.hasPriceError)
                }
            })
        }
    }
    
    @ViewBuilder
    var productInfo: some View {
        Section("Required Properties") {
            nameField
            priceField
        }
        Section("Optional Properties") {
            costField
            storageField
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
    
    // MARK: - InputField
    
    var nameField: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("Name")
                TextField("Required", text: $name)
                    .onChange(of: name) { _, newValue in
                        validation.validateName(input: newValue)
                    }
            }
            
            if(validation.hasNameError) {
                errorLabel(validation.nameErrorDescription)
            }
        }
    }
    
    var priceField: some View {
        VStack {
            HStack {
                Text("Price")
                TextField("Required", value: $price, format: .number)
                    .keyboardType(.numberPad)
                    .onChange(of: price) { _, newValue in
                        validation.validatePrice(input: newValue)
                    }
            }
            
            if(validation.hasPriceError) {
                errorLabel(validation.priceErrorDescription)
            }
        }
    }
    
    var costField: some View {
        HStack {
            Text("Cost")
            TextField("", value: $cost, format: .number)
                .keyboardType(.numberPad)
        }
    }
    
    var storageField: some View {
        HStack {
            Text("Storage")
            TextField("", value: $storage, format: .number)
                .keyboardType(.numberPad)        }
    }
    
    func errorLabel(_ description: String) -> some View {
        HStack {
            Image(systemName: "info.circle")
            Text(description)
        }
        .foregroundStyle(.red)
    }
    
    // MARK: - CRUD
    
    func createProduct() {
        let product = Product(
            imageData: selectedImageData,
            name: name,
            price: price ?? 0,
            cost: cost,
            storage: storage
        )

        modelContext.insert(product)
        dismiss()
    }
}

#Preview {
    CreateProductSheet()
}

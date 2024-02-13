//
//  EditProductSheet.swift
//  SimPOS
//
//  Created by Dong on 2024/2/1.
//

import PhotosUI
import SwiftUI

struct EditProductSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var product: Product

    @State var isScannerShow = false
    @State var selectedImage: PhotosPickerItem? = nil
    @State var selectedImageData: Data? = nil
    @State var validation = ProductValidation()
    
    var title = "Create product"
    var save: (Product) -> Void
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = "0"
        return formatter
    }()
    
    
    var body: some View {
        NavigationStack {
            Form {
                productInfo
                barCodeScanner
                imageSelector
            }
            .multilineTextAlignment(.trailing)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .presentationDragIndicator(.visible)
            .toolbar(content: {
                if(title == "Create product") {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            let nameValidation = validation.validateName(input: product.name)
                            let priceValidation = validation.validatePrice(input: product.price)
                            if(nameValidation && priceValidation) {
                                save(product)
                                dismiss()
                            }
                        } label: {
                            Text("Save")
                        }
                    }
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
    
    var barCodeScanner: some View {
        @State var scannerError: ScannerController.ScannerError?
        @State var errorActionIsShow = false
        
        return HStack {
            Button(action: { isScannerShow.toggle() }, label: {Text("Scan a barcode")})
            Spacer()
            Text(product.code ?? "")
        }
        .sheet(isPresented: $isScannerShow) {
            VStack(spacing: 12) {
                GeometryReader { gr in
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: gr.size.width, height: gr.size.width)
                        .overlay {
                            Scanner { result in
                                switch result {
                                    case .success(let success):
                                        product.code = success
                                        isScannerShow = false
                                    case .failure(let failure):
                                        scannerError = failure
                                        errorActionIsShow.toggle()
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                }
                .scaledToFit()
                
                HStack {
                    Text(product.code ?? "")
                    Spacer()
                    Button(action: { product.code = nil }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal)
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium])
            .padding()
            .alert(scannerError?.description() ?? "", isPresented: $errorActionIsShow) {
                Button(action: {errorActionIsShow.toggle()}) {
                    Text("OK")
                }
            }
        }
    }
    
    var imageSelector: some View {
        VStack(alignment: .leading) {
            PhotosPicker("Select a photo", selection: $selectedImage)
                .onChange(of: selectedImage) { _, image in
                    Task {
                        if let data = try? await image?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            product.imageData = data
                        }
                    }
                }
            if let imageData = selectedImageData,
               let image = UIImage(data: imageData) {
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
                TextField("Required", text: $product.name)
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
                TextField("Required", value: $product.price, formatter: numberFormatter)
                    .keyboardType(.decimalPad)
            }
            
            if(validation.hasPriceError) {
                errorLabel(validation.priceErrorDescription)
            }
        }
    }
    
    var costField: some View {
        HStack {
            Text("Cost")
            TextField("", value: $product.cost, format: .number)
                .keyboardType(.decimalPad)
        }
    }
    
    var storageField: some View {
        HStack {
            Text("Storage")
            TextField("", value: $product.storage, format: .number)
                .keyboardType(.numberPad)
        }
    }
    
    func errorLabel(_ description: String) -> some View {
        HStack {
            Image(systemName: "info.circle")
            Text(description)
        }
        .foregroundStyle(.red)
    }
    
}

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
    var save: ((Product) -> Void)?
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = "0"
        return formatter
    }()
    
    
    var body: some View {
        NavigationStack {
            Form {
                productInfo
                Section {
                    barCodeScanner
                    imageSelector
                }
            }
            .multilineTextAlignment(.trailing)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if(title == "Create product") { toolbar }
            }
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
        HStack {
            Button(action: { isScannerShow.toggle() }, label: {Text("Scan barcode")})
            Spacer()
            Text(product.code ?? "")
        }
        .sheet(isPresented: $isScannerShow) {
            GeometryReader { gr in
                VStack(alignment: .center, spacing: 12) {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(
                            width: min(min(gr.size.width, gr.size.height), 500),
                            height: min(min(gr.size.width, gr.size.height), 500)
                        )
                        .overlay { scanner }
                    
                    HStack {
                        Text(product.code ?? "")
                        Spacer()
                        Button(action: { product.code = nil }) {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }
                    .padding(.horizontal)
                    .frame(width: min(min(gr.size.width, gr.size.height), 500))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium])
            .padding()
        }
    }
    
    var scanner: some View {
        @State var scannerError: ScannerController.ScannerError?
        @State var errorActionIsShow = false
        
        return Scanner { result in
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
        .alert(scannerError?.description() ?? "", isPresented: $errorActionIsShow) {
            Button(action: {errorActionIsShow.toggle()}) {
                Text("OK")
            }
        }
    }
    
    var imageSelector: some View {
        VStack(alignment: .leading) {
            PhotosPicker("Select a photo", selection: $selectedImage)
            if selectedImageData != nil {
                DataImage(data: selectedImageData)
            }
        }
        .onChange(of: selectedImage) { _, image in
            Task {
                if let data = try? await image?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                    product.imageData = data
                }
            }
        }
    }
    
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                let nameValidation = validation.validateName(input: product.name)
                let priceValidation = validation.validatePrice(input: product.price)
                if(nameValidation && priceValidation) {
                    if(save != nil) { save!(product) }
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - InputField
    
    var nameField: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("Name")
                TextField("Required", text: $product.name)
                    .frame(maxWidth: .infinity)
            }
            
            if(validation.hasNameError) {
                errorLabel(validation.nameErrorDescription)
            }
        }
    }
    
    var priceField: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("Price")
                TextField("Required", value: $product.price, formatter: numberFormatter)
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: .infinity)
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
                .frame(maxWidth: .infinity)
        }
    }
    
    var storageField: some View {
        HStack {
            Text("Storage")
            TextField("", value: $product.storage, format: .number)
                .keyboardType(.numberPad)
                .frame(maxWidth: .infinity)
        }
    }
    
    func errorLabel(_ description: String) -> some View {
        Label(description, systemImage: "info.circle")
            .labelStyle(.titleAndIcon)
            .foregroundStyle(.red)
    }
    
}

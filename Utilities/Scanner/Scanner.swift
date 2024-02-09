//
//  Scanner.swift
//  
//
//  Created by Dong on 2024/2/9.
//

import AVFoundation
import SwiftUI

struct Scanner: UIViewControllerRepresentable {
    var completion: (Result<String, ScannerError>) -> Void
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return ScannerController { result in
            switch result {
                case .success(let success):
                    completion(.success(success))
                case .failure(let failure):
                    completion(.failure(failure))
            }
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

}

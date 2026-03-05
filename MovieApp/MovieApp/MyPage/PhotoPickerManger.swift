//
//  PhotoPickerManger.swift
//  MovieApp
//
//  Created by t2025-m0239 on 2026.03.05.
//

import UIKit
import PhotosUI

final class PhotoPickerManager: NSObject {
    var selectionHandler: ((UIImage) -> Void)?

    func presentPicker(vc: UIViewController) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        vc.present(picker, animated: true)
    }
}

extension PhotoPickerManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, _) in
            if let selectedImage = image as? UIImage {
                DispatchQueue.main.async { self?.selectionHandler?(selectedImage) }
            }
        }
    }
}

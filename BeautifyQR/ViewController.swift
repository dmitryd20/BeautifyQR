//
//  ViewController.swift
//  BeautifyQR
//
//  Created by Дмитрий Демьянов on 27.11.2021.
//

import UIKit
import WidgetKit

class ViewController: UIViewController {

    // MARK: - Nested Types

    private enum PickerMode {
        case codeImage
        case backgroundImage
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var selectBackgroundButton: UIButton!

    // MARK: - Private Properties

    private var codeContents: String?
    private var pickerMode = PickerMode.codeImage

    private let codeService = QRService()
    private let storageService = StorageService()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        switch pickerMode {
        case .codeImage:
            handleCodeImageLoaded(info[.originalImage] as? UIImage)
        case .backgroundImage:
            handleBackgroundImageLoaded(info[.editedImage] as? UIImage)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

}

// MARK: - Private Methods

private extension ViewController {

    func setupInitialState() {
        imageView.image = storageService.lastImage
    }

    func handleCodeImageLoaded(_ image: UIImage?) {
        guard let image = image?.cgImage, let imageCodeContents = codeService.getCode(from: image) else {
            DispatchQueue.main.async { self.showError() }
            return
        }

        codeContents = imageCodeContents
        let basicCodeImage = codeService.buildImage(for: imageCodeContents)
        DispatchQueue.main.async { self.showImage(basicCodeImage) }
    }

    func handleBackgroundImageLoaded(_ image: UIImage?) {
        guard let codeContents = codeContents else {
            return
        }

        let codeWithBackground = codeService.buildImage(for: codeContents, withBackground: image)
        DispatchQueue.main.async { self.showImage(codeWithBackground) }
    }

    func showError() {
        let alert = UIAlertController(
            title: "🙁",
            message: "QR код на картинке не удалось распознать",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true) { [weak self] in
            self?.showImage(nil)
        }
    }

    func showImage(_ image: UIImage?) {
        activityIndicator.stopAnimating()
        imageView.image = image
        UIView.animate(withDuration: 0.3) {
            self.selectBackgroundButton.isHidden = image == nil
        }
        storageService.lastImage = image
        updateWidget()
    }

    func showImagePicker(withCropping: Bool) {
        let picker = UIImagePickerController()
        picker.allowsEditing = withCropping
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    func updateWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }

}

// MARK: - Actions

private extension ViewController {

    @IBAction
    func showCodeImageSelector() {
        self.pickerMode = .codeImage
        showImagePicker(withCropping: false)
    }

    @IBAction
    func showBackgroundImageSelector() {
        self.pickerMode = .backgroundImage
        showImagePicker(withCropping: true)
    }

    @IBAction
    func handleImageTouched() {
        guard let image = imageView.image else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true)
    }

}


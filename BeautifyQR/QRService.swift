//
//  QRService.swift
//  BeautifyQR
//
//  Created by Дмитрий Демьянов on 27.11.2021.
//

import UIKit
import EFQRCode

final class QRService {

    func getCode(from image: CGImage) -> String? {
        return EFQRCode.recognize(image).first
    }

    func buildImage(for code: String, withBackground image: UIImage? = nil) -> UIImage? {
        return EFQRCode
            .generate(for: code, watermark: image?.cgImage, watermarkMode: .scaleAspectFill)
            .map(UIImage.init(cgImage:))
    }

}

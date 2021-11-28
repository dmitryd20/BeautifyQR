//
//  StorageService.swift
//  BeautifyQR
//
//  Created by Дмитрий Демьянов on 28.11.2021.
//

import Foundation
import UIKit

public class StorageService {

    // MARK: - Keys

    private enum Keys {
        static let lastImage = "lastImage"
    }

    // MARK: - Public Properties

    public var lastImage: UIImage? {
        get {
            guard let data = storage?.data(forKey: Keys.lastImage) else {
                return nil
            }
            return UIImage(data: data)
        }
        set {
            guard let data = newValue?.pngData() else {
                return
            }
            storage?.set(data, forKey: Keys.lastImage)
        }
    }

    // MARK: - Private Properties

    private let storage = UserDefaults(suiteName: "group.ru.demyanov.BeautifyQR")

    // MARK: - Initialization

    public init() {}

}

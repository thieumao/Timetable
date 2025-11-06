//
//  LocalizationManager.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: String = "en"
    
    static let shared = LocalizationManager()
    
    private let supportedLanguages = ["en", "vi"]
    private let userDefaultsKey = "app_language"
    
    private init() {
        loadLanguage()
    }
    
    // Detect and set language based on device language or saved preference
    private func loadLanguage() {
        if let savedLanguage = UserDefaults.standard.string(forKey: userDefaultsKey),
           supportedLanguages.contains(savedLanguage) {
            currentLanguage = savedLanguage
        } else {
            // Detect device language
            let deviceLanguage = Locale.preferredLanguages.first?.prefix(2) ?? "en"
            if supportedLanguages.contains(String(deviceLanguage)) {
                currentLanguage = String(deviceLanguage)
            } else {
                currentLanguage = "en" // Default to English
            }
            saveLanguage()
        }
    }
    
    func setLanguage(_ language: String) {
        if supportedLanguages.contains(language) {
            currentLanguage = language
            saveLanguage()
        }
    }
    
    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage, forKey: userDefaultsKey)
    }
    
    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: LocalizationManager.shared.bundle, comment: "")
    }
}

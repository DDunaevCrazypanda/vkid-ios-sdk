//
// Copyright (c) 2023 - present, LLC “V Kontakte”
//
// 1. Permission is hereby granted to any person obtaining a copy of this Software to
// use the Software without charge.
//
// 2. Restrictions
// You may not modify, merge, publish, distribute, sublicense, and/or sell copies,
// create derivative works based upon the Software or any part thereof.
//
// 3. Termination
// This License is effective until terminated. LLC “V Kontakte” may terminate this
// License at any time without any negative consequences to our rights.
// You may terminate this License at any time by deleting the Software and all copies
// thereof. Upon termination of this license for any reason, you shall continue to be
// bound by the provisions of Section 2 above.
// Termination will be without prejudice to any rights LLC “V Kontakte” may have as
// a result of this agreement.
//
// 4. Disclaimer of warranty and liability
// THE SOFTWARE IS MADE AVAILABLE ON THE “AS IS” BASIS. LLC “V KONTAKTE” DISCLAIMS
// ALL WARRANTIES THAT THE SOFTWARE MAY BE SUITABLE OR UNSUITABLE FOR ANY SPECIFIC
// PURPOSES OF USE. LLC “V KONTAKTE” CAN NOT GUARANTEE AND DOES NOT PROMISE ANY
// SPECIFIC RESULTS OF USE OF THE SOFTWARE.
// UNDER NO CIRCUMSTANCES LLC “V KONTAKTE” BEAR LIABILITY TO THE LICENSEE OR ANY
// THIRD PARTIES FOR ANY DAMAGE IN CONNECTION WITH USE OF THE SOFTWARE.
//

import Foundation
import VKID

extension AuthViewController {
    func buildDebugSettings() -> DebugSettingsViewModel {
        DebugSettingsViewModel(
            title: "DebugSettings",
            sections: [
                .init(
                    title: "Color Scheme",
                    cells: self.colorSchemeCells()
                ),
                .init(
                    title: "Locale",
                    cells: self.localeCells()
                ),
                .init(
                    title: "Network",
                    cells: self.networkConfigurationCells()
                ),
            ]
        )
    }

    private func colorSchemeCells() -> [DebugSettingsCellViewModel] {
        Appearance
            .ColorScheme
            .allCases
            .map { theme in
                DebugSettingsCheckboxCellViewModel(
                    title: "\(theme)",
                    checked: self.appearance.colorScheme == theme
                ) { [weak self] in
                    self?.appearance.colorScheme = theme
                    self?.updateSettings()
                }
            }
    }

    private func localeCells() -> [DebugSettingsCellViewModel] {
        Appearance
            .Locale
            .allCases
            .map { locale in
                DebugSettingsCheckboxCellViewModel(
                    title: "\(locale)",
                    checked: self.appearance.locale == locale
                ) { [weak self] in
                    self?.appearance.locale = locale
                    self?.updateSettings()
                }
            }
    }

    private func networkConfigurationCells() -> [DebugSettingsCellViewModel] {
        [
            DebugSettingsToggleCellViewModel(
                title: "SSL Pinning Enabled",
                isOn: self.debugSettings.isSSLPinningEnabled
            ) { [weak self] in
                self?.debugSettings.isSSLPinningEnabled.toggle()
                self?.updateSettings()
            },
        ]
    }

    func updateSettings() {
        self.debugSettingsVC?.render(viewModel: self.buildDebugSettings())
    }
}
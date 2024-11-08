//
// Copyright (c) 2024 - present, LLC “V Kontakte”
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

import XCTest

public struct AllureReportAttribute {
    public var name: String
    public var value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }

    public init(label: String, value: String) {
        self.init(name: "label.\(label)", value: value)
    }
}

extension Allure {
    public static func report(_ attributes: AllureReportAttribute...) {
        self.report(attributes)
    }

    public static func report(_ attributes: [AllureReportAttribute]) {
        attributes.forEach {
            XCTContext.runActivity(
                named: "allure.\($0.name):\($0.value)",
                block: { _ in }
            )
        }
    }

    public static func report(_ reportables: AllureReportable...) {
        Allure.report(
            reportables.flatMap(\.allureReportAttributes)
        )
    }

    public static func report(_ testCase: Allure.TestCase) {
        Allure.report(testCase.allureReportAttributes)
    }
}

public protocol AllureReportable {
    var allureReportAttributes: [AllureReportAttribute] { get }
}

extension AllureReportable where Self: RawRepresentable, Self.RawValue == String {
    public var allureReportAttributes: [AllureReportAttribute] {
        [
            .init(
                label: String(describing: Self.self).lowercased(),
                value: rawValue
            ),
        ]
    }
}

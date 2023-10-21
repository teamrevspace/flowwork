//
//  ViewKeys.swift
//  Flow Work
//
//  Created by Allen Lin on 10/21/23.
//

import Foundation
import SwiftUI

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

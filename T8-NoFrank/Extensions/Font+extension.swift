//
//  Font+extension.swift
//  T8-NoFrank
//
//  Created by 이주현 on 8/7/25.
//

import SwiftUI

enum FontName: String {
    case CustomFont = "" // 추후 폰트 파일 이름 추가
}

extension Font {
    static let countdown: Font = .custom(FontName.CustomFont.rawValue, size: 128)
    
    static let largeTitle01: Font = .custom(FontName.CustomFont.rawValue, size: 44)
    static let largeTitle02: Font = .custom(FontName.CustomFont.rawValue, size: 40)
    
    static let title01: Font = .custom(FontName.CustomFont.rawValue, size: 24)
    static let title02: Font = .custom(FontName.CustomFont.rawValue, size: 20)
    static let title03: Font = .custom(FontName.CustomFont.rawValue, size: 18)
    
    static let text01: Font = .custom(FontName.CustomFont.rawValue, size: 16)
    static let text02: Font = .custom(FontName.CustomFont.rawValue, size: 14)

}

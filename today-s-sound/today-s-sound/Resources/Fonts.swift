//
//  Fonts.swift
//  today-s-sound
//
//  Created by 하승연 on 9/28/25.
//

import Foundation
import SwiftUI

extension Font {
  enum Koddi {
    case extraBold
    case bold
    case regular

    var value: String {
      switch self {
      case .extraBold:
        "KoddiUDOnGothic-ExtraBold"
      case .bold:
        "KoddiUDOnGothic-Bold"
      case .regular:
        "KoddiUDOnGothic-Regular"
      }
    }
  }

  static func koddi(type: Koddi, size: CGFloat) -> Font {
    .custom(type.value, size: size)
  }

  static var KoddiBold56: Font {
    .koddi(type: .bold, size: 56)
  }
}

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

  static var KoddiBold48: Font {
    .koddi(type: .bold, size: 48)
  }

  static var KoddiExtraBold32: Font {
    .koddi(type: .extraBold, size: 32)
  }

  static var KoddiBold28: Font {
    .koddi(type: .bold, size: 28)
  }

  static var KoddiExtraBold28: Font {
    .koddi(type: .extraBold, size: 28)
  }

  static var KoddiBold20: Font {
    .koddi(type: .bold, size: 20)
  }

  static var KoddiRegular16: Font {
    .koddi(type: .regular, size: 16)
  }

  static var KoddiBold14: Font {
    .koddi(type: .bold, size: 14)
  }
}

//
//  FlowLayout.swift
//  today-s-sound
//
//  여러 배지를 자동으로 줄바꿈해 배치해주는 레이아웃
//

import SwiftUI

/// 여러 배지를 자동으로 줄바꿈해 배치해주는 레이아웃
struct FlowLayout: Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let maxWidth = proposal.replacingUnspecifiedDimensions().width
    let result = FlowResult(in: maxWidth, subviews: subviews, spacing: spacing)
    return result.size
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
    for (index, subview) in subviews.enumerated() {
      subview.place(
        at: CGPoint(
          x: bounds.minX + result.positions[index].x,
          y: bounds.minY + result.positions[index].y
        ),
        proposal: .unspecified
      )
    }
  }

  struct FlowResult {
    var size: CGSize = .zero
    var positions: [CGPoint] = []

    init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
      var currentX: CGFloat = 0
      var currentY: CGFloat = 0
      var lineHeight: CGFloat = 0

      for subview in subviews {
        let size = subview.sizeThatFits(.unspecified)

        if currentX + size.width > maxWidth, currentX > 0 {
          currentX = 0
          currentY += lineHeight + spacing
          lineHeight = 0
        }

        positions.append(CGPoint(x: currentX, y: currentY))
        lineHeight = max(lineHeight, size.height)
        currentX += size.width + spacing
      }

      size = CGSize(width: maxWidth, height: currentY + lineHeight)
    }
  }
}

import SwiftUI

public struct HSKBadge: View {
    public let level: HSKLevel
    public var style: BadgeStyle = .standard
    
    public enum BadgeStyle {
        case compact
        case standard
        case prominent
    }
    
    public init(level: HSKLevel, style: BadgeStyle = .standard) {
        self.level = level
        self.style = style
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(hex: level.badgeColorHex))
                .frame(width: dotSize, height: dotSize)
            
            Text(level.rawValue)
                .font(font)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: level.badgeColorHex))
            
            if style == .prominent {
                Text("• \(level.proficiencyTier)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(Color(hex: level.badgeColorHex).opacity(0.15))
        .clipShape(Capsule())
    }
    
    private var dotSize: CGFloat {
        switch style {
        case .compact: return 5
        case .standard: return 7
        case .prominent: return 9
        }
    }
    
    private var font: Font {
        switch style {
        case .compact: return .caption2
        case .standard: return .caption
        case .prominent: return .subheadline
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch style {
        case .compact: return 6
        case .standard: return 10
        case .prominent: return 12
        }
    }
    
    private var verticalPadding: CGFloat {
        switch style {
        case .compact: return 2
        case .standard: return 4
        case .prominent: return 6
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

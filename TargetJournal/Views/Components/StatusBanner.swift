import SwiftUI

public struct StatusBanner: View {
    public let icon: String
    public let title: String
    public let message: String
    public let color: Color
    
    public init(icon: String = "info.circle.fill", title: String, message: String, color: Color = .blue) {
        self.icon = icon
        self.title = title
        self.message = message
        self.color = color
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

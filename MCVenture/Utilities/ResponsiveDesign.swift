//
//  ResponsiveDesign.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI
import UIKit

// MARK: - Screen Size Helper
struct ScreenSize {
    static var width: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        UIScreen.main.bounds.height
    }
    
    static var safeAreaInsets: UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets
        }
        return .zero
    }
    
    // Device types based on screen dimensions
    static var deviceType: DeviceType {
        let height = UIScreen.main.bounds.height
        
        switch height {
        case 667: return .iPhone8 // iPhone SE 3rd gen, iPhone 8
        case 736: return .iPhone8Plus
        case 812: return .iPhoneX // iPhone X, XS, 11 Pro, 12 mini, 13 mini
        case 844: return .iPhone12 // iPhone 12, 12 Pro, 13, 13 Pro, 14
        case 852: return .iPhone14Pro // iPhone 14 Pro, 15, 15 Pro
        case 896: return .iPhone11 // iPhone XR, XS Max, 11, 11 Pro Max
        case 926: return .iPhone12ProMax // iPhone 12 Pro Max, 13 Pro Max, 14 Plus
        case 932: return .iPhone14ProMax // iPhone 14 Pro Max, 15 Plus, 15 Pro Max
        case 956: return .iPhone16ProMax // iPhone 16 Pro Max
        default: return .standard
        }
    }
    
    enum DeviceType {
        case iPhone8
        case iPhone8Plus
        case iPhoneX
        case iPhone11
        case iPhone12
        case iPhone12ProMax
        case iPhone14Pro
        case iPhone14ProMax
        case iPhone16ProMax
        case standard
        
        var hasNotch: Bool {
            switch self {
            case .iPhone8, .iPhone8Plus:
                return false
            default:
                return true
            }
        }
    }
}

// MARK: - Responsive Sizing Extensions
extension CGFloat {
    /// Scales value based on screen width (375pt is the base - iPhone X/11/12 mini width)
    var scaled: CGFloat {
        let baseWidth: CGFloat = 375.0
        let screenWidth = ScreenSize.width
        return self * (screenWidth / baseWidth)
    }
    
    /// Scales value based on screen height (812pt is the base - iPhone X height)
    var scaledHeight: CGFloat {
        let baseHeight: CGFloat = 812.0
        let screenHeight = ScreenSize.height
        return self * (screenHeight / baseHeight)
    }
}

extension Double {
    var scaled: Double {
        CGFloat(self).scaled
    }
    
    var scaledHeight: Double {
        CGFloat(self).scaledHeight
    }
}

extension Int {
    var scaled: CGFloat {
        CGFloat(self).scaled
    }
    
    var scaledHeight: CGFloat {
        CGFloat(self).scaledHeight
    }
}

// MARK: - Responsive Font Sizes
extension Font {
    static func scaled(_ size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        return .system(size: size.scaled, weight: weight, design: design)
    }
    
    static func scaledTitle() -> Font {
        return .system(size: 34.scaled, weight: .bold)
    }
    
    static func scaledLargeTitle() -> Font {
        return .system(size: 40.scaled, weight: .bold)
    }
    
    static func scaledHeadline() -> Font {
        return .system(size: 17.scaled, weight: .semibold)
    }
    
    static func scaledBody() -> Font {
        return .system(size: 17.scaled, weight: .regular)
    }
    
    static func scaledCaption() -> Font {
        return .system(size: 12.scaled, weight: .regular)
    }
}

// MARK: - Responsive Padding
extension View {
    func responsivePadding(_ edges: Edge.Set = .all, _ length: CGFloat = 16) -> some View {
        self.padding(edges, length.scaled)
    }
    
    func responsiveFrame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        self.frame(
            width: width?.scaled,
            height: height?.scaledHeight,
            alignment: alignment
        )
    }
    
    func responsiveCornerRadius(_ radius: CGFloat) -> some View {
        self.cornerRadius(radius.scaled)
    }
}

// MARK: - Safe Area Helper
extension View {
    func safeAreaPadding(_ edges: Edge.Set = .all) -> some View {
        let insets = ScreenSize.safeAreaInsets
        return self.padding(.top, edges.contains(.top) ? insets.top : 0)
            .padding(.bottom, edges.contains(.bottom) ? insets.bottom : 0)
            .padding(.leading, edges.contains(.leading) ? insets.left : 0)
            .padding(.trailing, edges.contains(.trailing) ? insets.right : 0)
    }
}

// MARK: - Responsive Spacing
struct ResponsiveSpacing {
    static let tiny: CGFloat = 4.scaled
    static let small: CGFloat = 8.scaled
    static let medium: CGFloat = 16.scaled
    static let large: CGFloat = 24.scaled
    static let extraLarge: CGFloat = 32.scaled
}

// MARK: - Responsive Icon Sizes
struct ResponsiveIconSize {
    static let small: CGFloat = 16.scaled
    static let medium: CGFloat = 24.scaled
    static let large: CGFloat = 32.scaled
    static let extraLarge: CGFloat = 48.scaled
}

// MARK: - Responsive Button Heights
struct ResponsiveButtonHeight {
    static let small: CGFloat = 36.scaledHeight
    static let medium: CGFloat = 44.scaledHeight
    static let large: CGFloat = 56.scaledHeight
}

// MARK: - Device-Specific Adjustments
extension View {
    @ViewBuilder
    func adaptForSmallScreens() -> some View {
        if ScreenSize.height <= 667 {
            // iPhone SE, iPhone 8 and smaller
            self.scaleEffect(0.9)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func hideOnSmallScreens() -> some View {
        if ScreenSize.height > 667 {
            self
        } else {
            EmptyView()
        }
    }
}

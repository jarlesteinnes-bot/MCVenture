//
//  StarRatingView.swift
//  MCVenture
//
//  Interactive star rating component
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    let maximumRating: Int = 5
    let interactive: Bool
    let size: CGFloat
    
    init(rating: Binding<Int>, interactive: Bool = false, size: CGFloat = 20) {
        self._rating = rating
        self.interactive = interactive
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maximumRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundColor(index <= rating ? .orange : .gray)
                    .font(.system(size: size))
                    .onTapGesture {
                        if interactive {
                            HapticManager.shared.selection()
                            rating = index
                        }
                    }
            }
        }
    }
}

struct StaticStarRatingView: View {
    let rating: Double
    let size: CGFloat
    let showNumber: Bool
    
    init(rating: Double, size: CGFloat = 16, showNumber: Bool = true) {
        self.rating = rating
        self.size = size
        self.showNumber = showNumber
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: starType(for: index))
                    .foregroundColor(.orange)
                    .font(.system(size: size))
            }
            
            if showNumber {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: size))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func starType(for index: Int) -> String {
        let position = Double(index) + 1
        if rating >= position {
            return "star.fill"
        } else if rating >= position - 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// Rating distribution bar chart
struct RatingDistributionView: View {
    let stats: RouteRatingStats
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach((1...5).reversed(), id: \.self) { stars in
                HStack(spacing: 8) {
                    Text("\(stars)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 15)
                    
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: geometry.size.width * CGFloat(stats.getStarPercentage(stars) / 100.0), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(Int(stats.getStarPercentage(stars)))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 35, alignment: .trailing)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StarRatingView(rating: .constant(3), interactive: true, size: 24)
        StaticStarRatingView(rating: 4.5, size: 20)
        StaticStarRatingView(rating: 3.2, size: 16)
    }
    .padding()
}

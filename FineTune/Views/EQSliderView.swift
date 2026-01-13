// FineTune/Views/EQSliderView.swift
import SwiftUI

struct EQSliderView: View {
    let frequency: String
    @Binding var gain: Float
    let range: ClosedRange<Float> = -12...12

    // Local state for smooth visual updates
    @State private var localGain: Float = 0

    private let trackWidth: CGFloat = 4
    private let thumbSize: CGFloat = 14
    private let tickCount = 5  // Number of tick marks (fewer = cleaner)
    private let tickWidth: CGFloat = 3
    private let tickGap: CGFloat = 3  // Gap between tick and track
    private let verticalPadding: CGFloat = 8  // Margin at top/bottom for thumb travel

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                // Thumb travels within padded range
                let travelHeight = geo.size.height - (verticalPadding * 2)
                let normalizedGain = CGFloat((localGain - range.lowerBound) / (range.upperBound - range.lowerBound))
                let thumbY = verticalPadding + travelHeight * (1 - normalizedGain)

                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // Map touch to padded range
                                let normalizedY = (value.location.y - verticalPadding) / travelHeight
                                let normalized = 1 - normalizedY
                                let clamped = min(max(normalized, 0), 1)
                                let newGain = Float(clamped) * (range.upperBound - range.lowerBound) + range.lowerBound
                                localGain = newGain
                                gain = newGain
                            }
                    )
                    .overlay {
                        // All visuals - no hit testing
                        ZStack {
                            // Tick marks on LEFT side
                            VStack(spacing: 0) {
                                ForEach(0..<tickCount, id: \.self) { index in
                                    if index > 0 { Spacer() }
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.25))
                                        .frame(width: tickWidth, height: 1)
                                }
                            }
                            .frame(height: travelHeight)
                            .offset(x: -(trackWidth / 2 + tickGap + tickWidth / 2))

                            // Tick marks on RIGHT side
                            VStack(spacing: 0) {
                                ForEach(0..<tickCount, id: \.self) { index in
                                    if index > 0 { Spacer() }
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.25))
                                        .frame(width: tickWidth, height: 1)
                                }
                            }
                            .frame(height: travelHeight)
                            .offset(x: trackWidth / 2 + tickGap + tickWidth / 2)

                            // Track (full height)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: trackWidth)

                            // Center line (0 dB marker) - spans across ticks
                            Rectangle()
                                .fill(Color.secondary.opacity(0.4))
                                .frame(width: trackWidth + (tickGap + tickWidth) * 2, height: 1)

                            // Thumb
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: thumbSize, height: thumbSize)
                                Circle()
                                    .fill(Color(white: 0.15))
                                    .frame(width: 5, height: 5)
                            }
                            .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
                            .position(x: geo.size.width / 2, y: thumbY)
                        }
                        .allowsHitTesting(false)
                    }
            }

            Text(frequency)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
        }
        .onAppear {
            localGain = gain  // Initialize from binding
        }
        .onChange(of: gain) { _, newValue in
            localGain = newValue  // Sync from external changes
        }
    }
}

#Preview {
    HStack(spacing: 8) {
        EQSliderView(frequency: "31", gain: .constant(6))
        EQSliderView(frequency: "1k", gain: .constant(0))
        EQSliderView(frequency: "16k", gain: .constant(-6))
    }
    .frame(width: 120, height: 120)
    .padding()
    .background(Color.black)
}

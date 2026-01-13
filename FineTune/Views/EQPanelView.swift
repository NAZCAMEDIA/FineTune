// FineTune/Views/EQPanelView.swift
import SwiftUI

struct EQPanelView: View {
    @Binding var settings: EQSettings
    let onPresetSelected: (EQPreset) -> Void
    let onSettingsChanged: (EQSettings) -> Void

    private let frequencyLabels = ["31", "62", "125", "250", "500", "1k", "2k", "4k", "8k", "16k"]

    private var currentPreset: EQPreset? {
        EQPreset.allCases.first { preset in
            preset.settings.bandGains == settings.bandGains
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            // Header: Toggle left, Preset right
            HStack {
                // EQ toggle on left
                HStack(spacing: 4) {
                    Toggle("", isOn: $settings.isEnabled)
                        .toggleStyle(.switch)
                        .scaleEffect(0.65)
                        .labelsHidden()
                        .onChange(of: settings.isEnabled) { _, _ in
                            onSettingsChanged(settings)
                        }
                    Text("EQ")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Preset picker on right
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text("Preset")
                        .font(DesignTokens.Typography.pickerText)
                        .foregroundColor(DesignTokens.Colors.textSecondary)

                    EQPresetPicker(
                        selectedPreset: currentPreset,
                        onPresetSelected: onPresetSelected
                    )
                }
            }
            .zIndex(1)  // Ensure dropdown renders above sliders

            // 10-band sliders - taller with more spacing
            HStack(spacing: 22) {
                ForEach(0..<10, id: \.self) { index in
                    EQSliderView(
                        frequency: frequencyLabels[index],
                        gain: Binding(
                            get: { settings.bandGains[index] },
                            set: { newValue in
                                settings.bandGains[index] = newValue
                                onSettingsChanged(settings)
                            }
                        )
                    )
                    .frame(width: 26, height: 100)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.5))
        )
    }
}

#Preview {
    EQPanelView(
        settings: .constant(EQSettings()),
        onPresetSelected: { _ in },
        onSettingsChanged: { _ in }
    )
    .frame(width: 320)
    .padding()
    .background(Color.black)
}

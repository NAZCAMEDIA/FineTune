// FineTune/Views/Components/EQPresetPicker.swift
import SwiftUI

struct EQPresetPicker: View {
    let selectedPreset: EQPreset?
    let onPresetSelected: (EQPreset) -> Void

    var body: some View {
        DropdownMenu(
            items: Array(EQPreset.allCases),
            selectedItem: selectedPreset,
            maxVisibleItems: 8,
            width: 100,
            popoverWidth: 140,
            onSelect: onPresetSelected
        ) { selected in
            Text(selected?.name ?? "Custom")
        } itemContent: { preset, isSelected in
            HStack {
                Text(preset.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

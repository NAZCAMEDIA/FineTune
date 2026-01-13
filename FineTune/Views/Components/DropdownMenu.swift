// FineTune/Views/Components/DropdownMenu.swift
import SwiftUI

/// A reusable dropdown menu component with height restriction support
struct DropdownMenu<Item: Identifiable, Label: View, ItemContent: View>: View where Item.ID: Hashable {
    let items: [Item]
    let selectedItem: Item?
    let maxVisibleItems: Int?
    let width: CGFloat
    let popoverWidth: CGFloat?
    let onSelect: (Item) -> Void
    @ViewBuilder let label: (Item?) -> Label
    @ViewBuilder let itemContent: (Item, Bool) -> ItemContent

    @State private var isExpanded = false
    @State private var isButtonHovered = false

    // Configuration
    private let itemHeight: CGFloat = 20
    private let cornerRadius: CGFloat = 8
    private let animationDuration: Double = 0.15

    private var effectivePopoverWidth: CGFloat {
        popoverWidth ?? width
    }

    private var menuHeight: CGFloat {
        let itemCount = CGFloat(items.count)
        if let max = maxVisibleItems {
            return min(itemCount, CGFloat(max)) * itemHeight + 10
        }
        return itemCount * itemHeight + 10
    }

    // MARK: - Trigger Button
    private var triggerButton: some View {
        Button {
            withAnimation(.snappy(duration: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                label(selectedItem)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)

                Spacer(minLength: 4)

                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isExpanded ? -180 : 0))
                    .animation(.easeInOut(duration: 0.25), value: isExpanded)
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 4)
            .frame(width: width)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius)
                .fill(isButtonHovered ? Color(red: 0.26, green: 0.27, blue: 0.29) : Color(red: 0.212, green: 0.224, blue: 0.235))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius)
                .stroke(Color.white.opacity(0.10), lineWidth: 0.5)
        )
        .onHover { isButtonHovered = $0 }
        .animation(DesignTokens.Animation.hover, value: isButtonHovered)
    }

    // MARK: - Body
    var body: some View {
        triggerButton
            .background(
                PopoverHost(isPresented: $isExpanded) {
                    DropdownContentView(
                        items: items,
                        selectedItem: selectedItem,
                        width: effectivePopoverWidth,
                        menuHeight: menuHeight,
                        itemHeight: itemHeight,
                        cornerRadius: cornerRadius,
                        onSelect: { item in
                            onSelect(item)
                            withAnimation(.easeOut(duration: animationDuration)) {
                                isExpanded = false
                            }
                        },
                        itemContent: itemContent
                    )
                }
            )
    }
}

// MARK: - Dropdown Content View

private struct DropdownContentView<Item: Identifiable, ItemContent: View>: View where Item.ID: Hashable {
    let items: [Item]
    let selectedItem: Item?
    let width: CGFloat
    let menuHeight: CGFloat
    let itemHeight: CGFloat
    let cornerRadius: CGFloat
    let onSelect: (Item) -> Void
    @ViewBuilder let itemContent: (Item, Bool) -> ItemContent

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 1) {
                ForEach(items) { item in
                    DropdownMenuItem(
                        item: item,
                        isSelected: selectedItem?.id == item.id,
                        itemHeight: itemHeight,
                        onSelect: onSelect,
                        itemContent: itemContent
                    )
                    .id(item.id)
                }
            }
            .padding(5)
            .scrollTargetLayout()
        }
        .scrollPosition(id: .constant(selectedItem?.id), anchor: .center)
        .frame(width: width, height: menuHeight)
        .background(
            VisualEffectBackground(material: .menu, blendingMode: .behindWindow)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.primary.opacity(0.15), lineWidth: 0.5)
        )
    }
}

// MARK: - Dropdown Menu Item (with hover tracking)

private struct DropdownMenuItem<Item: Identifiable, ItemContent: View>: View where Item.ID: Hashable {
    let item: Item
    let isSelected: Bool
    let itemHeight: CGFloat
    let onSelect: (Item) -> Void
    @ViewBuilder let itemContent: (Item, Bool) -> ItemContent

    @State private var isHovered = false

    var body: some View {
        Button {
            onSelect(item)
        } label: {
            itemContent(item, isSelected)
                .font(.system(size: 11))
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .frame(height: itemHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isHovered ? Color.accentColor.opacity(0.15) : Color.clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .whenHovered { isHovered = $0 }
    }
}

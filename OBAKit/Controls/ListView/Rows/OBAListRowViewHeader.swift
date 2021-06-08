//
//  OBAListRowViewHeader.swift
//  OBAKit
//
//  Created by Alan Chu on 10/4/20.
//

import OBAKitCore

/// A header view that visually separates sections in `OBAListView`.
/// To include collapsible sections support, the `section` model you assign has to implement
/// collapsible sections.
public class OBAListRowViewHeader: OBAListRowView {
    static let ReuseIdentifier = "OBAListRowViewHeader_ReuseIdentifier"

    public var section: OBAListViewSection? {
        didSet {
            guard let section = section else { return }

            if let collapseState = section.collapseState {
                let image: UIImage

                switch collapseState {
                case .collapsed:    image = UIImage(systemName: "chevron.right.circle.fill")!
                case .expanded:     image = UIImage(systemName: "chevron.down.circle.fill")!
                }

                self.configuration = OBAListRowConfiguration(image: image, text: .string(section.title), appearance: .header)
            } else {
                self.configuration = OBAListRowConfiguration(text: .string(section.title), appearance: .header)
            }
        }
    }

    let titleLabel: UILabel = .obaLabel(font: .preferredFont(forTextStyle: .headline))

    override func makeUserView() -> UIView {
        // wrap in stack view to fix layout spacing
        return UIStackView.stack(distribution: .equalSpacing, arrangedSubviews: [titleLabel])
    }

    override func configureView() {
        super.configureView()
        self.backgroundColor = UIColor.secondarySystemBackground

        titleLabel.setText(configuration.text)

        isAccessibilityElement = true
        accessibilityTraits = .header
        if case let .string(string) = configuration.text {
            accessibilityLabel = string
        } else {
            accessibilityLabel = nil
        }

        self.layoutIfNeeded()
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI
import OBAKitCore

struct OBAListRowViewHeader_Previews: PreviewProvider {
    static let configuration = OBAListRowConfiguration(
        image: UIImage(systemName: "person.circle.fill"),
        text: .string("Privacy Settings"),
        appearance: .header,
        accessoryType: .none)

    static var previews: some View {
        Group {
            UIViewPreview {
                let view = OBAListRowViewHeader(frame: .zero)
                view.configuration = configuration
                return view
            }
            .previewLayout(.fixed(width: 384, height: 44))

            UIViewPreview {
                let view = OBAListRowViewHeader(frame: .zero)
                view.configuration = configuration
                return view
            }
            .environment(\.sizeCategory, .accessibilityLarge)
            .previewLayout(.sizeThatFits)

            UIViewPreview {
                let view = OBAListRowViewHeader(frame: .zero)
                view.configuration = configuration
                return view
            }
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
            .previewLayout(.sizeThatFits)
        }
    }
}

#endif

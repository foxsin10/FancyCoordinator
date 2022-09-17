import UIKit

import SwiftUI

final class ExcampleController: UIViewController {
    let identifier: String
    var onNavigation: () -> Void

    init(identifier: String, onNavigation: @escaping () -> Void = {}) {
        self.identifier = identifier
        self.onNavigation = onNavigation
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let host = UIHostingController(rootView: IdentifyView(identifier: identifier, onNavigation: onNavigation))
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        host.view.backgroundColor = .clear

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

struct IdentifyView: View {
    let identifier: String
    let onNavigation: () -> Void

    var body: some View {
        VStack {
            Text(identifier)
                .font(.body)
                .foregroundColor(.blue)

            Button("tap me") {
                onNavigation()
            }

            Spacer()
        }
    }
}

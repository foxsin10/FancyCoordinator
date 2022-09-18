//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by yzj on 2022/9/17.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()

    var body: some View {
        vm.coordinator
            .buildView(for: vm.route, withContext: ())
            .border(Color.red, width: 2)
            .onTapGesture {
                withAnimation {
                    switch vm.route {
                    case .home(.root): vm.route = .home(.fun)
                    case .home(.fun): vm.route = .me(.root)
                    case .me(.root): vm.route = .me(.profile)
                    case .me(.profile): vm.route = .home(.root)
                    }
                }
            }
    }

    final class ViewModel: ObservableObject {
        let coordinator = Root()

        @Published
        var route = Root.Route.home(.root)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

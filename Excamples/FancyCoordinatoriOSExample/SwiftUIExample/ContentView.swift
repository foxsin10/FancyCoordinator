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
        if let view = vm.coordinator.coordinate(to: vm.route) {
            view
                .border(Color.red, width: 2)
                .onTapGesture {
                    vm.route = .home(.fun)
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

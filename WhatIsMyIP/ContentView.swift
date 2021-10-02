//
//  ContentView.swift
//  WhatIsMyIP
//
//  Created by Stefan Arentz on 02/10/2021.
//

import SwiftUI

struct Address {
    let address: String
}

extension Address {
  static let empty = Address(address: "-")
}

@MainActor
class AddressServiceViewModel: ObservableObject {
    @Published var address = Address.empty
    @Published var isLoading = false
    
    func refresh() async {
        isLoading = true
        await Task.sleep(1_500_000_000) // Artificial delay otherwise things load too fast
        address = await fetch()
        isLoading = false
    }
    
    private func fetch() async -> Address {
        let request = URLRequest(url: URL(string: "https://api.ipify.org")!)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            // Error handling and response status checking omitted for simplicity
            return Address(address: String(data: data, encoding: .utf8)!)
        } catch {
            return Address.empty
        }
    }
}

struct AddressView: View {
    let address: String
    var body: some View {
        Text(address)
            .font(.headline)
            .bold()
    }
}

struct ContentView: View {
    @StateObject var viewModel = AddressServiceViewModel()

    var body: some View {
        ZStack {
          if viewModel.isLoading {
            ProgressView("Fetching...")
          } else {
              VStack(alignment: .center, spacing: 20) {
                  AddressView(address: viewModel.address.address).padding()
                  Button("Refresh") {
                      Task {
                          await viewModel.refresh()
                      }
                  }
              }
          }
        }
        .task {
            await viewModel.refresh()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

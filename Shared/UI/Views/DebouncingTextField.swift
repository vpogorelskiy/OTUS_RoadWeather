import Foundation
import SwiftUI
import Combine

struct DebouncingTextField: View {
    let title: String
    
    
    @Binding var debouncedText : String
    @StateObject private var vm = ViewModel()
    
    var body: some View {
        VStack {
            TextField(title, text: $vm.searchText)
                .frame(height: 30)
                .padding(.leading, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black, lineWidth: 1)
                )
                .background(.white)
                .padding(.horizontal, 20)
        }.onReceive(vm.$debouncedText) { (val) in
            debouncedText = val
        }
    }
}

private extension DebouncingTextField {
    class ViewModel : ObservableObject {
        @Published var debouncedText = ""
        @Published var searchText = ""
        
        private let debounceInterval = 1
        private var subscriptions = Set<AnyCancellable>()
        
        init() {
            $searchText
                .debounce(for: .seconds(debounceInterval), scheduler: DispatchQueue.main)
                .sink(receiveValue: { [weak self] t in
                    self?.debouncedText = t
                } )
                .store(in: &subscriptions)
        }
    }
}



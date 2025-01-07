//
//  submitViewModel.swift
//  fdci_assessment
//
//  Created by Jonrel Baclayon on 1/7/25.
//

import Combine
import Foundation

class SubmitViewModel: ObservableObject {
    
    enum ViewState {
        case valid
        case invalid
        case none
    }
    
    @Published var name = ""
    @Published var country = ""
    @Published var regionState = ""
    @Published var nameTextState: ViewState = .none
    @Published var countryTextState: ViewState = .none
    @Published var regionStateTextState: ViewState = .none
    
    private var cancellables = Set<AnyCancellable>()
    @Published var isInputValid = false
    
    var isValidNamePublisher: AnyPublisher<Bool, Never> {
        $name
            .map { $0.isValidName }
            .eraseToAnyPublisher()
    }

    var isValidStatePublisher: AnyPublisher<Bool, Never> {
        $regionState
            .map { !$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    var isValidCountryPublisher: AnyPublisher<Bool, Never> {
        $country
            .map { !$0.isEmpty}
            .eraseToAnyPublisher()
    }
}

extension String {
    var isValidName: Bool {
        return NSPredicate(
            format: "SELF MATCHES %@", "^[a-zA-Z ]*$"
        )
        .evaluate(with: self)
    }
}

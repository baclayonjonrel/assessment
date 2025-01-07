//
//  CountryViewModel.swift
//  fdci_assessment
//
//  Created by Jonrel Baclayon on 1/7/25.
//

import Combine
import Foundation
import Alamofire

class CountryViewModel: ObservableObject {
    
    enum ViewState {
        case loading
        case success
        case failed(Error)
        case none
    }
    
    @Published var countries: [Country]?
    @Published var region: [String]?
    @Published var state: ViewState = .none
    
    private var retries = 0
    private let maxRetries = 3
    
    func searchCountries(by name: String, in region: String?) -> [String] {
        guard let countries = countries else { return [] }
        
        let filteredCountries = countries.filter {
            ($0.region == region || region == nil) &&
            $0.name.common.localizedCaseInsensitiveContains(name)
        }
        
        return Array(filteredCountries.map { $0.name.common }.prefix(3))
    }
    
    func fetchCountries() {
        state = .loading
        
        let url = "https://restcountries.com/v3.1/all"
        
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: [Country].self) { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success(let countries):
                    self.retries = 0
                    self.countries = countries
                    self.state = .success
                    self.region = Set(countries.map(\.region)).sorted()
                    print("regions: \(region)")
                case .failure(let error):
                    print(error)
                    if self.retries < self.maxRetries {
                        self.retries += 1
                        print("Retrying (\(self.retries)/\(self.maxRetries))...")
                        self.fetchCountries()
                    } else {
                        self.state = .failed(error)
                        print("Failed after \(self.retries) retries: \(error.localizedDescription)")
                    }
                }
            }
    }
}


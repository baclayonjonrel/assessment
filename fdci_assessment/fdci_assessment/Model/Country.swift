//
//  Country.swift
//  fdci_assessment
//
//  Created by Jonrel Baclayon on 1/7/25.
//

import Foundation

struct Country: Codable {
    let name: Name
    let capital: [String]?
    let region: String
    let flags: Flags
    let population: Int?
    let area: Double?
    let latlng: [Double]?
}

struct Name: Codable {
    let common: String
    let official: String
}

struct Flags: Codable {
    let png: String?
    let svg: String?
}

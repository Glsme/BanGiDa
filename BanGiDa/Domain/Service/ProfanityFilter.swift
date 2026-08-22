//
//  ProfanityFilter.swift
//  BanGiDa
//

public protocol ProfanityFilter {
    func containsProhibitedWord(_ text: String) -> Bool
}

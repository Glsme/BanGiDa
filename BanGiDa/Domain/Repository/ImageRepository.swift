//
//  ImageRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol ImageRepository {
    func loadImageData(fileName: String) -> Data?
    func saveImageData(fileName: String, data: Data)
    func removeImage(fileName: String)
}

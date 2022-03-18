//
//  Player.swift
//  Chess
//
//  Created by Privat on 18.03.22.
//

import Foundation

enum Player {
    case black
    case white
    
    var imageSuffix: String {
        switch self {
        case .black:
            return "_b"
        case .white:
            return "_w"
        }
    }
}

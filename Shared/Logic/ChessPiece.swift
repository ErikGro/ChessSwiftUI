//
//  ChessPiece.swift
//  Chess
//
//  Created by Privat on 18.03.22.
//

import SwiftUI

enum ChessPiece: Hashable {
    case pawn(_ player: Player, _  wasMoved: Bool = false)
    case knight(_ player: Player)
    case bishop(_ player: Player)
    case rook(_ player: Player)
    case king(_ player: Player)
    case queen(_ player: Player)
    
    var player: Player {
        switch self {
        case .pawn(let player, _):
            return player
        case .knight(let player):
            return player
        case .bishop(let player):
            return player
        case .rook(let player):
            return player
        case .king(let player):
            return player
        case .queen(let player):
            return player
        }
    }
    
    var image: Image {
        switch self {
        case .pawn(let color, _):
            return Image("pawn\(color.imageSuffix)")
        case .knight(let color):
            return Image("knight\(color.imageSuffix)")
        case .bishop(let color):
            return Image("bishop\(color.imageSuffix)")
        case .rook(let color):
            return Image("rook\(color.imageSuffix)")
        case .king(let color):
            return Image("king\(color.imageSuffix)")
        case .queen(let color):
            return Image("queen\(color.imageSuffix)")
        }
    }
}

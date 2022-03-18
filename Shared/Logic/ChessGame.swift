//
//  ChessGame.swift
//  Chess
//
//  Created by Privat on 18.03.22.
//

import Foundation
import Combine

struct Coord: Equatable {
    let row: Int
    let column: Int
    
    init?(_ row: Int, _ column: Int) {
        guard row >= 0 && row < 8 && column >= 0 && column < 8 else { return nil }
        
        self.row = row
        self.column = column
    }
    
    func offsetBy(row: Int, column: Int, for player: Player) -> Coord? {
        switch player {
        case .black:
            return Coord(self.row + row * -1, self.column + column)
        case .white:
            return Coord(self.row + row, self.column + column)
        }
    }
}

struct ChessGame {
    private(set) var chessBoard: [[ChessPiece?]] = []
    
    private(set) var turn = 0
    
    var currentPlayer: Player {
        turn % 2 == 0 ? .white : .black
    }
    
    var winner: Player? {
        let blackKing = chessBoard.reduce([], +).compactMap { $0 }.first { .king(.black) == $0 }
        let whiteKing = chessBoard.reduce([], +).compactMap { $0 }.first { .king(.white) == $0 }
        
        if blackKing == nil {
            return .white
        } else if whiteKing == nil {
            return .black
        }
        
        // TODO: Check if king is check
        
        return nil
    }
    
    init() {
        initGame()
    }
    
    mutating func initGame() {
        turn = 0
        initChessBoard()
    }
    
    private mutating func initChessBoard() {
        chessBoard = [
            [.rook(.black), .knight(.black), .bishop(.black), .queen(.black), .king(.black), .bishop(.black), .knight(.black), .rook(.black)],
            Array(repeating: .pawn(.black), count: 8),
            Array(repeating: nil, count: 8),
            Array(repeating: nil, count: 8),
            Array(repeating: nil, count: 8),
            Array(repeating: nil, count: 8),
            Array(repeating: .pawn(.white), count: 8),
            [.rook(.white), .knight(.white), .bishop(.white), .queen(.white), .king(.white), .bishop(.white), .knight(.white), .rook(.white)]
        ]
    }

    /// Only use for valid moves. I.e.: You cannot move from an empty field or from/to outside the board.
    mutating func move(from: Coord, to: Coord) {
        precondition(chessBoard[from.row][from.column] != nil, "From coordinate must not be nil!")

        chessBoard[to.row][to.column] = chessBoard[from.row][from.column]
        turn += 1
        
        if let player = winner {
            // Game over
            print("\(player) won.")
        }
    }
    
    func possibleMoves(from coord: Coord) -> [Coord] {
        guard
            let piece = chessBoard[coord.row][coord.column],
            piece.player == currentPlayer
        else {
            return []
        }
     
        switch piece {
        case .pawn(let player, let wasMoved):
            return possiblePawnMoves(from: coord, for: player, wasMoved: wasMoved)
        case .knight(let player):
            return possibleKnightMoves(from: coord, for: player)
        case .bishop(let player):
            return possibleBishopMoves(from: coord, for: player)
        case .rook(let player):
            return possibleRookMoves(from: coord, for: player)
        case .king(let player):
            return possibleKingMoves(from: coord, for: player)
        case .queen(let player):
            return possibleQueenMoves(from: coord, for: player)
        }
    }
    
    // MARK: - Functions calculating possible moves for each piece type
    
    private func possiblePawnMoves(from coord: Coord, for player: Player, wasMoved: Bool) -> [Coord] {
        var possibleMoves = [Coord]()
        
        // Calculate possible coordinates
        let oneFieldStep = coord.offsetBy(row: -1, column: 0, for: player)
        let twoFieldStep = coord.offsetBy(row: -2, column: 0, for: player)
        let hitLeft = coord.offsetBy(row: -1, column: -1, for: player)
        let hitRight = coord.offsetBy(row: -1, column: 1, for: player)
        
        if let oneFieldStep = oneFieldStep,
           piece(at: oneFieldStep) == nil {
            possibleMoves.append(oneFieldStep)
        }
        
        if  let oneFieldStep = oneFieldStep,
            let twoFieldStep = twoFieldStep,
            !wasMoved && piece(at: oneFieldStep) == nil && piece(at: twoFieldStep) == nil {
            possibleMoves.append(twoFieldStep)
        }
        
        if let hitLeft = hitLeft,
           let targetPiece = piece(at: hitLeft),
           targetPiece.player != currentPlayer {
            possibleMoves.append(hitLeft)
        }
        
        if let hitRight = hitRight,
           let targetPiece = piece(at: hitRight),
           targetPiece.player != currentPlayer  {
            possibleMoves.append(hitRight)
        }
        
        // TODO: En passant
        
        return possibleMoves
    }
    
    private func possibleKnightMoves(from coord: Coord, for player: Player) -> [Coord] {
        var possibleMoves = [Coord?]()
        
        // Calculate possible coordinates
        possibleMoves.append(coord.offsetBy(row: -2, column: 1, for: player))
        possibleMoves.append(coord.offsetBy(row: -1, column: 2, for: player))
        possibleMoves.append(coord.offsetBy(row: 1, column: 2, for: player))
        possibleMoves.append(coord.offsetBy(row: 2, column: 1, for: player))
        possibleMoves.append(coord.offsetBy(row: 2, column: -1, for: player))
        possibleMoves.append(coord.offsetBy(row: 1, column: -2, for: player))
        possibleMoves.append(coord.offsetBy(row: -1, column: -2, for: player))
        possibleMoves.append(coord.offsetBy(row: -2, column: -1, for: player))
        
        return possibleMoves
            .compactMap {$0}
            .filter { chessBoard[$0.row][$0.column]?.player != currentPlayer }
    }
    
    private func possibleBishopMoves(from coord: Coord, for player: Player) -> [Coord] {
        var possibleMoves = [Coord]()
        
        for row in [-1, 1] {
            for column in [-1, 1] {
                
                var rowOffset = 1
                var columnOffset = 1
                while let validCoord = coord.offsetBy(row: row * rowOffset, column: column * columnOffset, for: player) {
                    if let piece = piece(at: validCoord) { // Found piece -> Cannot go further
                        if piece.player != currentPlayer {
                            possibleMoves.append(validCoord)
                        }
                        break
                    } else {
                        possibleMoves.append(validCoord)
                        rowOffset += 1
                        columnOffset += 1
                    }
                }
                
            }
        }
        
        return possibleMoves
    }
    
    private func possibleRookMoves(from coord: Coord, for player: Player) -> [Coord] {
        var possibleMoves = [Coord]()
        
        // TODO: Simplify
        
        for row in [-1, 1] {
            var rowOffset = 1
            while let validCoord = coord.offsetBy(row: row * rowOffset, column: 0, for: player) {
                if let piece = piece(at: validCoord) { // Found piece -> Cannot go further
                    if piece.player != currentPlayer {
                        possibleMoves.append(validCoord)
                    }
                    break
                } else {
                    possibleMoves.append(validCoord)
                    rowOffset += 1
                }
            }
        }
        
        for column in [-1, 1] {
            var columnOffset = 1
            while let validCoord = coord.offsetBy(row: 0, column: column * columnOffset, for: player) {
                if let piece = piece(at: validCoord) { // Found piece -> Cannot go further
                    if piece.player != currentPlayer {
                        possibleMoves.append(validCoord)
                    }
                    break
                } else {
                    possibleMoves.append(validCoord)
                    columnOffset += 1
                }
            }
        }
        
        return possibleMoves
    }
    
    private func possibleKingMoves(from coord: Coord, for player: Player) -> [Coord] {
        var possibleMoves = [Coord]()
        
        for row in [-1, 0, 1] {
            for column in [-1, 0, 1] {
                if let validCoord = coord.offsetBy(row: row, column: column, for: player) {
                    if let piece = piece(at: validCoord), piece.player == currentPlayer {
                        continue
                    }
                    
                    possibleMoves.append(validCoord)
                }
            }
        }
        
        return possibleMoves
    }
    
    private func possibleQueenMoves(from coord: Coord, for player: Player) -> [Coord] {
        // hehe
        return possibleBishopMoves(from: coord, for: player) + possibleRookMoves(from: coord, for: player)
    }
    
    // MARK: - Helper/Convenience functions
    
    func piece(at coord: Coord) -> ChessPiece? {
        return chessBoard[coord.row][coord.column]
    }
}

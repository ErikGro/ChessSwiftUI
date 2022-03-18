//
//  ContentView.swift
//  Shared
//
//  Created by Privat on 03.03.22.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = ChessViewModel()
    @State var offset: CGSize = .zero
    @State var dragged: Coord?
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach((0..<8), id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach((0..<8), id: \.self) { column in
                        if let piece = viewModel.chessBoard[row][column] {
                            piece.image
                                .resizable()
                                .frame(width: 80, height: 80)
                                .offset(Coord(row, column) == dragged ? offset : .zero)
                                .background(color(row: row, column: column, highlighted: viewModel.highLights[row][column]))
                                .zIndex(Coord(row, column) == dragged ? 1 : 0)
                                .onHover { active in
                                    let coord = Coord(row, column)
                                    if active {
                                        viewModel.hoveredAbove = coord
                                    } else if viewModel.hoveredAbove == coord {
                                        viewModel.hoveredAbove = nil
                                    }
                                }.gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            dragged = Coord(row, column)
                                            offset = gesture.translation
                                        }.onEnded { _ in
                                            
                                        }
                                )
                        } else {
                            Rectangle()
                                .fill(color(row: row, column: column, highlighted: viewModel.highLights[row][column]))
                                .frame(width: 80, height: 80)
                                .zIndex(-1)
                        }
                    }
                }
            }
        }
        .border(.gray, width: 1)
    }
    
    func color(row: Int, column: Int, highlighted: Bool) -> Color {
        if highlighted {
            return .orange
        }
        return (row % 2 == column % 2) ? .white : .gray
    }
}

extension ContentView {
    @MainActor class ChessViewModel: ObservableObject {
        @Published var chessBoard: [[ChessPiece?]]
        @Published var highLights: [[Bool]] = Array(repeating: Array(repeating: false, count: 8), count: 8)
        
        var hoveredAbove: Coord? = nil {
            didSet {
                highLights = Array(repeating: Array(repeating: false, count: 8), count: 8)
                
                if let coord = hoveredAbove {
                    coordTapped(coord: coord)
                }
            }
        }
        
        private let game = ChessGame()
        
        init() {
            self.chessBoard = game.chessBoard
        }
        
        func coordTapped(coord: Coord) {
            game.possibleMoves(from: coord)
                .forEach { coord in
                    highLights[coord.row][coord.column] = true
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

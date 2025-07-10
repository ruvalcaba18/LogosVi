import SwiftUI
import Combine

struct TetrisView: View {
    @StateObject private var game: TetrisViewModel
    @State private var timer: Timer?
    
    init(height: CGFloat) {
        _game = StateObject(wrappedValue: TetrisViewModel(height: height))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let totalWidth = geometry.size.width
            
            let infoWidth = totalWidth * 0.3
            let gridWidth = totalWidth * 0.7
            let gridHeight = totalHeight * 0.9
            let buttonsHeight = totalHeight * 0.1
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("👤 Jugador")
                            .font(.headline)
                        Text("🏆 Puntos: 1234")
                        Text("🔥 Nivel: 5")
                        Spacer()
                    }
                    .padding()
                    .frame(width: infoWidth, height: gridHeight)
                    .background(Color(white: 0.95))
                    
                    renderTetrisGrid(game: game, height: gridHeight, width: gridWidth)
                        .frame(width: gridWidth, height: gridHeight)
                        .background(Color.black)
                        .onAppear {
                            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                                game.move(dx: 0, dy: 1)
                            }
                        }
                        .onDisappear {
                            timer?.invalidate()
                        }
                }
                
                renderButtons()
                    .frame(maxWidth: .infinity, maxHeight: buttonsHeight)
                    .background(Color.gray.opacity(0.2))
            }
            .background(.black)
            .frame(width: totalWidth, height: totalHeight)
            .overlay(
                Group {
                    if game.isGameOver {
                        
                        VStack {
                            Text("GAME OVER")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                            
                            Button("Reiniciar") {
                                game.reset()
                            }
                            .padding(.top, 20)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.7))
                        .onAppear{
                            game.current = nil 
                        }
                    }
                }
            )
        }
    }
}

extension TetrisView {
    
    @ViewBuilder
    private func renderButtons() -> some View {
        HStack {
            Button("⬅️") {
                game.move(dx: -1, dy: 0)
            }
            Spacer()
            Button("🔄") {
                game.rotate()
            }
            Spacer()
            Button("➡️") {
                game.move(dx: 1, dy: 0)
            }
            Spacer()
            Button("⬇️") {
                game.move(dx: 0, dy: 1)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
    
    func renderTetrisGrid(game: TetrisViewModel, height: CGFloat, width: CGFloat) -> some View {
        let cellSize = max(
            (height - CGFloat(game.rows - 1) * 2)/CGFloat(game.rows),
            (width - CGFloat(game.cols - 1) * 2)/CGFloat(game.cols)
        )

        return VStack(spacing: 2) {
            ForEach(0..<game.rows, id: \.self) { row in
             
                HStack(spacing: 2) {
                    ForEach(0..<game.cols, id: \.self) { col in
                        Rectangle()
                            .fill(colorAt(game: game, row: row, col: col))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }


    func colorAt(game: TetrisViewModel, row: Int, col: Int) -> Color {
        if let type = game.grid[row][col] {
            return colorForType(type)
        }

        if let tetromino = game.current {
            for block in tetromino.blocks {
                let x = tetromino.position.x + block.x
                let y = tetromino.position.y + block.y
                if x == col && y == row {
                    return colorForType(tetromino.type)
                }
            }
        }

        return .gray.opacity(0.1)
    }


    func colorForType(_ type: TetrominoType) -> Color {
        switch type {
        case .I: return .cyan
        case .O: return .yellow
        case .T: return .purple
        case .S: return .green
        case .Z: return .red
        case .J: return .blue
        case .L: return .orange
        }
    }
}


#Preview {
    GeometryReader { geometry in
        TetrisView(height: geometry.size.height)
    }
}


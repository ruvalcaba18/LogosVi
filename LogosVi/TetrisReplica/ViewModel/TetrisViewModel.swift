import Foundation


final class TetrisViewModel: ObservableObject {
    let rows: Int
    let cols = 10
    @Published var grid: [[TetrominoType?]]
    @Published var current: Tetromino?
    @Published var isGameOver = false

    init(height: CGFloat) {
          // Calculamos las filas para que las celdas sean aproximadamente cuadradas
          let estimatedCellSize: CGFloat = 30
          self.rows = Int(height / estimatedCellSize)
          self.grid = Array(repeating: Array(repeating: nil, count: cols), count: rows)
          spawnTetromino()
      }

    func spawnTetromino() {
        current = Tetromino.random()
        if !isValidPosition(current!) {
            isGameOver = true
        }
    }

    func isValidPosition(_ tetromino: Tetromino) -> Bool {
        for block in tetromino.blocks {
            let x = tetromino.position.x + block.x
            let y = tetromino.position.y + block.y
            if x < 0 || x >= cols || y < 0 || y >= rows {
                return false
            }
            if grid[y][x] != nil {
                return false
            }
        }
        return true
    }

    func move(dx: Int, dy: Int) {
        guard let tetromino = current else { return }
        let moved = tetromino.moved(by: dx, dy: dy)
        if isValidPosition(moved) {
            current = moved
        } else if dy > 0 {
            lockCurrent()
            spawnTetromino()
        }
    }

    func rotate() {
        guard var tetromino = current else { return }
        tetromino.rotate()
        if isValidPosition(tetromino) {
            current = tetromino
        }
    }

    func lockCurrent() {
        guard let tetromino = current else { return }
        for block in tetromino.blocks {
            let x = tetromino.position.x + block.x
            let y = tetromino.position.y + block.y
            if y >= 0 && y < rows && x >= 0 && x < cols {
                grid[y][x] = tetromino.type
            }
        }
        clearLines()
    }

    func clearLines() {
        var newGrid: [[TetrominoType?]] = []
        var cleared = 0

        for row in grid {
            if row.allSatisfy({ $0 != nil }) {
                cleared += 1 // línea completa → no la agregamos
            } else {
                newGrid.append(row)
            }
        }

        let emptyLines = Array(repeating: Array<TetrominoType?>(repeating: nil, count: cols), count: cleared)
        grid = emptyLines + newGrid

        // Aquí podrías sumar puntos por 'cleared'
        print("Cleared \(cleared) lines!")
    }
    
    func reset() {
        isGameOver = false
        grid = Array(repeating: Array<TetrominoType?>(repeating: nil, count: cols), count: rows)
        spawnTetromino()
    }
}


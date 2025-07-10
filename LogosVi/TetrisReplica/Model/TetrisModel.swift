

import Foundation

public enum TetrominoType: CaseIterable {
    case I, O, T, S, Z, J, L
}

struct Point {
    var x: Int
    var y: Int
}

struct Tetromino {
    
    let type: TetrominoType
    var position: Point
    var rotationIndex: Int
    
    var blocks: [Point] {
        Tetromino.rotations[type]![rotationIndex]
    }
    
    mutating func rotate(clockwise: Bool = true ) {
        let count = Tetromino.rotations[type]!.count
        rotationIndex = (rotationIndex + (clockwise ? 1 : count-1)) % count
    }
    
    func moved(by dx: Int, dy: Int) -> Tetromino {
        var copy  = self
        copy.position.x += dx
        copy.position.y += dy
        return copy
    }
    
    static func random() -> Tetromino {
        let type = TetrominoType.allCases.randomElement()!
        return Tetromino(type: type, position: Point(x: 4, y: 0), rotationIndex: 0)
    }
    
    static let rotations: [TetrominoType: [[Point]]] = [
           .I: [
            // MARK: 0 Degrees of the shape
               [Point(x:-2, y:0), Point(x:-1, y:0), Point(x:0, y:0), Point(x:1, y:0)],
               // MARK: 90 Degrees of the shape
               [Point(x:0, y:-1), Point(x:0, y:0), Point(x:0, y:1), Point(x:0, y:2)],
           ],
           .O: [
               [Point(x:0, y:0), Point(x:1, y:0), Point(x:0, y:1), Point(x:1, y:1)],
           ],
           .T: [
               [Point(x:-1, y:0), Point(x:0, y:0), Point(x:1, y:0), Point(x:0, y:1)],
               [Point(x:0, y:-1), Point(x:0, y:0), Point(x:0, y:1), Point(x:1, y:0)],
               [Point(x:-1, y:0), Point(x:0, y:0), Point(x:1, y:0), Point(x:0, y:-1)],
               [Point(x:0, y:-1), Point(x:0, y:0), Point(x:0, y:1), Point(x:-1, y:0)],
           ],
           .S: [
                  [Point(x:0, y:0), Point(x:1, y:0), Point(x:-1, y:1), Point(x:0, y:1)],
                  [Point(x:0, y:-1), Point(x:0, y:0), Point(x:1, y:0), Point(x:1, y:1)],
              ],
              .Z: [
                  [Point(x:-1, y:0), Point(x:0, y:0), Point(x:0, y:1), Point(x:1, y:1)],
                  [Point(x:1, y:-1), Point(x:0, y:0), Point(x:1, y:0), Point(x:0, y:1)],
              ],
              .J: [
                  [Point(x:-1, y:0), Point(x:0, y:0), Point(x:1, y:0), Point(x:-1, y:1)],
                  [Point(x:0, y:-1), Point(x:0, y:0), Point(x:0, y:1), Point(x:1, y:-1)],
                  [Point(x:-1, y:0), Point(x:0, y:0), Point(x:1, y:0), Point(x:1, y:-1)],
                  [Point(x:0, y:-1), Point(x:0, y:0), Point(x:0, y:1), Point(x:-1, y:1)],
              ],
              .L: [
                  [Point(x:-1, y:0), Point(x:0, y:0), Point(x:1, y:0), Point(x:1, y:1)],
                  [Point(x:0, y:-1), Point(x:0, y:0), Point(x:0, y:1), Point(x:1, y:1)],
                  [Point(x:-1, y:0), Point(x:0, y:0), Point(x:1, y:0), Point(x:-1, y:-1)],
                  [Point(x:0, y:-1), Point(x:0, y:0), Point(x:0, y:1), Point(x:-1, y:-1)],
              ]
       ]
    
}

//
//  LCSMatrixView.swift
//  LogosVi
//
//  Created by JaelWizeline on 25/06/25.
//

import SwiftUI

struct Cell: Identifiable {
    let id = UUID()
    let value: Int
    let isMatch: Bool
}

struct LCSMatrixView: View {
    let text1 = Array("abcde")
    let text2 = Array("ace")
    @State private var dpMatrix: [[Cell]] = []

    var body: some View {
        VStack {
            Text("LCS Visualizer: \"abcde\" vs \"ace\"")
                .font(.title2).bold()
                .padding()

            Grid(horizontalSpacing: 4, verticalSpacing: 4) {
                // Primera fila con letras de text2
                GridRow {
                    Text("").frame(width: 30)
                    ForEach(text2.indices, id: \.self) { j in
                        Text(String(text2[j]))
                            .bold()
                            .frame(width: 30)
                    }
                }

                // Resto de la matriz DP
                ForEach(dpMatrix.indices, id: \.self) { i in
                    GridRow {
                        // Primera columna con letras de text1
                        if i > 0 {
                            Text(String(text1[i - 1]))
                                .bold()
                                .frame(width: 30)
                        } else {
                            Text("").frame(width: 30)
                        }

                        // Celdas de la fila actual
                        ForEach(dpMatrix[i]) { cell in
                            Text("\(cell.value)")
                                .frame(width: 30, height: 30)
                                .background(cell.isMatch ? Color.green.opacity(0.6) : Color.gray.opacity(0.2))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear(perform: computeLCSMatrix)
    }

    func computeLCSMatrix() {
        let m = text1.count
        let n = text2.count
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        var matrix: [[Cell]] = []

        for i in 0...m {
            
            var row: [Cell] = []
            
            for j in 0...n {
                
                var isMatch = false
                
                if i > 0 && j > 0 {
                    
                    if text1[i - 1] == text2[j - 1] {
                        
                        dp[i][j] = dp[i - 1][j - 1] + 1
                        isMatch = true
                        
                    } else {
                        dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                    }
                }
                row.append(Cell(value: dp[i][j], isMatch: isMatch))
            }
            matrix.append(row)
        }

        dpMatrix = matrix
    }
}

#Preview {
    LCSMatrixView()
}

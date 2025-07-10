
import SwiftUI

struct PascalTriangleView: View {
    @State private var triangle: [[Int]] = []
    @State private var animatedRow: [String] = []
    @State private var currentRow = 0
    let numRows: Int = 7

    var body: some View {
        ZStack {
            Color.black
                        .ignoresSafeArea()
            VStack(spacing: 10) {
                ForEach(0..<triangle.count, id: \.self) { rowIndex in
                    HStack(spacing: 10) {
                        ForEach(triangle[rowIndex], id: \.self) { num in
                            Text("\(num)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .frame(width: 50, height: 50)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .scaleEffect(1.2)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                if !animatedRow.isEmpty {
                    HStack(spacing: 10) {
                        ForEach(animatedRow.indices, id: \.self) { idx in
                            Text(animatedRow[idx])
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .frame(width: 50, height: 50)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .scaleEffect(1.2)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .padding([.vertical], 10)
            
            .onAppear {
                Task {
                    await buildTriangleWithAnimation()
                }
            }
        }
    }

    func buildTriangleWithAnimation() async {
        triangle = []
        for i in 0..<numRows {
            await animateRowConstruction(i)
            try? await Task.sleep(nanoseconds: 400_000_000)
        }
    }

    func animateRowConstruction(_ rowIndex: Int) async {
        if rowIndex == 0 {
            // Primera fila simple
            withAnimation(.spring()) {
                triangle.append([1])
            }
            return
        }
        let prev = triangle[rowIndex - 1]
        var row: [Int] = [1]
        animatedRow = Array(repeating: "", count: rowIndex + 1)
        animatedRow[0] = "1"
        animatedRow[rowIndex] = "1"
        
        for j in 1..<rowIndex {
            // Mostrar la suma parcial: "a + b"
            let left = prev[j - 1]
            let right = prev[j]
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.4)) {
                    animatedRow[j] = "\(left) + \(right)"
                }
            }
            try? await Task.sleep(nanoseconds: 600_000_000)
            let sum = left + right
            row.append(sum)
            // Mostrar el resultado final
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.4)) {
                    animatedRow[j] = "\(sum)"
                }
            }
            try? await Task.sleep(nanoseconds: 400_000_000)
        }
        row.append(1)
        // Fila terminada, agregar al triángulo y limpiar animación temporal
        await MainActor.run {
            withAnimation(.spring()) {
                triangle.append(row)
                animatedRow = []
            }
        }
    }
}



#Preview {
    PascalTriangleView()
}

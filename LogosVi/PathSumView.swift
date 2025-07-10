import SwiftUI

// Modelo de nodo de árbol binario
class TreeNode: Identifiable, ObservableObject {
    let id = UUID()
    let val: Int
    var left: TreeNode?
    var right: TreeNode?
    
    @Published var isActive = false
    
    init(_ val: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.val = val
        self.left = left
        self.right = right
    }
}

// Vista para un nodo con animación
struct TreeNodeView: View {
    @ObservedObject var node: TreeNode
    
    var body: some View {
        Circle()
            .fill(node.isActive ? Color.red : Color.blue)
            .frame(width: 50, height: 50)
            .overlay(Text("\(node.val)").foregroundColor(.white).bold())
            .shadow(radius: node.isActive ? 10 : 0)
            .animation(.easeInOut, value: node.isActive)
    }
}

// Vista recursiva para el árbol
struct TreeView: View {
    @ObservedObject var node: TreeNode
    
    var body: some View {
        VStack {
            TreeNodeView(node: node)
            HStack(alignment: .top, spacing: 30) {
                if let left = node.left {
                    TreeView(node: left)
                }
                if let right = node.right {
                    TreeView(node: right)
                }
            }
        }
    }
}

struct PathSumView: View {
    @StateObject private var root = TreeNode(
        5,
        left: TreeNode(
            4,
            left: TreeNode(
                11,
                left: TreeNode(
                    7
                ),
                right: TreeNode(
                    2
                )
            )
        ),
        right: TreeNode(
            8,
            left: TreeNode(
                13
            ),
            right: TreeNode(
                4,
                right: TreeNode(
                    1
                )
            )
        )
    )
    @State private var sum = 22
    @State private var found = false
    @State private var currentSum = 0
    
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Sum to found \(sum )")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                
                TreeView(node: root)
                
                Text("Current sum: \(currentSum)")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                
                Button("Start Path Sum Animation") {
                    found = false
                    currentSum = 0
                    Task {
                        await pathSum(root, targetSum: sum)
                    }
                }
                
                if found {
                    Text("Path sum found! 🎉")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                }
            }
            .padding()
        }
    }
    
    // Función recursiva con animación para path sum
    func pathSum(_ node: TreeNode?, targetSum: Int, currentSum: Int = 0) async -> Bool {
        guard let node = node else { return false }
        
        await MainActor.run {
            node.isActive = true
        }
        let newSum = currentSum + node.val
        await MainActor.run {
            self.currentSum = newSum
        }
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        if node.left == nil && node.right == nil && newSum == targetSum {
            await MainActor.run {
                found = true
            }
            return true
        }
        
        let leftFound = await pathSum(node.left, targetSum: targetSum, currentSum: newSum)
        if leftFound { return true }
        let rightFound = await pathSum(node.right, targetSum: targetSum, currentSum: newSum)
        if rightFound { return true }
        
        // Desactivar nodo si no encontró la suma aquí
        await MainActor.run {
            node.isActive = false
        }
        
        return false
    }
}

#Preview {
    PathSumView()
}



import SwiftUI

struct HouseLogoView: View {
    @State private var fillHeight: CGFloat = 0.0

    var body: some View {
        VStack {
            ZStack {
                RadialGradient(colors: [.black, .blue.opacity(0.5)],
                               center: .center, startRadius: 100, endRadius: 400)
                    .ignoresSafeArea()
             

                ZStack {
                    MinimalHomeShape()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 10)
                        .blur(radius: 6)

                    MinimalHomeShape()
                        .stroke(
                            LinearGradient(colors: [.cyan, .blue],
                                           startPoint: .top,
                                           endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .shadow(color: .blue.opacity(0.8), radius: 8)

                    MinimalHomeShape()
                        .fill(
                            LinearGradient(colors: [.blue, .cyan],
                                           startPoint: .bottom,
                                           endPoint: .top)
                        )
                        .mask(
                            Rectangle()
                                .frame(height: fillHeight)
                                .offset(y: 250 - fillHeight / 2)
                        )
                        .animation(.easeInOut(duration: 1), value: fillHeight)
                }
                .frame(width: 350, height: 350)
            }
            .frame(maxHeight: .infinity)

            // Botones
            HStack(spacing: 20) {
                Button("20%") {
                    setFill(to: 0.2)
                }
                Button("50%") {
                    setFill(to: 0.5)
                }
                Button("100%") {
                    setFill(to: 1.0)
                }
            }
            .background(.black)
            .padding()
            .buttonStyle(.borderedProminent)
        }.background(.black)
    }

    private func setFill(to percentage: CGFloat) {
        let totalHeight: CGFloat = 480
        fillHeight = totalHeight * percentage
    }
}

#Preview {
    HouseLogoView()
}
    

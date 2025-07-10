
import Foundation
import SwiftUI

struct MinimalHomeShape: Shape {
    // MARK: - Dimensiones y Radios de Forma
    // Estas constantes definen la apariencia de la casa y el techo.
    // Ajustarlas para cambiar la forma y redondez.
    private let bodyCornerRadius: CGFloat = 12.0 // Radio para las esquinas inferiores del cuerpo
    private let roofApexRadius: CGFloat = 4.0     // Radio para el pico del techo
    private let roofBaseConvexityDepth: CGFloat = 0.02 // Factor de profundidad de la curva cóncava del techo (más sutil)
    
    // Dimensiones relativas del cuerpo y techo
    private let houseBodyWidthRatio: CGFloat = 0.65
    private let houseBodyHeightRatio: CGFloat = 0.55
    private let roofHeightRatio: CGFloat = 0.55 // AJUSTADO: Un poco más de altura al techo para no amontonar el ápice
    private let roofOverhangHorizontalRatio: CGFloat = 0.15 // AJUSTADO: Más ancho el triángulo del techo
    
    // Dimensiones de la puerta
    private let doorWidthRatio: CGFloat = 0.4
    private let doorHeightRatio: CGFloat = 0.65 // AJUSTADO: Más height para la puerta
    private let doorCornerRadius: CGFloat = 10.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // MARK: - Cálculos de Dimensiones Absolutas
        let bodyWidth = houseBodyWidthRatio * w
        let bodyHeight = houseBodyHeightRatio * h

        let bodyRect = CGRect(x: (w - bodyWidth) / 2,
                              y: h - bodyHeight,
                              width: bodyWidth,
                              height: bodyHeight)

        let roofOverhang = roofOverhangHorizontalRatio * w
        let roofHeight = roofHeightRatio * h

        // MARK: - Puntos Clave
        let housePoints = HousePoints(
            bottomLeft: CGPoint(x: bodyRect.minX, y: bodyRect.maxY),
            bottomRight: CGPoint(x: bodyRect.maxX, y: bodyRect.maxY),
            topLeft: CGPoint(x: bodyRect.minX, y: bodyRect.minY),
            topRight: CGPoint(x: bodyRect.maxX, y: bodyRect.minY),
            roofApex: CGPoint(x: w / 2, y: bodyRect.minY - roofHeight),
            roofBaseLeft: CGPoint(x: bodyRect.minX - roofOverhang, y: bodyRect.minY),
            roofBaseRight: CGPoint(x: bodyRect.maxX + roofOverhang, y: bodyRect.minY)
        )

        // MARK: - Trazar la Casa
        path.addPath(drawHouseBody(from: housePoints, bodyCornerRadius: bodyCornerRadius))
        // El drawHouseRoof ahora es responsable de toda la secuencia del techo
        path.addPath(drawHouseRoof(from: housePoints, roofApexRadius: roofApexRadius, roofBaseConvexityDepth: roofBaseConvexityDepth * h, roofOverhangHorizontal: roofOverhang))
        path.addPath(drawHouseDoor(in: bodyRect, doorWidthRatio: doorWidthRatio, doorHeightRatio: doorHeightRatio, doorCornerRadius: doorCornerRadius))

        return path
    }

    // MARK: - Funciones Modulares de Trazado
    
    /// Estructura para contener los puntos clave de la casa.
    fileprivate struct HousePoints {
        let bottomLeft: CGPoint
        let bottomRight: CGPoint
        let topLeft: CGPoint
        let topRight: CGPoint
        let roofApex: CGPoint
        let roofBaseLeft: CGPoint
        let roofBaseRight: CGPoint
    }

    /// Dibuja el cuerpo principal de la casa con esquinas inferiores redondeadas y superiores cuadradas.
    private func drawHouseBody(from points: HousePoints, bodyCornerRadius: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: points.bottomLeft.x, y: points.bottomLeft.y - bodyCornerRadius))

        // Redondeo inferior izquierdo
        path.addArc(center: CGPoint(x: points.bottomLeft.x + bodyCornerRadius, y: points.bottomLeft.y - bodyCornerRadius),
                   radius: bodyCornerRadius,
                   startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        // Línea inferior
        path.addLine(to: CGPoint(x: points.bottomRight.x - bodyCornerRadius, y: points.bottomRight.y))

        // Redondeo inferior derecho
        path.addArc(center: CGPoint(x: points.bottomRight.x - bodyCornerRadius, y: points.bottomRight.y - bodyCornerRadius),
                   radius: bodyCornerRadius,
                   startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        // Línea lateral derecha (vertical) hasta la esquina superior derecha (CUADRADA)
        path.addLine(to: points.topRight)

        return path
    }

    /// Dibuja el techo de la casa con bases cóncavas hacia arriba y ápice redondeado.
    /// Esta función ahora contiene la lógica para las curvas de la base del techo directamente.
    private func drawHouseRoof(from points: HousePoints, roofApexRadius: CGFloat, roofBaseConvexityDepth: CGFloat, roofOverhangHorizontal: CGFloat) -> Path {
        var path = Path()
        
        // El techo comienza desde la esquina superior derecha del cuerpo.
        // Y luego se extiende horizontalmente para el voladizo.
        path.move(to: points.topRight) // Mueve el path al inicio del trazado del techo
        path.addLine(to: points.roofBaseRight) // Dibuja la línea recta del voladizo derecho.

        // Lado derecho del techo con curvatura CÓNCAVA ("hacia arriba")
        // El punto final de esta curva será el inicio del redondeo del ápice.
        let roofApexArcStartRight = CGPoint(x: points.roofApex.x + roofApexRadius, y: points.roofApex.y)
        
        // AJUSTE CLAVE: ControlPoint para una curva CÓNCAVA (hacia arriba)
        // El control point está por encima de la línea del voladizo y ligeramente hacia afuera.
        // Calibrado para suavidad y no ser picudo.
        let controlPointRight = CGPoint(x: points.roofBaseRight.x + (roofOverhangHorizontal * 0.4), // Mueve el CP HORIZONTALMENTE HACIA AFUERA
                                        y: points.roofBaseRight.y - roofBaseConvexityDepth) // Tira HACIA ARRIBA para la curvatura CÓNCAVA

        path.addQuadCurve(to: roofApexArcStartRight,
                          control: controlPointRight)


        // Redondeo del ápice
        path.addArc(tangent1End: points.roofApex,
                   tangent2End: CGPoint(x: points.roofApex.x, y: points.roofApex.y),
                   radius: roofApexRadius)

        // Lado izquierdo del techo con curvatura CÓNCAVA ("hacia arriba")
        // El punto final de esta curva será el punto de voladizo izquierdo.
        let roofApexArcStartLeft = CGPoint(x: points.roofApex.x, y: points.roofApex.y)
        
        // ControlPoint simétrico
        let controlPointLeft = CGPoint(x: points.roofBaseLeft.x - (roofOverhangHorizontal * 0.4),
                                       y: points.roofBaseLeft.y - roofBaseConvexityDepth)

        path.addQuadCurve(to: points.roofBaseLeft,
                          control: controlPointLeft)

        // La línea recta desde el final del voladizo izquierdo hasta la esquina superior izquierda del cuerpo (CUADRADA)
        path.addLine(to: points.topLeft)
     

        // Línea lateral izquierda (vertical) hasta la base redondeada
        path.addLine(to: CGPoint(x: points.bottomLeft.x, y: points.bottomLeft.y ))

        // No cerramos el subpath del techo aquí, ya que el path general se cierra al final de MinimalHomeShape.
        // Esto evita la figura extra.
        
        return path
    }

    /// Dibuja la puerta centrada del cuerpo de la casa.
    private func drawHouseDoor(in bodyRect: CGRect, doorWidthRatio: CGFloat, doorHeightRatio: CGFloat, doorCornerRadius: CGFloat) -> Path {
        var path = Path()
        let doorWidth = doorWidthRatio * bodyRect.width
        let doorHeight = doorHeightRatio * bodyRect.height
        let doorX = bodyRect.midX - doorWidth / 2
        let doorY = bodyRect.maxY - doorHeight - (bodyCornerRadius / 2) // bodyCornerRadius viene del ámbito de MinimalHomeShape

        let doorRect = CGRect(x: doorX, y: doorY, width: doorWidth, height: doorHeight)
        path.addRoundedRect(in: doorRect, cornerSize: CGSize(width: doorCornerRadius, height: doorCornerRadius))
        
        return path
    }
}

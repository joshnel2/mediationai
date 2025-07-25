import SwiftUI

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 2)

        let colors: [UIColor] = [.systemPink, .systemTeal, .systemYellow, .systemPurple]
        var cells: [CAEmitterCell] = []
        for color in colors {
            let cell = CAEmitterCell()
            cell.birthRate = 5
            cell.lifetime = 4
            cell.velocity = 150
            cell.velocityRange = 100
            cell.emissionLongitude = .pi
            cell.spin = 3
            cell.spinRange = 5
            cell.scaleRange = 0.2
            cell.scale = 0.6
            cell.color = color.cgColor
            cell.contents = UIImage(systemName: "circle.fill")?.withTintColor(color, renderingMode: .alwaysOriginal).cgImage
            cells.append(cell)
        }
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            emitter.birthRate = 0
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let url: String
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    var body: some View {
        if let cg = generateQR() {
            Image(decorative: cg, scale: 1.0)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        }
    }
    private func generateQR() -> CGImage? {
        filter.message = Data(url.utf8)
        if let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10, y: 10)) {
            return context.createCGImage(output, from: output.extent)
        }
        return nil
    }
}
import SwiftUI

#if DEBUG
struct ComponentCatalogView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Buttons") {
                    VStack(spacing: 12) {
                        Button("Primary Button") {}
                            .primaryButton()
                        Button("Secondary Button") {}
                            .secondaryButton()
                    }
                    .padding()
                }

                Section("Cards") {
                    VStack(spacing: 16) {
                        Text("Modern Card")
                            .modernCard()
                        Text("Glass Card")
                            .glassCard()
                    }
                }

                Section("Skeleton Loader") {
                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(AppTheme.glassSecondary)
                            .frame(height: 20)
                            .shimmer()
                        Rectangle()
                            .fill(AppTheme.glassSecondary)
                            .frame(height: 20)
                            .shimmer()
                    }
                }

                Section("Heat Meter") {
                    HeatMeterSample()
                        .frame(height: 60)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Component Catalog")
        }
    }

    private struct HeatMeterSample: View {
        let dummy = ["Calm message", "WHY?!", "This is STUPID!!!", "Ok fine"]
        var body: some View {
            VStack {
                ForEach(dummy, id: \ .self) { txt in
                    Rectangle()
                        .fill(color(for: txt))
                        .frame(height: 8)
                }
            }
        }
        private func color(for text: String) -> Color {
            let exclam = text.filter { $0 == "!" }.count
            let capsRatio = Double(text.filter { $0.isUppercase }.count) / Double(max(1,text.count))
            let score = Double(exclam)*0.3 + capsRatio*0.5
            if score < 0.3 { return .blue }
            if score < 0.6 { return .orange }
            return .red
        }
    }
}
#endif
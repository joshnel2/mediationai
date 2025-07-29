import SwiftUI

struct UnderlineToggle: View {
    @Binding var selection: Int
    let titles: [String]
    @Namespace private var ns

    var body: some View {
        HStack {
            ForEach(titles.indices, id: \.self) { idx in
                Button(action: { withAnimation(.spring()) { selection = idx } }) {
                    VStack(spacing:4){
                        Text(titles[idx])
                            .font(.subheadline.weight(selection == idx ? .bold : .regular))
                            .foregroundColor(selection == idx ? AppTheme.accent : Color.primary.opacity(0.6))
                        ZStack{
                            if selection == idx {
                                Rectangle()
                                    .fill(AppTheme.accent)
                                    .matchedGeometryEffect(id: "uline", in: ns)
                                    .frame(height:2)
                            } else {
                                Rectangle().fill(Color.clear).frame(height:2)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
    }
}
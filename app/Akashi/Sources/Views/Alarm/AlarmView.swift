import SwiftUI
import AudioToolbox

/// The high-contrast "冤罪です" alarm screen (画面07), styled after the same
/// black-background / large-vertical-type pattern used by digi police's
/// "痴漢です・助けてください" screen so bystanders instantly understand it.
struct AlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isSounding = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark").foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding()

            Spacer()

            HStack(spacing: 14) {
                VerticalText("信じてください", size: 22)
                VerticalText("冤罪です", size: 40)
            }
            .foregroundStyle(.white)

            Spacer()

            Text("画面をタップすると音で周囲に知らせます")
                .font(AppFont.body(10))
                .foregroundStyle(Color(white: 0.81))
            Text("マナーモードでも音が鳴りますので、使用の際はご注意ください。")
                .font(AppFont.body(8.5))
                .foregroundStyle(Color(white: 0.56))
                .padding(.bottom, 14)

            HStack(spacing: 8) {
                Button {
                    sound()
                } label: {
                    Text(isSounding ? "鳴動中..." : "音で知らせる")
                        .font(AppFont.body(11, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white)
                        .foregroundStyle(Color(white: 0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                NavigationLink {
                    GuideView(scrollToHotline: true)
                } label: {
                    Text("弁護士に連絡")
                        .font(AppFont.body(11, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(.white, lineWidth: 1))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
        }
        .background(Color(white: 0.04).ignoresSafeArea())
        .onTapGesture { sound() }
    }

    private func sound() {
        isSounding = true
        AudioServicesPlaySystemSound(SystemSoundID(1005))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { isSounding = false }
    }
}

private struct VerticalText: View {
    let text: String
    let size: CGFloat

    init(_ text: String, size: CGFloat) {
        self.text = text
        self.size = size
    }

    var body: some View {
        VStack(spacing: size * 0.06) {
            ForEach(Array(text), id: \.self) { character in
                Text(String(character))
                    .font(AppFont.headline(size))
            }
        }
    }
}

#Preview {
    NavigationStack { AlarmView() }
}

import SwiftUI
import UIKit

struct UIKitSpinnerRepresentable: UIViewRepresentable {
    let isSpinning: Bool

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        return spinner
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        if isSpinning {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

struct SwiftUIGreetingView: View {
    @State private var enteredName: String = ""
    @State private var greetingOutput: String = "Enter your name above to begin."
    @State private var isProcessing: Bool = false

    var body: some View {
        VStack(spacing: 18) {
            Text("SwiftUI Check-In")
                .font(.title2)
                .fontWeight(.bold)

            TextField("Type your full name", text: $enteredName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Generate Greeting") {
                let cleaned = enteredName.trimmingCharacters(in: .whitespacesAndNewlines)
                greetingOutput = cleaned.isEmpty
                    ? "Please enter a valid name."
                    : "Welcome to iOS Training, \(cleaned)!"
            }
            .buttonStyle(.borderedProminent)

            UIKitSpinnerRepresentable(isSpinning: isProcessing)

            Text(greetingOutput)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 40)
    }
}

#Preview {
    SwiftUIGreetingView()
}

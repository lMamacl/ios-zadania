import SwiftUI

struct ContentView: View {
    @State private var message = "Listening to gestures..."
    @State private var color: Color = .gray            // default: not white
    @State private var isShowingDialog = false
    // true once the user confirmed a colour change; the second view then starts with a random colour.
    @State private var wasShaken = false
    @State private var isVisible = true

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text(message)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(10)
                Spacer()
                NavigationLink(destination: SecondView(wasShaken: wasShaken)) {
                    Text("Go to the second view")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .background(color.ignoresSafeArea())
            .gesture(tapGestures)
            .onLongPressGesture { message = "Long press!" }
            .gesture(pinchGesture)
            .simultaneousGesture(dragGesture)
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
                guard isVisible else { return }
                message = "Shaken"
                isShowingDialog = true
            }
            .confirmationDialog(
                "Do you want to change the background color?",
                isPresented: $isShowingDialog,
                titleVisibility: .visible
            ) {
                Button("Yes") {
                    color = ColorHelper.getRandomColor()
                    wasShaken = true
                }
                Button("No", role: .destructive) { }
                Button("Cancel", role: .cancel) { }
            }
            .onAppear { isVisible = true }
            .onDisappear { isVisible = false }
        }
    }

    // Triple > double > single: the higher tap count gets priority.
    private var tapGestures: some Gesture {
        let triple = TapGesture(count: 3).onEnded { message = "Triple tap!" }
        let double = TapGesture(count: 2).onEnded { message = "Double tap!" }
        let single = TapGesture(count: 1).onEnded { message = "Tap!" }
        return triple.exclusively(before: double).exclusively(before: single)
    }

    private var pinchGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                message = "Pinch! (scale \(String(format: "%.2f", value.magnification)))"
            }
            .onEnded { _ in
                message = "Pinch ended"
            }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { _ in
                message = "Drag..."
            }
            .onEnded { value in
                message = "Swipe \(direction(of: value.translation))"
            }
    }

    private func direction(of translation: CGSize) -> String {
        if abs(translation.width) > abs(translation.height) {
            return translation.width > 0 ? "right" : "left"
        }
        return translation.height > 0 ? "down" : "up"
    }
}

#Preview {
    ContentView()
}

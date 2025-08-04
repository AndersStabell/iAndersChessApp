import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @State private var showSettings = false
    @State private var showGameHistory = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Title
                VStack {
                    Text("♛ iAnders Chess")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Master the Royal Game")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Game Mode Buttons
                VStack(spacing: 20) {
                    NavigationLink(destination: GameView(gameManager: gameManager, gameMode: .humanVsAI)) {
                        GameModeButton(
                            title: "Play vs Computer",
                            subtitle: "Challenge AI opponent",
                            icon: "cpu",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: GameView(gameManager: gameManager, gameMode: .humanVsHuman)) {
                        GameModeButton(
                            title: "Play vs Human",
                            subtitle: "Local multiplayer",
                            icon: "person.2.fill",
                            color: .green
                        )
                    }
                    
                    NavigationLink(destination: GameHistoryView()) {
                        GameModeButton(
                            title: "Game History",
                            subtitle: "View past games",
                            icon: "clock.arrow.circlepath",
                            color: .orange
                        )
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        GameModeButton(
                            title: "Settings",
                            subtitle: "Customize your experience",
                            icon: "gearshape.fill",
                            color: .purple
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Version Info
                Text("Version 1.0")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct GameModeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

// Placeholder views for navigation
struct GameHistoryView: View {
    var body: some View {
        Text("Game History")
            .navigationTitle("History")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}

#Preview {
    ContentView()
}
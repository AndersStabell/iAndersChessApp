import SwiftUI

struct ChessBoardView: View {
    @ObservedObject var gameManager: GameManager
    @State private var boardSize: CGSize = .zero
    @State private var squareSize: CGFloat = 40
    @State private var showingPromotionPicker = false
    @State private var dragOffset: CGSize = .zero
    @State private var draggedPiece: ChessPiece?
    @State private var draggedFrom: ChessPosition?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top player info (Black)
                PlayerInfoView(
                    color: .black,
                    timer: gameManager.blackTimer,
                    capturedPieces: gameManager.chessEngine.capturedPieces.filter { $0.color == .white },
                    isCurrentPlayer: gameManager.chessEngine.currentPlayer == .black,
                    gameState: gameManager.chessEngine.gameState
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Chess Board
                boardView(geometry: geometry)
                
                Spacer()
                
                // Bottom player info (White)
                PlayerInfoView(
                    color: .white,
                    timer: gameManager.whiteTimer,
                    capturedPieces: gameManager.chessEngine.capturedPieces.filter { $0.color == .black },
                    isCurrentPlayer: gameManager.chessEngine.currentPlayer == .white,
                    gameState: gameManager.chessEngine.gameState
                )
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingPromotionPicker) {
            PromotionPickerView(
                color: gameManager.chessEngine.currentPlayer.opposite,
                onSelection: { promotionPiece in
                    if let from = gameManager.selectedSquare,
                       let to = gameManager.promotionSquare {
                        gameManager.executeMove(from: from, to: to, promotion: promotionPiece)
                    }
                    showingPromotionPicker = false
                }
            )
        }
        .onChange(of: gameManager.showPromotionDialog) { showPromotion in
            showingPromotionPicker = showPromotion
        }
    }
    
    private func boardView(geometry: GeometryProxy) -> some View {
        let availableSize = min(geometry.size.width - 40, geometry.size.height * 0.6)
        let calculatedSquareSize = availableSize / 8
        
        return VStack(spacing: 0) {
            // Rank labels (8-1) and board
            HStack(spacing: 0) {
                // Left rank labels
                if gameManager.showCoordinates {
                    VStack(spacing: 0) {
                        ForEach((1...8).reversed(), id: \.self) { rank in
                            Text("\(rank)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 20, height: calculatedSquareSize)
                        }
                    }
                }
                
                // Chess board
                VStack(spacing: 0) {
                    ForEach((0..<8).reversed(), id: \.self) { rank in
                        HStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { file in
                                ChessSquareView(
                                    position: ChessPosition(file, rank),
                                    piece: gameManager.chessEngine.board[file][rank],
                                    isSelected: gameManager.selectedSquare == ChessPosition(file, rank),
                                    isHighlighted: gameManager.highlightedSquares.contains(ChessPosition(file, rank)),
                                    isLastMove: isLastMoveSquare(file: file, rank: rank),
                                    isInCheck: isKingInCheck(file: file, rank: rank),
                                    theme: gameManager.boardTheme,
                                    size: calculatedSquareSize
                                ) {
                                    gameManager.handleSquareTap(ChessPosition(file, rank))
                                }
                            }
                        }
                    }
                }
                .frame(width: calculatedSquareSize * 8, height: calculatedSquareSize * 8)
                .clipped()
                
                // Right rank labels
                if gameManager.showCoordinates {
                    VStack(spacing: 0) {
                        ForEach((1...8).reversed(), id: \.self) { rank in
                            Text("\(rank)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 20, height: calculatedSquareSize)
                        }
                    }
                }
            }
            
            // File labels (a-h)
            if gameManager.showCoordinates {
                HStack(spacing: 0) {
                    if gameManager.showCoordinates {
                        Spacer().frame(width: 20)
                    }
                    
                    ForEach(0..<8, id: \.self) { file in
                        Text(String("abcdefgh"["abcdefgh".index("abcdefgh".startIndex, offsetBy: file)]))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(width: calculatedSquareSize, height: 20)
                    }
                    
                    if gameManager.showCoordinates {
                        Spacer().frame(width: 20)
                    }
                }
            }
        }
        .onAppear {
            squareSize = calculatedSquareSize
        }
    }
    
    private func isLastMoveSquare(file: Int, rank: Int) -> Bool {
        guard let lastMove = gameManager.lastMove else { return false }
        let position = ChessPosition(file, rank)
        return position == lastMove.from || position == lastMove.to
    }
    
    private func isKingInCheck(file: Int, rank: Int) -> Bool {
        guard let piece = gameManager.chessEngine.board[file][rank],
              piece.type == .king else { return false }
        
        switch gameManager.chessEngine.gameState {
        case .check(let color):
            return piece.color == color
        case .checkmate(let winner):
            return piece.color != winner
        default:
            return false
        }
    }
}

struct ChessSquareView: View {
    let position: ChessPosition
    let piece: ChessPiece?
    let isSelected: Bool
    let isHighlighted: Bool
    let isLastMove: Bool
    let isInCheck: Bool
    let theme: BoardTheme
    let size: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Square background
            Rectangle()
                .fill(squareColor)
                .frame(width: size, height: size)
            
            // Last move highlight
            if isLastMove {
                Rectangle()
                    .fill(Color.yellow.opacity(0.4))
                    .frame(width: size, height: size)
            }
            
            // Selection highlight
            if isSelected {
                Rectangle()
                    .stroke(Color.blue, lineWidth: 3)
                    .frame(width: size, height: size)
            }
            
            // Check highlight
            if isInCheck {
                Rectangle()
                    .fill(Color.red.opacity(0.6))
                    .frame(width: size, height: size)
            }
            
            // Legal move indicators
            if isHighlighted {
                Circle()
                    .fill(piece != nil ? Color.red.opacity(0.7) : Color.gray.opacity(0.3))
                    .frame(width: piece != nil ? size * 0.9 : size * 0.3,
                           height: piece != nil ? size * 0.9 : size * 0.3)
                    .overlay(
                        piece != nil ? 
                        Circle().stroke(Color.red, lineWidth: 3) : nil
                    )
            }
            
            // Chess piece
            if let chessPiece = piece {
                Text(chessPiece.symbol)
                    .font(.system(size: size * 0.7))
                    .foregroundColor(.primary)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
            }
        }
        .onTapGesture {
            onTap()
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }
    
    private var squareColor: Color {
        let isLightSquare = (position.file + position.rank) % 2 == 0
        return isLightSquare ? theme.lightSquareColor : theme.darkSquareColor
    }
}

struct PlayerInfoView: View {
    let color: PieceColor
    let timer: PlayerTimer
    let capturedPieces: [ChessPiece]
    let isCurrentPlayer: Bool
    let gameState: GameState
    
    var body: some View {
        HStack {
            // Player indicator
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Circle()
                        .fill(color == .white ? Color.white : Color.black)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 20, height: 20)
                    
                    Text(color == .white ? "White" : "Black")
                        .font(.headline)
                        .fontWeight(isCurrentPlayer ? .bold : .regular)
                    
                    if isCurrentPlayer {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                
                // Game state indicator
                gameStateText
            }
            
            Spacer()
            
            // Captured pieces
            if !capturedPieces.isEmpty {
                HStack(spacing: 2) {
                    ForEach(Array(capturedPieces.enumerated()), id: \.offset) { index, piece in
                        Text(piece.symbol)
                            .font(.caption)
                            .opacity(0.7)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Timer
            if timer.timeRemaining > 0 {
                TimerView(timer: timer)
            }
        }
        .padding(.vertical, 8)
        .background(isCurrentPlayer ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private var gameStateText: some View {
        switch gameState {
        case .check(let checkedColor) where checkedColor == color:
            Text("Check!")
                .font(.caption)
                .foregroundColor(.red)
                .fontWeight(.bold)
        case .checkmate(let winner) where winner != color:
            Text("Checkmate")
                .font(.caption)
                .foregroundColor(.red)
                .fontWeight(.bold)
        case .checkmate(let winner) where winner == color:
            Text("Victory!")
                .font(.caption)
                .foregroundColor(.green)
                .fontWeight(.bold)
        case .stalemate:
            Text("Stalemate")
                .font(.caption)
                .foregroundColor(.orange)
        case .draw:
            Text("Draw")
                .font(.caption)
                .foregroundColor(.orange)
        case .resigned(let winner) where winner == color:
            Text("Victory!")
                .font(.caption)
                .foregroundColor(.green)
                .fontWeight(.bold)
        case .resigned(let winner) where winner != color:
            Text("Resigned")
                .font(.caption)
                .foregroundColor(.red)
        default:
            EmptyView()
        }
    }
}

struct TimerView: View {
    @ObservedObject var timer: PlayerTimer
    
    var body: some View {
        Text(timer.formattedTime)
            .font(.system(.title2, design: .monospaced))
            .fontWeight(.bold)
            .foregroundColor(timer.isLowTime ? .red : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(timer.isActive ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                    .stroke(timer.isActive ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .scaleEffect(timer.isLowTime ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), 
                      value: timer.isLowTime)
    }
}

struct PromotionPickerView: View {
    let color: PieceColor
    let onSelection: (PieceType) -> Void
    
    private let promotionPieces: [PieceType] = [.queen, .rook, .bishop, .knight]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Promotion")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Select which piece to promote your pawn to:")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                ForEach(promotionPieces, id: \.self) { pieceType in
                    Button(action: {
                        onSelection(pieceType)
                    }) {
                        VStack(spacing: 8) {
                            Text(ChessPiece(type: pieceType, color: color).symbol)
                                .font(.system(size: 60))
                            
                            Text(pieceType.rawValue.capitalized)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(width: 80, height: 100)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .presentationDetents([.fraction(0.4)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Game View (Main Game Screen)
struct GameView: View {
    @ObservedObject var gameManager: GameManager
    let gameMode: GameMode
    @State private var showingGameSetup = true
    @State private var showingGameMenu = false
    @State private var selectedTimeControl: TimeControl = .unlimited
    @State private var selectedAIDifficulty: AIDifficulty = .medium
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Main game view
            if !showingGameSetup {
                VStack(spacing: 0) {
                    // Top toolbar
                    HStack {
                        Button("Menu") {
                            showingGameMenu = true
                        }
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        // Game info
                        VStack(spacing: 2) {
                            Text(gameMode == .humanVsAI ? "vs Computer" : "vs Human")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if selectedTimeControl != .unlimited {
                                Text(selectedTimeControl.displayName)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Resign") {
                            gameManager.resignGame()
                        }
                        .foregroundColor(.red)
                        .disabled(!gameManager.isGameActive)
                    }
                    .padding()
                    
                    // Chess board
                    ChessBoardView(gameManager: gameManager)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingGameSetup) {
            GameSetupView(
                gameMode: gameMode,
                selectedTimeControl: $selectedTimeControl,
                selectedAIDifficulty: $selectedAIDifficulty,
                onStartGame: {
                    gameManager.startNewGame(
                        mode: gameMode,
                        timeControl: selectedTimeControl,
                        aiDifficulty: selectedAIDifficulty
                    )
                    showingGameSetup = false
                }
            )
        }
        .actionSheet(isPresented: $showingGameMenu) {
            ActionSheet(
                title: Text("Game Menu"),
                buttons: [
                    .default(Text("New Game")) {
                        showingGameSetup = true
                    },
                    .default(Text("Pause/Resume")) {
                        if gameManager.isGameActive {
                            gameManager.pauseGame()
                        } else {
                            gameManager.resumeGame()
                        }
                    },
                    .destructive(Text("Resign")) {
                        gameManager.resignGame()
                    },
                    .default(Text("Offer Draw")) {
                        gameManager.offerDraw()
                    },
                    .cancel()
                ]
            )
        }
    }
}

struct GameSetupView: View {
    let gameMode: GameMode
    @Binding var selectedTimeControl: TimeControl
    @Binding var selectedAIDifficulty: AIDifficulty
    let onStartGame: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Game mode info
                VStack(spacing: 10) {
                    Image(systemName: gameMode == .humanVsAI ? "cpu" : "person.2.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text(gameMode == .humanVsAI ? "Play vs Computer" : "Play vs Human")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                // Time control selection
                VStack(alignment: .leading, spacing: 15) {
                    Text("Time Control")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(TimeControl.allCases, id: \.self) { timeControl in
                            Button(action: {
                                selectedTimeControl = timeControl
                            }) {
                                VStack(spacing: 4) {
                                    Text(timeControl.rawValue)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Text(timeControl.displayName)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    selectedTimeControl == timeControl ? 
                                    Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
                                )
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            selectedTimeControl == timeControl ? Color.blue : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // AI difficulty selection (only for human vs AI)
                if gameMode == .humanVsAI {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("AI Difficulty")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                                Button(action: {
                                    selectedAIDifficulty = difficulty
                                }) {
                                    VStack(spacing: 4) {
                                        Text(difficulty.displayName)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Text(difficulty.description)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        selectedAIDifficulty == difficulty ? 
                                        Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
                                    )
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                selectedAIDifficulty == difficulty ? Color.blue : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Start game button
                Button(action: onStartGame) {
                    Text("Start Game")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("Game Setup")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    ChessBoardView(gameManager: GameManager())
}
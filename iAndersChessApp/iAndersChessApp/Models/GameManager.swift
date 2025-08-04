import Foundation
import SwiftUI

// MARK: - Game Mode
enum GameMode {
    case humanVsHuman
    case humanVsAI
}

// MARK: - Time Control
enum TimeControl: String, CaseIterable {
    case bullet = "1+0"
    case blitz = "3+2"
    case rapid = "10+0"
    case classical = "30+0"
    case unlimited = "∞"
    
    var displayName: String {
        switch self {
        case .bullet: return "Bullet (1 min)"
        case .blitz: return "Blitz (3+2)"
        case .rapid: return "Rapid (10 min)"
        case .classical: return "Classical (30 min)"
        case .unlimited: return "No Time Limit"
        }
    }
    
    var initialTime: TimeInterval {
        switch self {
        case .bullet: return 60 // 1 minute
        case .blitz: return 180 // 3 minutes
        case .rapid: return 600 // 10 minutes
        case .classical: return 1800 // 30 minutes
        case .unlimited: return 0
        }
    }
    
    var increment: TimeInterval {
        switch self {
        case .bullet: return 0
        case .blitz: return 2 // 2 seconds
        case .rapid: return 0
        case .classical: return 0
        case .unlimited: return 0
        }
    }
}

// MARK: - AI Difficulty
enum AIDifficulty: Int, CaseIterable {
    case beginner = 1
    case easy = 3
    case medium = 5
    case hard = 8
    case expert = 12
    case master = 16
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        case .master: return "Master"
        }
    }
    
    var description: String {
        switch self {
        case .beginner: return "Perfect for learning"
        case .easy: return "Casual play"
        case .medium: return "Balanced challenge"
        case .hard: return "Strong opponent"
        case .expert: return "Very challenging"
        case .master: return "Maximum difficulty"
        }
    }
    
    var stockfishDepth: Int {
        return rawValue
    }
    
    var thinkingTime: TimeInterval {
        switch self {
        case .beginner: return 0.5
        case .easy: return 1.0
        case .medium: return 2.0
        case .hard: return 3.0
        case .expert: return 5.0
        case .master: return 8.0
        }
    }
}

// MARK: - Player Timer
class PlayerTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var isActive: Bool = false
    
    private var timer: Timer?
    private let increment: TimeInterval
    
    init(initialTime: TimeInterval, increment: TimeInterval = 0) {
        self.timeRemaining = initialTime
        self.increment = increment
    }
    
    func start() {
        guard !isActive && timeRemaining > 0 else { return }
        
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.timeRemaining -= 0.1
            if self.timeRemaining <= 0 {
                self.timeRemaining = 0
                self.stop()
            }
        }
    }
    
    func stop() {
        isActive = false
        timer?.invalidate()
        timer = nil
        
        // Add increment when stopping (after making a move)
        if increment > 0 {
            timeRemaining += increment
        }
    }
    
    func reset(to time: TimeInterval) {
        stop()
        timeRemaining = time
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        let tenths = Int((timeRemaining.truncatingRemainder(dividingBy: 1)) * 10)
        
        if timeRemaining >= 60 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%d.%d", seconds, tenths)
        }
    }
    
    var isLowTime: Bool {
        return timeRemaining <= 30 && timeRemaining > 0
    }
    
    var isTimeUp: Bool {
        return timeRemaining <= 0
    }
}

// MARK: - Game Manager
class GameManager: ObservableObject {
    @Published var chessEngine = ChessEngine()
    @Published var gameMode: GameMode = .humanVsHuman
    @Published var timeControl: TimeControl = .unlimited
    @Published var aiDifficulty: AIDifficulty = .medium
    @Published var whiteTimer: PlayerTimer
    @Published var blackTimer: PlayerTimer
    @Published var isGameActive: Bool = false
    @Published var selectedSquare: ChessPosition?
    @Published var highlightedSquares: Set<ChessPosition> = []
    @Published var lastMove: ChessMove?
    @Published var showPromotionDialog: Bool = false
    @Published var promotionSquare: ChessPosition?
    
    // AI Integration
    private var stockfishEngine: StockfishEngine?
    private var isAIThinking: Bool = false
    
    // Game Settings
    @Published var boardTheme: BoardTheme = .classic
    @Published var pieceStyle: PieceStyle = .traditional
    @Published var soundEnabled: Bool = true
    @Published var showCoordinates: Bool = true
    @Published var autoQueen: Bool = false
    
    init() {
        self.whiteTimer = PlayerTimer(initialTime: 0)
        self.blackTimer = PlayerTimer(initialTime: 0)
        setupTimers()
    }
    
    // MARK: - Game Setup
    func startNewGame(mode: GameMode, timeControl: TimeControl, aiDifficulty: AIDifficulty = .medium) {
        self.gameMode = mode
        self.timeControl = timeControl
        self.aiDifficulty = aiDifficulty
        
        // Reset chess engine
        chessEngine.setupInitialPosition()
        
        // Setup timers
        setupTimers()
        
        // Initialize AI if needed
        if mode == .humanVsAI {
            initializeAI()
        }
        
        // Reset UI state
        selectedSquare = nil
        highlightedSquares = []
        lastMove = nil
        showPromotionDialog = false
        promotionSquare = nil
        
        isGameActive = true
        
        // Start white's timer if using time control
        if timeControl != .unlimited {
            whiteTimer.start()
        }
    }
    
    private func setupTimers() {
        let initialTime = timeControl.initialTime
        let increment = timeControl.increment
        
        whiteTimer = PlayerTimer(initialTime: initialTime, increment: increment)
        blackTimer = PlayerTimer(initialTime: initialTime, increment: increment)
    }
    
    private func initializeAI() {
        stockfishEngine = StockfishEngine()
        stockfishEngine?.setDifficulty(aiDifficulty.stockfishDepth)
    }
    
    // MARK: - Move Handling
    func handleSquareTap(_ position: ChessPosition) {
        guard isGameActive else { return }
        
        // Don't allow moves during AI thinking
        if gameMode == .humanVsAI && isAIThinking {
            return
        }
        
        // Don't allow moves for AI's turn
        if gameMode == .humanVsAI && chessEngine.currentPlayer == .black {
            return
        }
        
        if let selected = selectedSquare {
            if selected == position {
                // Deselect if tapping the same square
                deselectSquare()
            } else if chessEngine.isValidMove(from: selected, to: position) {
                // Attempt to make the move
                attemptMove(from: selected, to: position)
            } else if let piece = chessEngine.board[position.file][position.rank],
                      piece.color == chessEngine.currentPlayer {
                // Select a different piece
                selectSquare(position)
            } else {
                // Invalid move, deselect
                deselectSquare()
            }
        } else {
            // Select a square if it has a piece of the current player
            if let piece = chessEngine.board[position.file][position.rank],
               piece.color == chessEngine.currentPlayer {
                selectSquare(position)
            }
        }
    }
    
    private func selectSquare(_ position: ChessPosition) {
        selectedSquare = position
        highlightedSquares = Set(chessEngine.getLegalMoves(from: position))
        
        // Play selection sound
        if soundEnabled {
            playSound(.select)
        }
    }
    
    private func deselectSquare() {
        selectedSquare = nil
        highlightedSquares = []
    }
    
    private func attemptMove(from: ChessPosition, to: ChessPosition) {
        // Check for pawn promotion
        if let piece = chessEngine.board[from.file][from.rank],
           piece.type == .pawn && (to.rank == 0 || to.rank == 7) {
            if autoQueen {
                executeMove(from: from, to: to, promotion: .queen)
            } else {
                // Show promotion dialog
                promotionSquare = to
                showPromotionDialog = true
                return
            }
        } else {
            executeMove(from: from, to: to)
        }
    }
    
    func executeMove(from: ChessPosition, to: ChessPosition, promotion: PieceType? = nil) {
        let wasSuccessful = chessEngine.makeMove(from: from, to: to, promotionPiece: promotion)
        
        if wasSuccessful {
            // Update UI state
            lastMove = chessEngine.moveHistory.last
            deselectSquare()
            showPromotionDialog = false
            promotionSquare = nil
            
            // Handle timer switching
            switchTimers()
            
            // Play move sound
            if soundEnabled {
                playMoveSound()
            }
            
            // Check game end conditions
            checkGameEnd()
            
            // Trigger AI move if needed
            if gameMode == .humanVsAI && chessEngine.currentPlayer == .black && isGameActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.makeAIMove()
                }
            }
        }
    }
    
    // MARK: - Timer Management
    private func switchTimers() {
        if timeControl == .unlimited { return }
        
        if chessEngine.currentPlayer == .white {
            blackTimer.stop()
            whiteTimer.start()
        } else {
            whiteTimer.stop()
            blackTimer.start()
        }
    }
    
    // MARK: - AI Integration
    private func makeAIMove() {
        guard gameMode == .humanVsAI && chessEngine.currentPlayer == .black && isGameActive else { return }
        
        isAIThinking = true
        
        Task {
            do {
                let bestMove = try await stockfishEngine?.getBestMove(
                    fen: chessEngine.getFEN(),
                    thinkingTime: aiDifficulty.thinkingTime
                )
                
                await MainActor.run {
                    if let move = bestMove,
                       let from = ChessPosition(algebraic: String(move.prefix(2))),
                       let to = ChessPosition(algebraic: String(move.suffix(2))) {
                        
                        // Handle promotion
                        var promotion: PieceType?
                        if move.count > 4 {
                            let promotionChar = move.suffix(1).lowercased()
                            promotion = PieceType(rawValue: promotionChar)
                        }
                        
                        executeMove(from: from, to: to, promotion: promotion)
                    }
                    
                    isAIThinking = false
                }
            } catch {
                await MainActor.run {
                    isAIThinking = false
                    // Handle AI error - maybe make a random legal move
                    makeRandomMove()
                }
            }
        }
    }
    
    private func makeRandomMove() {
        let legalMoves = chessEngine.getAllLegalMoves(for: chessEngine.currentPlayer)
        if let randomMove = legalMoves.randomElement() {
            executeMove(from: randomMove.from, to: randomMove.to)
        }
    }
    
    // MARK: - Game End Handling
    private func checkGameEnd() {
        // Check timer expiration
        if timeControl != .unlimited {
            if whiteTimer.isTimeUp {
                chessEngine.gameState = .resigned(.black)
                endGame()
                return
            } else if blackTimer.isTimeUp {
                chessEngine.gameState = .resigned(.white)
                endGame()
                return
            }
        }
        
        // Check chess game state
        switch chessEngine.gameState {
        case .checkmate(_), .stalemate, .draw, .resigned(_):
            endGame()
        default:
            break
        }
    }
    
    private func endGame() {
        isGameActive = false
        whiteTimer.stop()
        blackTimer.stop()
        
        // Save game to history
        saveGameToHistory()
        
        // Play game end sound
        if soundEnabled {
            playGameEndSound()
        }
    }
    
    // MARK: - Sound Effects
    private func playSound(_ sound: SoundEffect) {
        // Implementation for sound effects
        // This would use AVAudioPlayer or similar
    }
    
    private func playMoveSound() {
        if let lastMove = lastMove {
            if lastMove.capturedPiece != nil {
                playSound(.capture)
            } else if lastMove.isCastling {
                playSound(.castle)
            } else if lastMove.isCheck {
                playSound(.check)
            } else {
                playSound(.move)
            }
        }
    }
    
    private func playGameEndSound() {
        switch chessEngine.gameState {
        case .checkmate(_):
            playSound(.checkmate)
        case .stalemate, .draw:
            playSound(.draw)
        default:
            playSound(.gameEnd)
        }
    }
    
    // MARK: - Game History
    private func saveGameToHistory() {
        let gameStorage = GameStorage.shared
        gameStorage.saveGame(
            moves: chessEngine.moveHistory,
            result: getGameResult(),
            timeControl: timeControl,
            gameMode: gameMode,
            aiDifficulty: gameMode == .humanVsAI ? aiDifficulty : nil
        )
    }
    
    private func getGameResult() -> String {
        switch chessEngine.gameState {
        case .checkmate(let winner):
            return winner == .white ? "1-0" : "0-1"
        case .resigned(let winner):
            return winner == .white ? "1-0" : "0-1"
        case .stalemate, .draw:
            return "1/2-1/2"
        default:
            return "*"
        }
    }
    
    // MARK: - Game Control
    func pauseGame() {
        whiteTimer.stop()
        blackTimer.stop()
        isGameActive = false
    }
    
    func resumeGame() {
        isGameActive = true
        if timeControl != .unlimited {
            if chessEngine.currentPlayer == .white {
                whiteTimer.start()
            } else {
                blackTimer.start()
            }
        }
    }
    
    func resignGame() {
        chessEngine.resign(color: chessEngine.currentPlayer)
        endGame()
    }
    
    func offerDraw() {
        chessEngine.offerDraw()
        endGame()
    }
}

// MARK: - Supporting Types
enum SoundEffect {
    case move
    case capture
    case castle
    case check
    case checkmate
    case draw
    case gameEnd
    case select
}

enum BoardTheme: String, CaseIterable {
    case classic = "Classic"
    case modern = "Modern"
    case wood = "Wood"
    case marble = "Marble"
    
    var lightSquareColor: Color {
        switch self {
        case .classic: return Color(red: 0.93, green: 0.93, blue: 0.82)
        case .modern: return Color(red: 0.85, green: 0.85, blue: 0.85)
        case .wood: return Color(red: 0.96, green: 0.87, blue: 0.70)
        case .marble: return Color(red: 0.95, green: 0.95, blue: 0.95)
        }
    }
    
    var darkSquareColor: Color {
        switch self {
        case .classic: return Color(red: 0.46, green: 0.59, blue: 0.34)
        case .modern: return Color(red: 0.45, green: 0.45, blue: 0.45)
        case .wood: return Color(red: 0.65, green: 0.42, blue: 0.24)
        case .marble: return Color(red: 0.65, green: 0.65, blue: 0.65)
        }
    }
}

enum PieceStyle: String, CaseIterable {
    case traditional = "Traditional"
    case modern = "Modern"
    case minimalist = "Minimalist"
}
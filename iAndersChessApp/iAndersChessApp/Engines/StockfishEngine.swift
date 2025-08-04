import Foundation

// MARK: - Stockfish Engine Wrapper
class StockfishEngine: ObservableObject {
    private var stockfishProcess: Process?
    private var inputPipe: Pipe?
    private var outputPipe: Pipe?
    private var errorPipe: Pipe?
    
    private var isInitialized = false
    private var currentDepth = 8
    private var currentEvaluation: Double = 0.0
    
    // Engine settings
    private var skillLevel = 20 // Maximum skill (0-20)
    private var threads = 1
    private var hash = 128 // MB
    
    // AI Personality integration
    @Published var currentPersonality: AIPersonality?
    private var decisionEngine: AIDecisionEngine?
    private var moveCount: Int = 0
    
    @Published var isThinking = false
    @Published var evaluation: Double = 0.0
    @Published var bestLine: [String] = []
    @Published var depth: Int = 0
    
    init() {
        initializeEngine()
    }
    
    deinit {
        stopEngine()
    }
    
    // MARK: - Engine Initialization
    private func initializeEngine() {
        guard !isInitialized else { return }
        
        // For this implementation, we'll use a simplified approach
        // In a real app, you would compile Stockfish as a C++ library
        // and link it with your iOS project
        
        isInitialized = true
        
        // Initialize with default settings
        configureEngine()
    }
    
    private func configureEngine() {
        // Configure engine parameters
        setOption("Skill Level", value: "\(skillLevel)")
        setOption("Threads", value: "\(threads)")
        setOption("Hash", value: "\(hash)")
    }
    
    private func setOption(_ name: String, value: String) {
        // In a real implementation, this would send UCI commands to Stockfish
        // For now, we'll simulate the configuration
    }
    
    private func stopEngine() {
        stockfishProcess?.terminate()
        stockfishProcess = nil
        inputPipe = nil
        outputPipe = nil
        errorPipe = nil
        isInitialized = false
    }
    
    // MARK: - Engine Configuration
    func setDifficulty(_ depth: Int) {
        currentDepth = max(1, min(depth, 20))
        
        // Adjust skill level based on depth
        let newSkillLevel = min(20, max(0, depth + 4))
        if newSkillLevel != skillLevel {
            skillLevel = newSkillLevel
            setOption("Skill Level", value: "\(skillLevel)")
        }
    }
    
    func setSkillLevel(_ level: Int) {
        skillLevel = max(0, min(level, 20))
        setOption("Skill Level", value: "\(skillLevel)")
    }
    
    func setThreads(_ threadCount: Int) {
        threads = max(1, min(threadCount, 8))
        setOption("Threads", value: "\(threads)")
    }
    
    func setHashSize(_ sizeInMB: Int) {
        hash = max(1, min(sizeInMB, 1024))
        setOption("Hash", value: "\(hash)")
    }
    
    // MARK: - Move Analysis
    func getBestMove(fen: String, thinkingTime: TimeInterval = 1.0) async throws -> String? {
        guard isInitialized else {
            throw StockfishError.engineNotInitialized
        }
        
        isThinking = true
        defer { isThinking = false }
        
        // Simulate thinking time
        try await Task.sleep(nanoseconds: UInt64(thinkingTime * 1_000_000_000))
        
        // For demonstration, we'll use a simplified move generation
        // In a real implementation, this would interface with the actual Stockfish engine
        let bestMove = await generateBestMove(from: fen)
        
        return bestMove
    }
    
    private func generateBestMove(from fen: String) async -> String? {
        // This is a placeholder implementation
        // In a real app, you would:
        // 1. Send "position fen [fen]" to Stockfish
        // 2. Send "go depth [depth]" or "go movetime [time]"
        // 3. Parse the "bestmove" response
        
        // For now, we'll return a simple move based on basic heuristics
        return await simulateStockfishMove(fen: fen)
    }
    
    private func simulateStockfishMove(fen: String) async -> String? {
        // Parse FEN to get current position
        let chessEngine = ChessEngine()
        
        // Get all legal moves for current player
        let currentPlayer: PieceColor = fen.contains(" w ") ? .white : .black
        let legalMoves = chessEngine.getAllLegalMoves(for: currentPlayer)
        
        if legalMoves.isEmpty {
            return nil
        }
        
        // Update game state for personality engine
        if let decisionEngine = decisionEngine {
            decisionEngine.updateGameState(fen: fen, moveCount: moveCount)
        }
        
        let move: (from: ChessPosition, to: ChessPosition)
        
        // Use personality-based decision making if available
        if let personality = currentPersonality, let decisionEngine = decisionEngine {
            // Adjust thinking time based on personality
            let baseThinkingTime = 1.0
            let personalityThinkingTime = decisionEngine.getThinkingTime(baseTime: baseThinkingTime)
            
            // Simulate thinking time
            try? await Task.sleep(nanoseconds: UInt64(personalityThinkingTime * 0.5 * 1_000_000_000))
            
            move = selectPersonalityBasedMove(from: legalMoves, fen: fen, engine: chessEngine, decisionEngine: decisionEngine)
        } else {
            // Fallback to skill-based selection
            switch skillLevel {
            case 0...5:
                // Beginner: Random moves
                move = legalMoves.randomElement()!
            case 6...10:
                // Easy: Prefer captures
                let captures = legalMoves.filter { chessEngine.board[$0.to.file][$0.to.rank] != nil }
                move = captures.randomElement() ?? legalMoves.randomElement()!
            case 11...15:
                // Medium: Basic tactics
                move = selectTacticalMove(from: legalMoves, engine: chessEngine) ?? legalMoves.randomElement()!
            default:
                // Hard: Best available move (simplified)
                move = selectBestMove(from: legalMoves, engine: chessEngine)
            }
        }
        
        moveCount += 1
        return "\(move.from.algebraic)\(move.to.algebraic)"
    }
    
    private func selectPersonalityBasedMove(
        from legalMoves: [(from: ChessPosition, to: ChessPosition)],
        fen: String,
        engine: ChessEngine,
        decisionEngine: AIDecisionEngine
    ) -> (from: ChessPosition, to: ChessPosition) {
        
        // Convert moves to string format and evaluate each
        var candidates: [String] = []
        var evaluations: [Double] = []
        
        for move in legalMoves {
            let moveString = "\(move.from.algebraic)\(move.to.algebraic)"
            candidates.append(moveString)
            
            // Evaluate position after this move
            let testEngine = ChessEngine()
            testEngine.board = engine.board
            testEngine.currentPlayer = engine.currentPlayer
            
            if testEngine.makeMove(from: move.from, to: move.to) {
                let newFEN = testEngine.getFEN()
                let baseEval = evaluatePositionSimple(newFEN)
                let personalityEval = decisionEngine.evaluatePosition(newFEN, baseEvaluation: baseEval)
                evaluations.append(personalityEval)
            } else {
                evaluations.append(-999.0) // Invalid move
            }
        }
        
        // Let the decision engine choose the move
        let selectedMoveString = decisionEngine.selectMove(candidates: candidates, evaluations: evaluations)
        
        // Find the corresponding move
        for (index, candidate) in candidates.enumerated() {
            if candidate == selectedMoveString {
                return legalMoves[index]
            }
        }
        
        // Fallback to random move
        return legalMoves.randomElement()!
    }
    
    private func selectTacticalMove(from moves: [(from: ChessPosition, to: ChessPosition)], engine: ChessEngine) -> (from: ChessPosition, to: ChessPosition)? {
        // Look for captures of higher-value pieces
        var bestMove: (from: ChessPosition, to: ChessPosition)?
        var bestValue = 0
        
        for move in moves {
            if let capturedPiece = engine.board[move.to.file][move.to.rank] {
                let value = capturedPiece.type.value
                if value > bestValue {
                    bestValue = value
                    bestMove = move
                }
            }
        }
        
        return bestMove
    }
    
    private func selectBestMove(from moves: [(from: ChessPosition, to: ChessPosition)], engine: ChessEngine) -> (from: ChessPosition, to: ChessPosition) {
        // Simplified evaluation - prefer center control and captures
        var bestMove = moves.first!
        var bestScore = -1000.0
        
        for move in moves {
            let score = evaluateMove(move, engine: engine)
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        return bestMove
    }
    
    private func evaluateMove(_ move: (from: ChessPosition, to: ChessPosition), engine: ChessEngine) -> Double {
        var score = 0.0
        
        // Capture value
        if let capturedPiece = engine.board[move.to.file][move.to.rank] {
            score += Double(capturedPiece.type.value * 10)
        }
        
        // Center control
        let centerFiles = [3, 4]
        let centerRanks = [3, 4]
        if centerFiles.contains(move.to.file) && centerRanks.contains(move.to.rank) {
            score += 5.0
        }
        
        // Piece development (move from back rank)
        if let piece = engine.board[move.from.file][move.from.rank] {
            if piece.color == .white && move.from.rank == 0 && move.to.rank > 0 {
                score += 3.0
            } else if piece.color == .black && move.from.rank == 7 && move.to.rank < 7 {
                score += 3.0
            }
        }
        
        return score
    }
    
    // MARK: - Position Evaluation
    func evaluatePosition(fen: String) async throws -> Double {
        guard isInitialized else {
            throw StockfishError.engineNotInitialized
        }
        
        // Simulate evaluation
        let evaluation = await calculatePositionEvaluation(fen: fen)
        
        DispatchQueue.main.async {
            self.evaluation = evaluation
        }
        
        return evaluation
    }
    
    private func calculatePositionEvaluation(fen: String) async -> Double {
        // Simple material evaluation
        let chessEngine = ChessEngine()
        var evaluation = 0.0
        
        for file in 0..<8 {
            for rank in 0..<8 {
                if let piece = chessEngine.board[file][rank] {
                    let value = Double(piece.type.value)
                    if piece.color == .white {
                        evaluation += value
                    } else {
                        evaluation -= value
                    }
                }
            }
        }
        
        // Add positional factors
        evaluation += evaluatePositionalFactors(engine: chessEngine)
        
        // Normalize to centipawns (-10.0 to +10.0 range)
        return max(-10.0, min(10.0, evaluation / 10.0))
    }
    
    private func evaluatePositionalFactors(engine: ChessEngine) -> Double {
        var positional = 0.0
        
        // Center control
        let centerSquares = [(3,3), (3,4), (4,3), (4,4)]
        for (file, rank) in centerSquares {
            if let piece = engine.board[file][rank] {
                positional += piece.color == .white ? 0.5 : -0.5
            }
        }
        
        // King safety (simplified)
        if let whiteKing = engine.findKing(color: .white) {
            if whiteKing.rank == 0 && (whiteKing.file == 1 || whiteKing.file == 6) {
                positional += 1.0 // Castled king
            }
        }
        
        if let blackKing = engine.findKing(color: .black) {
            if blackKing.rank == 7 && (blackKing.file == 1 || blackKing.file == 6) {
                positional -= 1.0 // Castled king
            }
        }
        
        return positional
    }
    
    // MARK: - Analysis
    func analyzePosition(fen: String, depth: Int = 15) async throws -> PositionAnalysis {
        guard isInitialized else {
            throw StockfishError.engineNotInitialized
        }
        
        isThinking = true
        defer { isThinking = false }
        
        // Simulate analysis
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let evaluation = try await evaluatePosition(fen: fen)
        let bestMove = try await getBestMove(fen: fen, thinkingTime: 2.0)
        
        return PositionAnalysis(
            evaluation: evaluation,
            bestMove: bestMove ?? "",
            principalVariation: bestMove.map { [$0] } ?? [],
            depth: depth,
            nodes: 100000, // Simulated
            time: 1.0
        )
    }
    
    func getMultipleBestMoves(fen: String, count: Int = 3) async throws -> [String] {
        guard isInitialized else {
            throw StockfishError.engineNotInitialized
        }
        
        // For simplicity, we'll return the best move multiple times
        // In a real implementation, you would use the "multipv" option
        if let bestMove = try await getBestMove(fen: fen) {
            return Array(repeating: bestMove, count: min(count, 1))
        }
        
        return []
    }
}

// MARK: - Supporting Types
enum StockfishError: Error {
    case engineNotInitialized
    case invalidFEN
    case engineTimeout
    case communicationError
    
    var localizedDescription: String {
        switch self {
        case .engineNotInitialized:
            return "Chess engine is not initialized"
        case .invalidFEN:
            return "Invalid FEN string provided"
        case .engineTimeout:
            return "Engine response timeout"
        case .communicationError:
            return "Communication error with chess engine"
        }
    }
}

struct PositionAnalysis {
    let evaluation: Double
    let bestMove: String
    let principalVariation: [String]
    let depth: Int
    let nodes: Int
    let time: TimeInterval
    
    var evaluationString: String {
        if abs(evaluation) > 5.0 {
            let mateIn = Int(10.0 - abs(evaluation))
            return evaluation > 0 ? "M\(mateIn)" : "-M\(mateIn)"
        } else {
            let centipawns = Int(evaluation * 100)
            return centipawns >= 0 ? "+\(centipawns)" : "\(centipawns)"
        }
    }
}

// MARK: - Extension for ChessEngine
extension ChessEngine {
    func findKing(color: PieceColor) -> ChessPosition? {
        for file in 0..<8 {
            for rank in 0..<8 {
                if let piece = board[file][rank], piece.type == .king && piece.color == color {
                    return ChessPosition(file, rank)
                }
            }
        }
        return nil
    }
    
    // MARK: - Personality Integration
    func getPersonalityComment() -> String? {
        return decisionEngine?.getRandomComment()
    }
    
    func getVictoryMessage() -> String {
        return decisionEngine?.getVictoryMessage() ?? "Good game!"
    }
    
    func getDefeatMessage() -> String {
        return decisionEngine?.getDefeatMessage() ?? "Well played!"
    }
    
    func resetMoveCount() {
        moveCount = 0
    }
    
    // MARK: - Personality Management
    func setPersonality(_ personality: AIPersonality) {
        currentPersonality = personality
        decisionEngine = AIDecisionEngine(personality: personality)
        
        // Adjust engine settings based on personality
        skillLevel = personality.skillLevel
        currentDepth = max(3, min(15, Int(Double(personality.skillLevel) * 0.75)))
        
        configureEngine()
        resetMoveCount()
    }
    
    func getPersonalityForDifficulty(_ difficulty: AIDifficulty) -> AIPersonality {
        switch difficulty {
        case .beginner:
            return AIPersonality.getRandomPersonality(skillRange: 1...5)
        case .easy:
            return AIPersonality.getRandomPersonality(skillRange: 6...10)
        case .intermediate:
            return AIPersonality.getRandomPersonality(skillRange: 11...15)
        case .hard:
            return AIPersonality.getRandomPersonality(skillRange: 16...18)
        case .expert:
            return AIPersonality.getRandomPersonality(skillRange: 19...20)
        }
    }
}
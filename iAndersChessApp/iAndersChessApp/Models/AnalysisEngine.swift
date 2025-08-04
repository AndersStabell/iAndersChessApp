import Foundation
import SwiftUI

// MARK: - Move Quality
enum MoveQuality: String, CaseIterable {
    case brilliant = "!!"
    case excellent = "!"
    case good = ""
    case inaccuracy = "?!"
    case mistake = "?"
    case blunder = "??"
    case forced = "□"
    case theoretical = "TN"
    
    var color: Color {
        switch self {
        case .brilliant: return .purple
        case .excellent: return .green
        case .good: return .primary
        case .inaccuracy: return .yellow
        case .mistake: return .orange
        case .blunder: return .red
        case .forced: return .blue
        case .theoretical: return .cyan
        }
    }
    
    var description: String {
        switch self {
        case .brilliant: return "Brilliant move - finds the best continuation"
        case .excellent: return "Excellent move - very strong choice"
        case .good: return "Good move - solid choice"
        case .inaccuracy: return "Inaccuracy - slightly imprecise"
        case .mistake: return "Mistake - loses advantage"
        case .blunder: return "Blunder - major error"
        case .forced: return "Forced move - only reasonable option"
        case .theoretical: return "Theoretical novelty"
        }
    }
}

// MARK: - Analysis Result
struct MoveAnalysis {
    let move: ChessMove
    let evaluation: Double
    let bestMove: String?
    let quality: MoveQuality
    let principalVariation: [String]
    let alternativeLines: [AnalysisLine]
    let timeSpent: TimeInterval
    let depth: Int
    let comment: String?
    
    var evaluationDifference: Double {
        // Difference from best move evaluation
        return 0.0 // Would be calculated based on best move
    }
}

struct AnalysisLine {
    let moves: [String]
    let evaluation: Double
    let comment: String?
    
    var moveString: String {
        return moves.prefix(5).joined(separator: " ")
    }
}

// MARK: - Position Analysis
struct PositionAnalysis {
    let fen: String
    let evaluation: Double
    let bestMoves: [String]
    let principalVariation: [String]
    let alternativeLines: [AnalysisLine]
    let positionThemes: [PositionTheme]
    let tacticalMotifs: [TacticalMotif]
    let pawnStructure: PawnStructureAnalysis
    let kingSafety: KingSafetyAnalysis
    let pieceActivity: PieceActivityAnalysis
    let endgameType: EndgameType?
    
    var isWinning: Bool { abs(evaluation) > 3.0 }
    var isDrawish: Bool { abs(evaluation) < 0.5 }
    var isTactical: Bool { !tacticalMotifs.isEmpty }
}

// MARK: - Position Themes
enum PositionTheme: String, CaseIterable {
    case openGame = "Open Game"
    case closedGame = "Closed Game"
    case attackingPosition = "Attacking Position"
    case defensivePosition = "Defensive Position"
    case endgame = "Endgame"
    case middlegame = "Middlegame"
    case opening = "Opening"
    case pawnStorm = "Pawn Storm"
    case pieceActivity = "Piece Activity"
    case kingSafety = "King Safety"
    case centerControl = "Center Control"
    case development = "Development"
    
    var color: Color {
        switch self {
        case .attackingPosition: return .red
        case .defensivePosition: return .blue
        case .endgame: return .purple
        case .middlegame: return .orange
        case .opening: return .green
        default: return .gray
        }
    }
}

// MARK: - Tactical Motifs
enum TacticalMotif: String, CaseIterable {
    case pin = "Pin"
    case fork = "Fork"
    case skewer = "Skewer"
    case discoveredAttack = "Discovered Attack"
    case doubleAttack = "Double Attack"
    case sacrifice = "Sacrifice"
    case deflection = "Deflection"
    case decoy = "Decoy"
    case clearance = "Clearance"
    case interference = "Interference"
    case xRay = "X-Ray"
    case zugzwang = "Zugzwang"
    case backRankMate = "Back Rank Mate"
    case smotheredMate = "Smothered Mate"
    
    var icon: String {
        switch self {
        case .pin: return "pin.fill"
        case .fork: return "arrow.branch"
        case .skewer: return "arrow.right.arrow.left"
        case .discoveredAttack: return "eye.trianglebadge.exclamationmark"
        case .doubleAttack: return "multiply.circle"
        case .sacrifice: return "flame.fill"
        default: return "star.fill"
        }
    }
}

// MARK: - Specialized Analysis
struct PawnStructureAnalysis {
    let isolatedPawns: [ChessPosition]
    let doubledPawns: [ChessPosition]
    let backwardPawns: [ChessPosition]
    let passedPawns: [ChessPosition]
    let pawnChains: [[ChessPosition]]
    let pawnIslands: Int
    let evaluation: Double
    
    var hasWeaknesses: Bool {
        return !isolatedPawns.isEmpty || !doubledPawns.isEmpty || !backwardPawns.isEmpty
    }
}

struct KingSafetyAnalysis {
    let whiteKingSafety: Double
    let blackKingSafety: Double
    let attackingPieces: [ChessPosition]
    let defendingPieces: [ChessPosition]
    let openFiles: [Int]
    let castlingRights: String
    
    var isUnderAttack: Bool {
        return !attackingPieces.isEmpty
    }
}

struct PieceActivityAnalysis {
    let activePieces: [ChessPosition]
    let passivePieces: [ChessPosition]
    let pieceCoordination: Double
    let spaceAdvantage: Double
    
    var overallActivity: Double {
        return pieceCoordination + spaceAdvantage
    }
}

enum EndgameType: String, CaseIterable {
    case kingPawn = "King and Pawn"
    case rookEndgame = "Rook Endgame"
    case queenEndgame = "Queen Endgame"
    case bishopEndgame = "Bishop Endgame"
    case knightEndgame = "Knight Endgame"
    case minorPiece = "Minor Piece Endgame"
    case opposite = "Opposite-Colored Bishops"
    case theoretical = "Theoretical Endgame"
}

// MARK: - Analysis Engine
class AnalysisEngine: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0.0
    @Published var currentAnalysis: PositionAnalysis?
    @Published var gameAnalysis: [MoveAnalysis] = []
    
    private let stockfishEngine: StockfishEngine
    private let openingDatabase = OpeningDatabase.shared
    
    init() {
        self.stockfishEngine = StockfishEngine()
    }
    
    // MARK: - Position Analysis
    func analyzePosition(_ fen: String, depth: Int = 20) async -> PositionAnalysis {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        // Get engine evaluation
        let evaluation = try? await stockfishEngine.evaluatePosition(fen: fen)
        let bestMoves = try? await stockfishEngine.getMultipleBestMoves(fen: fen, count: 3)
        
        // Analyze position characteristics
        let themes = analyzePositionThemes(fen)
        let tactics = analyzeTacticalMotifs(fen)
        let pawnStructure = analyzePawnStructure(fen)
        let kingSafety = analyzeKingSafety(fen)
        let pieceActivity = analyzePieceActivity(fen)
        let endgameType = determineEndgameType(fen)
        
        // Generate alternative lines
        let alternatives = await generateAlternativeLines(fen, depth: depth)
        
        return PositionAnalysis(
            fen: fen,
            evaluation: evaluation ?? 0.0,
            bestMoves: bestMoves ?? [],
            principalVariation: [],
            alternativeLines: alternatives,
            positionThemes: themes,
            tacticalMotifs: tactics,
            pawnStructure: pawnStructure,
            kingSafety: kingSafety,
            pieceActivity: pieceActivity,
            endgameType: endgameType
        )
    }
    
    // MARK: - Game Analysis
    func analyzeGame(_ moves: [ChessMove]) async -> [MoveAnalysis] {
        isAnalyzing = true
        gameAnalysis = []
        
        let engine = ChessEngine()
        engine.setupInitialPosition()
        
        var analysisResults: [MoveAnalysis] = []
        
        for (index, move) in moves.enumerated() {
            // Update progress
            await MainActor.run {
                analysisProgress = Double(index) / Double(moves.count)
            }
            
            // Analyze position before move
            let positionFEN = engine.getFEN()
            let analysis = await analyzeSingleMove(move, position: positionFEN, moveNumber: index + 1)
            analysisResults.append(analysis)
            
            // Make the move
            _ = engine.makeMove(from: move.from, to: move.to, promotionPiece: move.promotionPiece)
        }
        
        await MainActor.run {
            gameAnalysis = analysisResults
            isAnalyzing = false
            analysisProgress = 1.0
        }
        
        return analysisResults
    }
    
    private func analyzeSingleMove(_ move: ChessMove, position: String, moveNumber: Int) async -> MoveAnalysis {
        // Get best move for position
        let bestMove = try? await stockfishEngine.getBestMove(fen: position, thinkingTime: 2.0)
        let evaluation = try? await stockfishEngine.evaluatePosition(fen: position)
        
        // Determine move quality
        let quality = evaluateMoveQuality(move, bestMove: bestMove, evaluation: evaluation ?? 0.0)
        
        // Generate principal variation
        let pv = await generatePrincipalVariation(position, depth: 10)
        
        // Generate alternatives
        let alternatives = await generateAlternativeLines(position, depth: 8)
        
        return MoveAnalysis(
            move: move,
            evaluation: evaluation ?? 0.0,
            bestMove: bestMove,
            quality: quality,
            principalVariation: pv,
            alternativeLines: alternatives,
            timeSpent: 2.0,
            depth: 15,
            comment: generateMoveComment(quality: quality, move: move)
        )
    }
    
    // MARK: - Analysis Helpers
    private func analyzePositionThemes(_ fen: String) -> [PositionTheme] {
        var themes: [PositionTheme] = []
        
        // Simple heuristics for position themes
        let engine = ChessEngine()
        let moveCount = engine.moveHistory.count
        
        if moveCount < 20 {
            themes.append(.opening)
        } else if moveCount < 40 {
            themes.append(.middlegame)
        } else {
            themes.append(.endgame)
        }
        
        // Add more sophisticated analysis
        themes.append(.centerControl)
        themes.append(.development)
        
        return themes
    }
    
    private func analyzeTacticalMotifs(_ fen: String) -> [TacticalMotif] {
        var motifs: [TacticalMotif] = []
        
        // Simplified tactical detection
        // In a full implementation, this would use pattern recognition
        
        return motifs
    }
    
    private func analyzePawnStructure(_ fen: String) -> PawnStructureAnalysis {
        return PawnStructureAnalysis(
            isolatedPawns: [],
            doubledPawns: [],
            backwardPawns: [],
            passedPawns: [],
            pawnChains: [],
            pawnIslands: 2,
            evaluation: 0.0
        )
    }
    
    private func analyzeKingSafety(_ fen: String) -> KingSafetyAnalysis {
        return KingSafetyAnalysis(
            whiteKingSafety: 0.0,
            blackKingSafety: 0.0,
            attackingPieces: [],
            defendingPieces: [],
            openFiles: [],
            castlingRights: "KQkq"
        )
    }
    
    private func analyzePieceActivity(_ fen: String) -> PieceActivityAnalysis {
        return PieceActivityAnalysis(
            activePieces: [],
            passivePieces: [],
            pieceCoordination: 0.0,
            spaceAdvantage: 0.0
        )
    }
    
    private func determineEndgameType(_ fen: String) -> EndgameType? {
        // Count pieces to determine endgame type
        let pieceCount = fen.filter { "KQRBNPkqrbnp".contains($0) }.count
        
        if pieceCount <= 6 {
            return .kingPawn
        }
        
        return nil
    }
    
    private func evaluateMoveQuality(_ move: ChessMove, bestMove: String?, evaluation: Double) -> MoveQuality {
        // Simplified move quality evaluation
        guard let best = bestMove else { return .good }
        
        let moveString = "\(move.from.algebraic)\(move.to.algebraic)"
        
        if moveString == best {
            if abs(evaluation) > 3.0 {
                return .brilliant
            } else {
                return .excellent
            }
        }
        
        // In a full implementation, this would compare evaluations
        return .good
    }
    
    private func generatePrincipalVariation(_ fen: String, depth: Int) async -> [String] {
        // Generate principal variation
        return []
    }
    
    private func generateAlternativeLines(_ fen: String, depth: Int) async -> [AnalysisLine] {
        // Generate alternative move sequences
        return []
    }
    
    private func generateMoveComment(quality: MoveQuality, move: ChessMove) -> String? {
        switch quality {
        case .brilliant:
            return "Brilliant! This move finds the strongest continuation."
        case .excellent:
            return "Excellent move maintaining the advantage."
        case .inaccuracy:
            return "Slightly inaccurate, allowing the opponent counterplay."
        case .mistake:
            return "This move loses some advantage."
        case .blunder:
            return "A serious error that changes the evaluation significantly."
        default:
            return nil
        }
    }
    
    // MARK: - Analysis Export
    func exportAnalysisReport(_ analysis: [MoveAnalysis]) -> String {
        var report = "# Chess Game Analysis Report\n\n"
        
        report += "## Game Summary\n"
        report += "Total moves: \(analysis.count)\n"
        report += "Brilliant moves: \(analysis.filter { $0.quality == .brilliant }.count)\n"
        report += "Excellent moves: \(analysis.filter { $0.quality == .excellent }.count)\n"
        report += "Inaccuracies: \(analysis.filter { $0.quality == .inaccuracy }.count)\n"
        report += "Mistakes: \(analysis.filter { $0.quality == .mistake }.count)\n"
        report += "Blunders: \(analysis.filter { $0.quality == .blunder }.count)\n\n"
        
        report += "## Move-by-Move Analysis\n\n"
        
        for (index, moveAnalysis) in analysis.enumerated() {
            let moveNumber = (index / 2) + 1
            let isWhite = index % 2 == 0
            
            report += "\(moveNumber)\(isWhite ? "." : "...") \(moveAnalysis.move.moveNotation) \(moveAnalysis.quality.rawValue)\n"
            
            if let comment = moveAnalysis.comment {
                report += "  \(comment)\n"
            }
            
            if !moveAnalysis.principalVariation.isEmpty {
                report += "  Best line: \(moveAnalysis.principalVariation.prefix(5).joined(separator: " "))\n"
            }
            
            report += "\n"
        }
        
        return report
    }
}
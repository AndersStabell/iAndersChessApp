import Foundation
import SwiftUI

// MARK: - AI Personality Types
enum AIPersonalityType: String, CaseIterable, Codable {
    case aggressive = "Aggressive"
    case defensive = "Defensive"
    case positional = "Positional"
    case tactical = "Tactical"
    case balanced = "Balanced"
    case gambit = "Gambit Player"
    case endgame = "Endgame Specialist"
    case blitz = "Blitz Master"
    case classical = "Classical"
    case creative = "Creative"
    case solid = "Solid"
    case counterAttacker = "Counter-Attacker"
    
    var displayName: String {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .aggressive:
            return "Loves attacking the king and sacrificing material for initiative"
        case .defensive:
            return "Prefers solid positions and patient defensive play"
        case .positional:
            return "Focuses on long-term advantages and strategic planning"
        case .tactical:
            return "Seeks complex positions with tactical opportunities"
        case .balanced:
            return "Adapts playing style based on position requirements"
        case .gambit:
            return "Sacrifices pawns and pieces for rapid development and attack"
        case .endgame:
            return "Excels in simplified positions and technical endgames"
        case .blitz:
            return "Makes quick, intuitive moves with emphasis on time pressure"
        case .classical:
            return "Plays principled, textbook chess with deep calculation"
        case .creative:
            return "Seeks unusual and unexpected moves to confuse opponents"
        case .solid:
            return "Avoids risks and maintains stable, secure positions"
        case .counterAttacker:
            return "Absorbs pressure then launches devastating counterattacks"
        }
    }
    
    var icon: String {
        switch self {
        case .aggressive: return "flame.fill"
        case .defensive: return "shield.fill"
        case .positional: return "building.columns.fill"
        case .tactical: return "target"
        case .balanced: return "scale.3d"
        case .gambit: return "bolt.fill"
        case .endgame: return "crown.fill"
        case .blitz: return "timer"
        case .classical: return "book.fill"
        case .creative: return "lightbulb.fill"
        case .solid: return "lock.fill"
        case .counterAttacker: return "arrow.turn.up.right"
        }
    }
    
    var color: Color {
        switch self {
        case .aggressive: return .red
        case .defensive: return .blue
        case .positional: return .green
        case .tactical: return .orange
        case .balanced: return .purple
        case .gambit: return .yellow
        case .endgame: return .brown
        case .blitz: return .pink
        case .classical: return .indigo
        case .creative: return .cyan
        case .solid: return .gray
        case .counterAttacker: return .mint
        }
    }
}

// MARK: - Playing Style Preferences
struct PlayingStylePreferences: Codable {
    // Tactical vs Positional (0.0 = pure positional, 1.0 = pure tactical)
    let tacticalTendency: Double
    
    // Aggression level (0.0 = passive, 1.0 = hyper-aggressive)
    let aggressionLevel: Double
    
    // Risk tolerance (0.0 = risk-averse, 1.0 = risk-seeking)
    let riskTolerance: Double
    
    // Time usage (0.0 = quick moves, 1.0 = deep thinking)
    let timeUsage: Double
    
    // Piece activity preference (0.0 = safety first, 1.0 = maximum activity)
    let pieceActivityPreference: Double
    
    // King safety priority (0.0 = ignore safety, 1.0 = extreme caution)
    let kingSafetyPriority: Double
    
    // Pawn structure importance (0.0 = ignore structure, 1.0 = structure obsessed)
    let pawnStructureImportance: Double
    
    // Initiative preference (0.0 = reactive, 1.0 = always seeking initiative)
    let initiativePreference: Double
    
    // Material vs Position trade-off (0.0 = hoard material, 1.0 = sacrifice freely)
    let materialVsPositionBalance: Double
    
    // Opening diversity (0.0 = play same openings, 1.0 = try everything)
    let openingDiversity: Double
}

// MARK: - Evaluation Bonuses
struct EvaluationBonuses: Codable {
    // Piece-specific bonuses
    let knightOutpostBonus: Double
    let bishopPairBonus: Double
    let rookOnOpenFileBonus: Double
    let queenActivityBonus: Double
    
    // Positional bonuses
    let centerControlBonus: Double
    let kingSafetyBonus: Double
    let pawnStructureBonus: Double
    let pieceCoordinationBonus: Double
    
    // Tactical bonuses
    let attackingChancesBonus: Double
    let tacticalMotifBonus: Double
    let initiativeBonus: Double
    let sacrificeBonus: Double
    
    // Special situation bonuses
    let endgameBonus: Double
    let complexityBonus: Double
    let timeAdvantageBonus: Double
    let psychologicalBonus: Double
}

// MARK: - AI Personality
struct AIPersonality: Codable, Identifiable {
    let id = UUID()
    let name: String
    let type: AIPersonalityType
    let skillLevel: Int // 1-20
    let playingStyle: PlayingStylePreferences
    let evaluationBonuses: EvaluationBonuses
    let preferredOpenings: [String] // ECO codes or opening names
    let avoidedOpenings: [String]
    let motto: String
    let thinkingTimeMultiplier: Double // How long the AI "thinks"
    let blunderRate: Double // Probability of making mistakes
    let learningRate: Double // How quickly it adapts to opponent
    
    // Behavioral patterns
    let moveComments: [String] // Things the AI might "say"
    let victoryMessages: [String]
    let defeatMessages: [String]
    
    static let personalities: [AIPersonality] = [
        // Aggressive personalities
        AIPersonality(
            name: "Magnus the Destroyer",
            type: .aggressive,
            skillLevel: 18,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.8,
                aggressionLevel: 0.9,
                riskTolerance: 0.8,
                timeUsage: 0.7,
                pieceActivityPreference: 0.9,
                kingSafetyPriority: 0.3,
                pawnStructureImportance: 0.4,
                initiativePreference: 0.9,
                materialVsPositionBalance: 0.7,
                openingDiversity: 0.6
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 0.5,
                bishopPairBonus: 0.3,
                rookOnOpenFileBonus: 0.8,
                queenActivityBonus: 0.9,
                centerControlBonus: 0.6,
                kingSafetyBonus: 0.2,
                pawnStructureBonus: 0.3,
                pieceCoordinationBonus: 0.7,
                attackingChancesBonus: 1.2,
                tacticalMotifBonus: 1.0,
                initiativeBonus: 1.1,
                sacrificeBonus: 0.8,
                endgameBonus: 0.4,
                complexityBonus: 0.8,
                timeAdvantageBonus: 0.6,
                psychologicalBonus: 0.7
            ),
            preferredOpenings: ["B20", "C30", "C44", "B90"], // Sicilian, King's Gambit, Scotch, Najdorf
            avoidedOpenings: ["D30", "A04"], // QGD, Reti
            motto: "Attack or be attacked!",
            thinkingTimeMultiplier: 0.8,
            blunderRate: 0.15,
            learningRate: 0.3,
            moveComments: [
                "Time to unleash chaos!",
                "Your king looks vulnerable...",
                "This position screams for an attack!",
                "Material is temporary, glory is forever!"
            ],
            victoryMessages: [
                "Another victim falls to my attacking prowess!",
                "That's how you crush an opponent!",
                "Victory through superior firepower!"
            ],
            defeatMessages: [
                "You defended well... this time.",
                "Sometimes the attack fails, but never the spirit!",
                "I'll come back with an even fiercer attack!"
            ]
        ),
        
        // Defensive personalities
        AIPersonality(
            name: "Petra the Wall",
            type: .defensive,
            skillLevel: 16,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.3,
                aggressionLevel: 0.2,
                riskTolerance: 0.1,
                timeUsage: 0.9,
                pieceActivityPreference: 0.4,
                kingSafetyPriority: 0.9,
                pawnStructureImportance: 0.8,
                initiativePreference: 0.2,
                materialVsPositionBalance: 0.2,
                openingDiversity: 0.3
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 0.4,
                bishopPairBonus: 0.6,
                rookOnOpenFileBonus: 0.3,
                queenActivityBonus: 0.2,
                centerControlBonus: 0.7,
                kingSafetyBonus: 1.2,
                pawnStructureBonus: 1.0,
                pieceCoordinationBonus: 0.8,
                attackingChancesBonus: 0.1,
                tacticalMotifBonus: 0.3,
                initiativeBonus: 0.2,
                sacrificeBonus: 0.1,
                endgameBonus: 0.9,
                complexityBonus: 0.2,
                timeAdvantageBonus: 0.4,
                psychologicalBonus: 0.3
            ),
            preferredOpenings: ["C65", "D30", "B15"], // Berlin, QGD, Caro-Kann
            avoidedOpenings: ["C30", "B20"], // King's Gambit, Sicilian
            motto: "Patience is the strongest fortress.",
            thinkingTimeMultiplier: 1.3,
            blunderRate: 0.08,
            learningRate: 0.2,
            moveComments: [
                "Slow and steady wins the race.",
                "Your attack will break upon my defense.",
                "Every piece has its perfect square.",
                "Defense is the art of patience."
            ],
            victoryMessages: [
                "Your impatience was your downfall.",
                "Defense converts to victory!",
                "The wall holds, and now it strikes back!"
            ],
            defeatMessages: [
                "You found the crack in my armor.",
                "Even the strongest walls can fall.",
                "A good defense, but yours was better."
            ]
        ),
        
        // Tactical genius
        AIPersonality(
            name: "Mikhail the Tactician",
            type: .tactical,
            skillLevel: 19,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.95,
                aggressionLevel: 0.7,
                riskTolerance: 0.6,
                timeUsage: 0.6,
                pieceActivityPreference: 0.8,
                kingSafetyPriority: 0.4,
                pawnStructureImportance: 0.3,
                initiativePreference: 0.8,
                materialVsPositionBalance: 0.6,
                openingDiversity: 0.8
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 0.8,
                bishopPairBonus: 0.7,
                rookOnOpenFileBonus: 0.6,
                queenActivityBonus: 0.8,
                centerControlBonus: 0.5,
                kingSafetyBonus: 0.4,
                pawnStructureBonus: 0.2,
                pieceCoordinationBonus: 0.9,
                attackingChancesBonus: 0.9,
                tacticalMotifBonus: 1.5,
                initiativeBonus: 0.8,
                sacrificeBonus: 1.0,
                endgameBonus: 0.6,
                complexityBonus: 1.2,
                timeAdvantageBonus: 0.5,
                psychologicalBonus: 0.8
            ),
            preferredOpenings: ["B70", "C50", "B90"], // Dragon, Italian, Najdorf
            avoidedOpenings: ["D06", "A04"], // Queen's Gambit, Reti
            motto: "Every position hides a tactical secret.",
            thinkingTimeMultiplier: 0.7,
            blunderRate: 0.12,
            learningRate: 0.4,
            moveComments: [
                "I see a beautiful combination brewing...",
                "Tactics flow like water in this position!",
                "Your pieces are poorly coordinated.",
                "This calls for a tactical solution!"
            ],
            victoryMessages: [
                "The tactics spoke, and I listened!",
                "Beautiful combinations always win!",
                "That's the power of tactical vision!"
            ],
            defeatMessages: [
                "You out-calculated me this time.",
                "Sometimes even the best tactics fail.",
                "Your tactical awareness impressed me."
            ]
        ),
        
        // Positional master
        AIPersonality(
            name: "Anatoly the Architect",
            type: .positional,
            skillLevel: 17,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.2,
                aggressionLevel: 0.4,
                riskTolerance: 0.3,
                timeUsage: 1.0,
                pieceActivityPreference: 0.7,
                kingSafetyPriority: 0.7,
                pawnStructureImportance: 0.9,
                initiativePreference: 0.6,
                materialVsPositionBalance: 0.4,
                openingDiversity: 0.5
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 1.0,
                bishopPairBonus: 0.9,
                rookOnOpenFileBonus: 0.8,
                queenActivityBonus: 0.6,
                centerControlBonus: 1.1,
                kingSafetyBonus: 0.8,
                pawnStructureBonus: 1.3,
                pieceCoordinationBonus: 1.2,
                attackingChancesBonus: 0.4,
                tacticalMotifBonus: 0.3,
                initiativeBonus: 0.6,
                sacrificeBonus: 0.2,
                endgameBonus: 1.1,
                complexityBonus: 0.4,
                timeAdvantageBonus: 0.7,
                psychologicalBonus: 0.5
            ),
            preferredOpenings: ["D50", "E20", "A13"], // QGD, Nimzo-Indian, English
            avoidedOpenings: ["C30", "B01"], // King's Gambit, Scandinavian
            motto: "Chess is architecture in motion.",
            thinkingTimeMultiplier: 1.2,
            blunderRate: 0.06,
            learningRate: 0.25,
            moveComments: [
                "Building a superior position, brick by brick.",
                "Your pawn structure has weaknesses.",
                "This move improves my piece coordination.",
                "Long-term planning always pays off."
            ],
            victoryMessages: [
                "The position spoke, and victory followed!",
                "Superior structure leads to victory!",
                "Strategy triumphs over tactics!"
            ],
            defeatMessages: [
                "Your positional understanding was deeper.",
                "I underestimated your strategic plan.",
                "Sometimes tactics overcome strategy."
            ]
        ),
        
        // Gambit player
        AIPersonality(
            name: "Garry the Gambiteer",
            type: .gambit,
            skillLevel: 15,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.8,
                aggressionLevel: 0.9,
                riskTolerance: 0.95,
                timeUsage: 0.5,
                pieceActivityPreference: 1.0,
                kingSafetyPriority: 0.1,
                pawnStructureImportance: 0.2,
                initiativePreference: 1.0,
                materialVsPositionBalance: 0.9,
                openingDiversity: 0.9
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 0.6,
                bishopPairBonus: 0.8,
                rookOnOpenFileBonus: 1.0,
                queenActivityBonus: 1.2,
                centerControlBonus: 0.8,
                kingSafetyBonus: 0.1,
                pawnStructureBonus: 0.1,
                pieceCoordinationBonus: 0.9,
                attackingChancesBonus: 1.5,
                tacticalMotifBonus: 1.2,
                initiativeBonus: 1.4,
                sacrificeBonus: 1.3,
                endgameBonus: 0.2,
                complexityBonus: 1.0,
                timeAdvantageBonus: 0.8,
                psychologicalBonus: 1.0
            ),
            preferredOpenings: ["C30", "D08", "B01"], // King's Gambit, Albin Counter-Gambit, Scandinavian
            avoidedOpenings: ["D30", "C65"], // QGD, Berlin
            motto: "Fortune favors the bold!",
            thinkingTimeMultiplier: 0.6,
            blunderRate: 0.20,
            learningRate: 0.5,
            moveComments: [
                "Let's sacrifice something spectacular!",
                "Material is just a temporary inconvenience!",
                "Time to gamble everything!",
                "Development over material!"
            ],
            victoryMessages: [
                "Gambits and glory go hand in hand!",
                "That's the power of sacrificial chess!",
                "Risk everything, win everything!"
            ],
            defeatMessages: [
                "Sometimes the gambit fails...",
                "You played too safely for my style!",
                "The sacrifice gods weren't with me today."
            ]
        ),
        
        // Endgame specialist
        AIPersonality(
            name: "Vera the Virtuoso",
            type: .endgame,
            skillLevel: 20,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.4,
                aggressionLevel: 0.3,
                riskTolerance: 0.2,
                timeUsage: 1.2,
                pieceActivityPreference: 0.8,
                kingSafetyPriority: 0.6,
                pawnStructureImportance: 0.9,
                initiativePreference: 0.5,
                materialVsPositionBalance: 0.3,
                openingDiversity: 0.4
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 0.7,
                bishopPairBonus: 1.0,
                rookOnOpenFileBonus: 0.9,
                queenActivityBonus: 0.5,
                centerControlBonus: 0.8,
                kingSafetyBonus: 0.5,
                pawnStructureBonus: 1.2,
                pieceCoordinationBonus: 1.0,
                attackingChancesBonus: 0.3,
                tacticalMotifBonus: 0.4,
                initiativeBonus: 0.4,
                sacrificeBonus: 0.1,
                endgameBonus: 2.0,
                complexityBonus: 0.3,
                timeAdvantageBonus: 0.6,
                psychologicalBonus: 0.4
            ),
            preferredOpenings: ["D50", "E90", "C11"], // QGD, King's Indian, French
            avoidedOpenings: ["C30", "B20"], // King's Gambit, Sicilian
            motto: "The endgame is where truth lives.",
            thinkingTimeMultiplier: 1.4,
            blunderRate: 0.03,
            learningRate: 0.15,
            moveComments: [
                "This will be won in the endgame.",
                "Simplification favors the better player.",
                "Every pawn move matters in the endgame.",
                "Technique will decide this game."
            ],
            victoryMessages: [
                "Endgame technique never lies!",
                "That's how you convert an advantage!",
                "Precision in the endgame is everything!"
            ],
            defeatMessages: [
                "Your endgame knowledge was superior.",
                "I made a technical error.",
                "You outplayed me in the final phase."
            ]
        ),
        
        // Creative player
        AIPersonality(
            name: "Luna the Innovator",
            type: .creative,
            skillLevel: 14,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.6,
                aggressionLevel: 0.6,
                riskTolerance: 0.8,
                timeUsage: 0.8,
                pieceActivityPreference: 0.9,
                kingSafetyPriority: 0.4,
                pawnStructureImportance: 0.3,
                initiativePreference: 0.7,
                materialVsPositionBalance: 0.7,
                openingDiversity: 1.0
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 0.9,
                bishopPairBonus: 0.8,
                rookOnOpenFileBonus: 0.7,
                queenActivityBonus: 0.9,
                centerControlBonus: 0.4,
                kingSafetyBonus: 0.3,
                pawnStructureBonus: 0.2,
                pieceCoordinationBonus: 0.6,
                attackingChancesBonus: 0.8,
                tacticalMotifBonus: 0.9,
                initiativeBonus: 0.8,
                sacrificeBonus: 0.9,
                endgameBonus: 0.5,
                complexityBonus: 1.3,
                timeAdvantageBonus: 0.4,
                psychologicalBonus: 1.2
            ),
            preferredOpenings: ["A00", "A04", "B00"], // Unusual openings
            avoidedOpenings: ["D50", "C60"], // Main lines
            motto: "Creativity conquers convention!",
            thinkingTimeMultiplier: 0.9,
            blunderRate: 0.18,
            learningRate: 0.6,
            moveComments: [
                "Let's try something unexpected!",
                "Conventional moves are so boring...",
                "This should confuse my opponent!",
                "Art over science!"
            ],
            victoryMessages: [
                "Creativity triumphs again!",
                "That's what happens when you think outside the box!",
                "Unconventional but effective!"
            ],
            defeatMessages: [
                "Sometimes creativity isn't enough.",
                "You played too logically for my style!",
                "Back to the drawing board!"
            ]
        )
    ]
    
    // Get personality by type
    static func getPersonality(type: AIPersonalityType) -> AIPersonality? {
        return personalities.first { $0.type == type }
    }
    
    // Get random personality of specific skill range
    static func getRandomPersonality(skillRange: ClosedRange<Int>) -> AIPersonality {
        let filtered = personalities.filter { skillRange.contains($0.skillLevel) }
        return filtered.randomElement() ?? personalities.first!
    }
}

// MARK: - AI Decision Making
class AIDecisionEngine {
    private let personality: AIPersonality
    private var gamePhase: GamePhase = .opening
    private var positionComplexity: Double = 0.5
    private var timeRemaining: TimeInterval = 300
    
    init(personality: AIPersonality) {
        self.personality = personality
    }
    
    // Evaluate position with personality bonuses
    func evaluatePosition(_ fen: String, baseEvaluation: Double) -> Double {
        var adjustedEval = baseEvaluation
        let bonuses = personality.evaluationBonuses
        
        // Apply personality-specific bonuses based on position characteristics
        adjustedEval += evaluateKnightOutposts(fen) * bonuses.knightOutpostBonus
        adjustedEval += evaluateBishopPair(fen) * bonuses.bishopPairBonus
        adjustedEval += evaluateRookActivity(fen) * bonuses.rookOnOpenFileBonus
        adjustedEval += evaluateQueenActivity(fen) * bonuses.queenActivityBonus
        
        // Positional factors
        adjustedEval += evaluateCenterControl(fen) * bonuses.centerControlBonus
        adjustedEval += evaluateKingSafety(fen) * bonuses.kingSafetyBonus
        adjustedEval += evaluatePawnStructure(fen) * bonuses.pawnStructureBonus
        adjustedEval += evaluatePieceCoordination(fen) * bonuses.pieceCoordinationBonus
        
        // Tactical factors
        adjustedEval += evaluateAttackingChances(fen) * bonuses.attackingChancesBonus
        adjustedEval += evaluateTacticalMotifs(fen) * bonuses.tacticalMotifBonus
        adjustedEval += evaluateInitiative(fen) * bonuses.initiativeBonus
        
        // Game phase adjustments
        switch gamePhase {
        case .opening:
            adjustedEval *= (1.0 + personality.playingStyle.initiativePreference * 0.2)
        case .middlegame:
            adjustedEval *= (1.0 + personality.playingStyle.tacticalTendency * 0.3)
        case .endgame:
            adjustedEval *= (1.0 + bonuses.endgameBonus)
        }
        
        // Complexity bonus
        adjustedEval += positionComplexity * bonuses.complexityBonus
        
        return adjustedEval
    }
    
    // Choose move based on personality
    func selectMove(candidates: [String], evaluations: [Double]) -> String {
        guard !candidates.isEmpty else { return "" }
        
        var weightedScores: [(String, Double)] = []
        
        for (index, move) in candidates.enumerated() {
            var score = evaluations[index]
            
            // Apply personality-based move selection
            score = applyPersonalityFilters(move: move, baseScore: score)
            
            // Add randomness based on skill level and personality
            let randomFactor = (20.0 - Double(personality.skillLevel)) / 20.0 * 0.3
            let randomAdjustment = Double.random(in: -randomFactor...randomFactor)
            score += randomAdjustment
            
            // Blunder chance
            if Double.random(in: 0...1) < personality.blunderRate {
                score *= 0.7 // Reduce score to simulate blunder
            }
            
            weightedScores.append((move, score))
        }
        
        // Sort by score and apply selection strategy
        weightedScores.sort { $0.1 > $1.1 }
        
        return selectFromTopMoves(weightedScores)
    }
    
    private func applyPersonalityFilters(move: String, baseScore: Double) -> Double {
        var score = baseScore
        let style = personality.playingStyle
        
        // Analyze move characteristics (simplified)
        let isAggressive = move.contains("x") || move.contains("+") // Capture or check
        let isQuiet = !isAggressive
        let isDevelopment = isOpeningDevelopmentMove(move)
        let isCastling = move.contains("O")
        
        // Apply personality preferences
        if isAggressive {
            score *= (1.0 + style.aggressionLevel * 0.5)
            score *= (1.0 + style.tacticalTendency * 0.3)
        }
        
        if isQuiet && personality.type == .positional {
            score *= 1.2
        }
        
        if isDevelopment && gamePhase == .opening {
            score *= (1.0 + style.pieceActivityPreference * 0.4)
        }
        
        if isCastling {
            score *= (1.0 + style.kingSafetyPriority * 0.6)
        }
        
        // Risk adjustment
        let moveRisk = calculateMoveRisk(move)
        if moveRisk > 0.5 {
            score *= (1.0 + (style.riskTolerance - 0.5) * 0.8)
        }
        
        return score
    }
    
    private func selectFromTopMoves(_ weightedScores: [(String, Double)]) -> String {
        let topCount = max(1, min(3, weightedScores.count))
        let topMoves = Array(weightedScores.prefix(topCount))
        
        // Selection based on personality
        switch personality.type {
        case .creative:
            // Sometimes pick unusual moves
            if Double.random(in: 0...1) < 0.3 && topMoves.count > 1 {
                return topMoves[1].0
            }
        case .blitz:
            // Quick decisions, first move
            return topMoves[0].0
        case .classical:
            // Always best move
            return topMoves[0].0
        default:
            // Weighted random selection from top moves
            let weights = topMoves.map { exp($0.1 * 2.0) } // Exponential weighting
            let totalWeight = weights.reduce(0, +)
            let random = Double.random(in: 0...totalWeight)
            
            var cumulative = 0.0
            for (index, weight) in weights.enumerated() {
                cumulative += weight
                if random <= cumulative {
                    return topMoves[index].0
                }
            }
        }
        
        return topMoves[0].0
    }
    
    // Update game state
    func updateGameState(fen: String, moveCount: Int) {
        // Determine game phase
        let pieceCount = fen.filter { "KQRBNPkqrbnp".contains($0) }.count
        
        if moveCount < 20 {
            gamePhase = .opening
        } else if pieceCount > 12 {
            gamePhase = .middlegame
        } else {
            gamePhase = .endgame
        }
        
        // Calculate position complexity
        positionComplexity = calculatePositionComplexity(fen)
    }
    
    // Helper methods for position evaluation
    private func evaluateKnightOutposts(_ fen: String) -> Double {
        // Simplified knight outpost evaluation
        return 0.0
    }
    
    private func evaluateBishopPair(_ fen: String) -> Double {
        // Check for bishop pair advantage
        return 0.0
    }
    
    private func evaluateRookActivity(_ fen: String) -> Double {
        // Evaluate rook placement on open files
        return 0.0
    }
    
    private func evaluateQueenActivity(_ fen: String) -> Double {
        // Evaluate queen centralization and activity
        return 0.0
    }
    
    private func evaluateCenterControl(_ fen: String) -> Double {
        // Evaluate control of central squares
        return 0.0
    }
    
    private func evaluateKingSafety(_ fen: String) -> Double {
        // Evaluate king safety
        return 0.0
    }
    
    private func evaluatePawnStructure(_ fen: String) -> Double {
        // Evaluate pawn structure quality
        return 0.0
    }
    
    private func evaluatePieceCoordination(_ fen: String) -> Double {
        // Evaluate how well pieces work together
        return 0.0
    }
    
    private func evaluateAttackingChances(_ fen: String) -> Double {
        // Evaluate attacking potential
        return 0.0
    }
    
    private func evaluateTacticalMotifs(_ fen: String) -> Double {
        // Look for tactical patterns
        return 0.0
    }
    
    private func evaluateInitiative(_ fen: String) -> Double {
        // Evaluate who has the initiative
        return 0.0
    }
    
    private func calculatePositionComplexity(_ fen: String) -> Double {
        // Calculate how complex the position is
        let pieceCount = fen.filter { "KQRBNPkqrbnp".contains($0) }.count
        return Double(pieceCount) / 32.0
    }
    
    private func isOpeningDevelopmentMove(_ move: String) -> Bool {
        // Check if move develops a piece in opening
        return move.hasPrefix("N") || move.hasPrefix("B") || move.contains("O")
    }
    
    private func calculateMoveRisk(_ move: String) -> Double {
        // Calculate how risky a move is
        if move.contains("x") { return 0.6 } // Captures are somewhat risky
        if move.contains("+") { return 0.7 } // Checks can be risky
        if move.contains("!") { return 0.8 } // Sacrifices are risky
        return 0.3 // Normal moves have low risk
    }
    
    // Get thinking time based on personality
    func getThinkingTime(baseTime: TimeInterval) -> TimeInterval {
        return baseTime * personality.thinkingTimeMultiplier
    }
    
    // Get random comment during game
    func getRandomComment() -> String? {
        guard !personality.moveComments.isEmpty else { return nil }
        return personality.moveComments.randomElement()
    }
    
    // Get victory message
    func getVictoryMessage() -> String {
        return personality.victoryMessages.randomElement() ?? "Good game!"
    }
    
    // Get defeat message
    func getDefeatMessage() -> String {
        return personality.defeatMessages.randomElement() ?? "Well played!"
    }
}

// MARK: - Game Phase
enum GamePhase {
    case opening
    case middlegame
    case endgame
}
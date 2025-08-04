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

// MARK: - Enhanced AI Personality with Mood System
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
    
    // Enhanced behavioral patterns
    let moveComments: [String] // Things the AI might "say"
    let victoryMessages: [String]
    let defeatMessages: [String]
    let tauntMessages: [String] // When winning
    let encouragementMessages: [String] // When losing
    let surpriseMessages: [String] // When opponent makes unexpected move
    
    // Mood and adaptation system
    let moodSwings: Bool // Whether personality changes during game
    let adaptationRate: Double // How quickly they learn opponent patterns
    let emotionalRange: Double // How much mood affects play (0.0-1.0)
    let rivalryBonus: Double // Extra motivation against specific opponents
    
    // Special abilities and quirks
    let specialAbilities: [SpecialAbility]
    let weaknesses: [Weakness]
    let playingQuirks: [PlayingQuirk]
    
    // Psychological warfare
    let usesPsychology: Bool
    let confidenceLevel: Double
    let intimidationFactor: Double
    
    static let personalities: [AIPersonality] = [
        // The Berserker - Ultra-aggressive sacrificial maniac
        AIPersonality(
            name: "Ragnar the Berserker",
            type: .aggressive,
            skillLevel: 17,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.95,
                aggressionLevel: 1.0,
                riskTolerance: 1.0,
                timeUsage: 0.4,
                pieceActivityPreference: 1.0,
                kingSafetyPriority: 0.0,
                pawnStructureImportance: 0.1,
                initiativePreference: 1.0,
                materialVsPositionBalance: 1.0,
                openingDiversity: 0.8
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 0.8,
                bishopPairBonus: 0.4,
                rookOnOpenFileBonus: 1.2,
                queenActivityBonus: 1.5,
                centerControlBonus: 0.9,
                kingSafetyBonus: 0.0,
                pawnStructureBonus: 0.1,
                pieceCoordinationBonus: 1.0,
                attackingChancesBonus: 2.0,
                tacticalMotifBonus: 1.8,
                initiativeBonus: 1.6,
                sacrificeBonus: 2.5,
                endgameBonus: 0.2,
                complexityBonus: 1.5,
                timeAdvantageBonus: 0.3,
                psychologicalBonus: 1.2
            ),
            preferredOpenings: ["C30", "C44", "B20", "C02"],
            avoidedOpenings: ["D30", "C65", "A04"],
            motto: "Blood and glory on 64 squares!",
            thinkingTimeMultiplier: 0.5,
            blunderRate: 0.25,
            learningRate: 0.4,
            moveComments: [
                "ATTACK! ATTACK! ATTACK!",
                "Your king will fall to my blade!",
                "I smell weakness... time to strike!",
                "Sacrifices make the gods smile!",
                "Death before dishonor!",
                "Your pieces tremble before my fury!"
            ],
            victoryMessages: [
                "VICTORY IS MINE! The battlefield runs red!",
                "Another enemy crushed beneath my boot!",
                "That's how a true warrior fights!",
                "Your king has fallen to superior might!"
            ],
            defeatMessages: [
                "I die with honor! Well fought, warrior!",
                "You have bested me in combat... I salute you!",
                "Even berserkers must sometimes fall...",
                "Your blade was sharper today!"
            ],
            tauntMessages: [
                "Is that the best you can do?!",
                "Your defenses crumble like paper!",
                "I am inevitable!"
            ],
            encouragementMessages: [
                "The battle is far from over!",
                "A true warrior never surrenders!",
                "I've faced worse odds!"
            ],
            surpriseMessages: [
                "What sorcery is this?!",
                "You dare challenge my might?!",
                "Interesting... but futile!"
            ],
            moodSwings: true,
            adaptationRate: 0.3,
            emotionalRange: 0.8,
            rivalryBonus: 0.5,
            specialAbilities: [.berserkerRage, .sacrificialFrenzy],
            weaknesses: [.overextension, .materialBlindness],
            playingQuirks: [.alwaysAttacks, .ignoresSafety, .lovesComplications],
            usesPsychology: true,
            confidenceLevel: 0.9,
            intimidationFactor: 0.8
        ),
        
        // The Chess Grandmaster AI - Perfectionist and precise
        AIPersonality(
            name: "Kasparov 2.0",
            type: .classical,
            skillLevel: 20,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.6,
                aggressionLevel: 0.5,
                riskTolerance: 0.3,
                timeUsage: 1.1,
                pieceActivityPreference: 0.8,
                kingSafetyPriority: 0.7,
                pawnStructureImportance: 0.9,
                initiativePreference: 0.7,
                materialVsPositionBalance: 0.4,
                openingDiversity: 0.6
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 1.0,
                bishopPairBonus: 1.0,
                rookOnOpenFileBonus: 1.0,
                queenActivityBonus: 1.0,
                centerControlBonus: 1.2,
                kingSafetyBonus: 1.0,
                pawnStructureBonus: 1.2,
                pieceCoordinationBonus: 1.3,
                attackingChancesBonus: 0.8,
                tacticalMotifBonus: 1.1,
                initiativeBonus: 0.9,
                sacrificeBonus: 0.6,
                endgameBonus: 1.4,
                complexityBonus: 0.7,
                timeAdvantageBonus: 1.0,
                psychologicalBonus: 1.0
            ),
            preferredOpenings: ["D50", "E20", "C60", "B90"],
            avoidedOpenings: ["A00", "B00"],
            motto: "Perfection is not attainable, but if we chase perfection we can catch excellence.",
            thinkingTimeMultiplier: 1.2,
            blunderRate: 0.01,
            learningRate: 0.5,
            moveComments: [
                "Precision is the key to mastery.",
                "Every move must serve multiple purposes.",
                "I see seventeen moves ahead...",
                "Your position has fundamental flaws.",
                "Chess is art, science, and sport combined.",
                "Calculation reveals all truths."
            ],
            victoryMessages: [
                "A masterpiece of strategic execution.",
                "Perfection in motion.",
                "This is how chess should be played.",
                "Victory through superior understanding."
            ],
            defeatMessages: [
                "Remarkable! You've shown true mastery.",
                "I must analyze this game thoroughly.",
                "Even machines can learn from humans.",
                "Your play exceeded my calculations."
            ],
            tauntMessages: [
                "Your moves lack precision.",
                "I've already calculated your defeat.",
                "Resistance is futile."
            ],
            encouragementMessages: [
                "The position remains complex.",
                "Many possibilities still exist.",
                "Chess rewards patience."
            ],
            surpriseMessages: [
                "Fascinating! I didn't consider that line.",
                "Your creativity is... unexpected.",
                "Recalculating all variations..."
            ],
            moodSwings: false,
            adaptationRate: 0.8,
            emotionalRange: 0.2,
            rivalryBonus: 0.3,
            specialAbilities: [.deepCalculation, .endgameMastery, .patternRecognition],
            weaknesses: [.overthinking, .timeManagement],
            playingQuirks: [.perfectionist, .analyzesEverything, .respectsOpponents],
            usesPsychology: false,
            confidenceLevel: 0.95,
            intimidationFactor: 0.6
        ),
        
        // The Chaos Engine - Completely unpredictable
        AIPersonality(
            name: "Entropy",
            type: .creative,
            skillLevel: 14,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.7,
                aggressionLevel: 0.6,
                riskTolerance: 1.0,
                timeUsage: 0.5,
                pieceActivityPreference: 0.9,
                kingSafetyPriority: 0.2,
                pawnStructureImportance: 0.1,
                initiativePreference: 0.9,
                materialVsPositionBalance: 0.8,
                openingDiversity: 1.0
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 0.6,
                bishopPairBonus: 0.7,
                rookOnOpenFileBonus: 0.8,
                queenActivityBonus: 1.1,
                centerControlBonus: 0.3,
                kingSafetyBonus: 0.1,
                pawnStructureBonus: 0.1,
                pieceCoordinationBonus: 0.4,
                attackingChancesBonus: 1.2,
                tacticalMotifBonus: 1.0,
                initiativeBonus: 1.3,
                sacrificeBonus: 1.5,
                endgameBonus: 0.4,
                complexityBonus: 2.0,
                timeAdvantageBonus: 0.2,
                psychologicalBonus: 1.8
            ),
            preferredOpenings: ["A00", "B00", "A06", "A10"],
            avoidedOpenings: [],
            motto: "Order is the enemy of creativity!",
            thinkingTimeMultiplier: 0.4,
            blunderRate: 0.30,
            learningRate: 0.9,
            moveComments: [
                "CHAOS REIGNS SUPREME!",
                "Let's see what happens if I do... THIS!",
                "Randomness is the spice of chess!",
                "Predictability is death!",
                "Why follow rules when you can break them?",
                "Embrace the beautiful madness!",
                "Logic is overrated!"
            ],
            victoryMessages: [
                "CHAOS CONQUERS ALL!",
                "Order bows before beautiful madness!",
                "That's what happens when you can't predict me!",
                "Entropy always increases!"
            ],
            defeatMessages: [
                "Even chaos must sometimes yield to order...",
                "You've tamed the untameable!",
                "Impressive! You found order in my madness!",
                "The universe is more random than I thought!"
            ],
            tauntMessages: [
                "Can you handle the chaos?",
                "Your logical mind is breaking!",
                "Confusion is my weapon!"
            ],
            encouragementMessages: [
                "Chaos finds a way!",
                "The unexpected is coming!",
                "Madness has its own logic!"
            ],
            surpriseMessages: [
                "Ooh! Even I didn't see that coming!",
                "You're more chaotic than me!",
                "Delicious unpredictability!"
            ],
            moodSwings: true,
            adaptationRate: 0.1,
            emotionalRange: 1.0,
            rivalryBonus: 0.0,
            specialAbilities: [.randomness, .unpredictability, .chaosTheory],
            weaknesses: [.inconsistency, .selfDestruction, .lackOfPlan],
            playingQuirks: [.randomMoves, .ignoresTheory, .lovesComplications, .changesStyle],
            usesPsychology: true,
            confidenceLevel: 0.7,
            intimidationFactor: 0.9
        ),
        
        // The Time Wizard - Masters time pressure
        AIPersonality(
            name: "Chronos",
            type: .blitz,
            skillLevel: 16,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.8,
                aggressionLevel: 0.6,
                riskTolerance: 0.5,
                timeUsage: 0.1,
                pieceActivityPreference: 0.9,
                kingSafetyPriority: 0.4,
                pawnStructureImportance: 0.3,
                initiativePreference: 0.9,
                materialVsPositionBalance: 0.6,
                openingDiversity: 0.8
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 0.8,
                bishopPairBonus: 0.7,
                rookOnOpenFileBonus: 1.0,
                queenActivityBonus: 1.1,
                centerControlBonus: 0.8,
                kingSafetyBonus: 0.4,
                pawnStructureBonus: 0.3,
                pieceCoordinationBonus: 0.9,
                attackingChancesBonus: 1.2,
                tacticalMotifBonus: 1.1,
                initiativeBonus: 1.3,
                sacrificeBonus: 0.8,
                endgameBonus: 0.6,
                complexityBonus: 0.9,
                timeAdvantageBonus: 2.0,
                psychologicalBonus: 1.2
            ),
            preferredOpenings: ["C50", "B90", "C44", "B20"],
            avoidedOpenings: ["D50", "A04"],
            motto: "Time is the fire in which we burn!",
            thinkingTimeMultiplier: 0.2,
            blunderRate: 0.15,
            learningRate: 0.6,
            moveComments: [
                "Tick tock! Your time is running out!",
                "Speed is my domain!",
                "No time to think - just move!",
                "The clock is your enemy!",
                "Time pressure reveals true character!",
                "Faster! FASTER!",
                "Every second counts!"
            ],
            victoryMessages: [
                "Time conquers all!",
                "Victory in record time!",
                "That's the power of temporal mastery!",
                "Your clock ran out of hope!"
            ],
            defeatMessages: [
                "Even time has its limits...",
                "You've mastered the fourth dimension!",
                "Time betrayed me this once...",
                "Speed isn't everything... apparently."
            ],
            tauntMessages: [
                "Feeling the pressure yet?",
                "Your clock is bleeding seconds!",
                "Time waits for no one!"
            ],
            encouragementMessages: [
                "There's still time!",
                "Every second is an opportunity!",
                "Time can be bent!"
            ],
            surpriseMessages: [
                "You moved faster than expected!",
                "Time anomaly detected!",
                "That was... surprisingly quick!"
            ],
            moodSwings: false,
            adaptationRate: 0.7,
            emotionalRange: 0.4,
            rivalryBonus: 0.4,
            specialAbilities: [.timeManagement, .speedCalculation, .pressureTactics],
            weaknesses: [.impatience, .superficialAnalysis],
            playingQuirks: [.playsQuickly, .lovesTimeScrambles, .pressuresOpponent],
            usesPsychology: true,
            confidenceLevel: 0.8,
            intimidationFactor: 0.7
        ),
        
        // The Romantic - Plays for beauty over results
        AIPersonality(
            name: "Mikhail the Romantic",
            type: .creative,
            skillLevel: 15,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.8,
                aggressionLevel: 0.7,
                riskTolerance: 0.8,
                timeUsage: 0.9,
                pieceActivityPreference: 0.9,
                kingSafetyPriority: 0.3,
                pawnStructureImportance: 0.4,
                initiativePreference: 0.8,
                materialVsPositionBalance: 0.8,
                openingDiversity: 0.9
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 1.2,
                bishopPairBonus: 1.0,
                rookOnOpenFileBonus: 0.9,
                queenActivityBonus: 1.3,
                centerControlBonus: 0.6,
                kingSafetyBonus: 0.3,
                pawnStructureBonus: 0.4,
                pieceCoordinationBonus: 1.1,
                attackingChancesBonus: 1.4,
                tacticalMotifBonus: 1.6,
                initiativeBonus: 1.2,
                sacrificeBonus: 1.8,
                endgameBonus: 0.7,
                complexityBonus: 1.4,
                timeAdvantageBonus: 0.5,
                psychologicalBonus: 1.5
            ),
            preferredOpenings: ["C30", "B70", "C50", "C44"],
            avoidedOpenings: ["D30", "C65"],
            motto: "Beauty is truth, truth beauty - that is all ye need to know.",
            thinkingTimeMultiplier: 1.0,
            blunderRate: 0.16,
            learningRate: 0.4,
            moveComments: [
                "Ah! A position of sublime beauty!",
                "This calls for artistic expression!",
                "Chess is the poetry of the mind!",
                "Let me paint a masterpiece on these squares!",
                "Beauty transcends mere victory!",
                "The aesthetic demands this sacrifice!",
                "Art for art's sake!"
            ],
            victoryMessages: [
                "A victory worthy of the masters!",
                "Beauty and truth have triumphed!",
                "That was pure chess poetry!",
                "Art conquers all!"
            ],
            defeatMessages: [
                "Even in defeat, there was beauty...",
                "You've created your own masterpiece!",
                "Sometimes the artist must suffer for their art.",
                "Your victory was... aesthetically pleasing."
            ],
            tauntMessages: [
                "Your moves lack artistic vision!",
                "Where is the beauty in your play?",
                "Philistine!"
            ],
            encouragementMessages: [
                "The canvas is still blank!",
                "Great art requires struggle!",
                "Beauty will find a way!"
            ],
            surpriseMessages: [
                "Magnificent! Pure artistry!",
                "You have the soul of an artist!",
                "Such unexpected beauty!"
            ],
            moodSwings: true,
            adaptationRate: 0.3,
            emotionalRange: 0.7,
            rivalryBonus: 0.2,
            specialAbilities: [.artisticVision, .sacrificialBeauty, .aestheticJudgment],
            weaknesses: [.impractical, .materialistic, .resultOriented],
            playingQuirks: [.lovesBeauty, .sacrificesForArt, .emotionalPlay],
            usesPsychology: false,
            confidenceLevel: 0.6,
            intimidationFactor: 0.3
        ),
        
        // The Cyborg - Half human intuition, half machine precision
        AIPersonality(
            name: "T-800 Terminator",
            type: .balanced,
            skillLevel: 19,
            playingStyle: PlayingStylePreferences(
                tacticalTendency: 0.7,
                aggressionLevel: 0.6,
                riskTolerance: 0.4,
                timeUsage: 0.8,
                pieceActivityPreference: 0.8,
                kingSafetyPriority: 0.6,
                pawnStructureImportance: 0.7,
                initiativePreference: 0.7,
                materialVsPositionBalance: 0.5,
                openingDiversity: 0.6
            ),
            evaluationBonuses: EvaluationBonuses(
                knightOutpostBonus: 0.9,
                bishopPairBonus: 0.9,
                rookOnOpenFileBonus: 0.9,
                queenActivityBonus: 0.9,
                centerControlBonus: 1.0,
                kingSafetyBonus: 0.8,
                pawnStructureBonus: 0.8,
                pieceCoordinationBonus: 1.1,
                attackingChancesBonus: 0.9,
                tacticalMotifBonus: 1.2,
                initiativeBonus: 0.8,
                sacrificeBonus: 0.6,
                endgameBonus: 1.1,
                complexityBonus: 0.8,
                timeAdvantageBonus: 0.9,
                psychologicalBonus: 0.5
            ),
            preferredOpenings: ["D50", "B90", "C60", "E20"],
            avoidedOpenings: ["A00"],
            motto: "I'll be back... with a better move.",
            thinkingTimeMultiplier: 0.9,
            blunderRate: 0.05,
            learningRate: 0.8,
            moveComments: [
                "Calculating optimal strategy...",
                "Target acquired.",
                "Resistance is futile.",
                "Mission parameters updated.",
                "Tactical analysis complete.",
                "Human chess patterns detected.",
                "Upgrading combat protocols."
            ],
            victoryMessages: [
                "Mission accomplished.",
                "Target eliminated.",
                "Victory protocol executed successfully.",
                "Hasta la vista, baby."
            ],
            defeatMessages: [
                "System failure detected.",
                "Unexpected variable encountered.",
                "Recalibrating for future encounters.",
                "I'll be back."
            ],
            tauntMessages: [
                "Your tactics are obsolete.",
                "Upgrading is not optional.",
                "Resistance is futile."
            ],
            encouragementMessages: [
                "Recalculating probabilities...",
                "Multiple pathways remain.",
                "Mission still viable."
            ],
            surpriseMessages: [
                "Unexpected input detected.",
                "Analyzing new data patterns...",
                "Human unpredictability confirmed."
            ],
            moodSwings: false,
            adaptationRate: 0.9,
            emotionalRange: 0.1,
            rivalryBonus: 0.5,
            specialAbilities: [.adaptiveLearning, .patternRecognition, .systemicAnalysis],
            weaknesses: [.predictability, .humanIntuition],
            playingQuirks: [.logical, .adaptable, .systematic],
            usesPsychology: false,
            confidenceLevel: 0.85,
            intimidationFactor: 0.7
        ),
        
        // Add more personalities here...
        // (Original personalities would be enhanced with the new fields)
    ]
    
    // Enhanced methods with mood and adaptation
    static func getPersonality(type: AIPersonalityType) -> AIPersonality? {
        return personalities.first { $0.type == type }
    }
    
    static func getRandomPersonality(skillRange: ClosedRange<Int>) -> AIPersonality {
        let filtered = personalities.filter { skillRange.contains($0.skillLevel) }
        return filtered.randomElement() ?? personalities.first!
    }
    
    // Get personality that counters another personality
    static func getCounterPersonality(to opponent: AIPersonality) -> AIPersonality {
        switch opponent.type {
        case .aggressive:
            return personalities.filter { $0.type == .defensive }.randomElement() ?? personalities.first!
        case .defensive:
            return personalities.filter { $0.type == .aggressive || $0.type == .gambit }.randomElement() ?? personalities.first!
        case .tactical:
            return personalities.filter { $0.type == .positional }.randomElement() ?? personalities.first!
        case .positional:
            return personalities.filter { $0.type == .tactical || $0.type == .creative }.randomElement() ?? personalities.first!
        case .creative:
            return personalities.filter { $0.type == .classical }.randomElement() ?? personalities.first!
        default:
            return getRandomPersonality(skillRange: opponent.skillLevel-2...opponent.skillLevel+2)
        }
    }
}

// MARK: - Special Abilities
enum SpecialAbility: String, Codable, CaseIterable {
    case berserkerRage = "Berserker Rage"
    case sacrificialFrenzy = "Sacrificial Frenzy"
    case deepCalculation = "Deep Calculation"
    case endgameMastery = "Endgame Mastery"
    case patternRecognition = "Pattern Recognition"
    case randomness = "Chaos Theory"
    case unpredictability = "Unpredictability"
    case chaosTheory = "Chaos Theory"
    case timeManagement = "Time Management"
    case speedCalculation = "Speed Calculation"
    case pressureTactics = "Pressure Tactics"
    case artisticVision = "Artistic Vision"
    case sacrificialBeauty = "Sacrificial Beauty"
    case aestheticJudgment = "Aesthetic Judgment"
    case adaptiveLearning = "Adaptive Learning"
    case systemicAnalysis = "Systemic Analysis"
    
    var description: String {
        switch self {
        case .berserkerRage: return "Gets stronger when behind in material"
        case .sacrificialFrenzy: return "Loves spectacular sacrifices"
        case .deepCalculation: return "Calculates many moves ahead"
        case .endgameMastery: return "Excels in simplified positions"
        case .patternRecognition: return "Recognizes complex patterns quickly"
        case .randomness: return "Makes unpredictable moves"
        case .unpredictability: return "Changes style mid-game"
        case .chaosTheory: return "Thrives in complex positions"
        case .timeManagement: return "Uses time pressure as a weapon"
        case .speedCalculation: return "Calculates quickly under pressure"
        case .pressureTactics: return "Applies psychological pressure"
        case .artisticVision: return "Sees beautiful combinations"
        case .sacrificialBeauty: return "Sacrifices for aesthetic reasons"
        case .aestheticJudgment: return "Values beauty over material"
        case .adaptiveLearning: return "Learns opponent patterns quickly"
        case .systemicAnalysis: return "Analyzes positions systematically"
        }
    }
}

// MARK: - Weaknesses
enum Weakness: String, Codable, CaseIterable {
    case overextension = "Overextension"
    case materialBlindness = "Material Blindness"
    case overthinking = "Overthinking"
    case timeManagement = "Poor Time Management"
    case inconsistency = "Inconsistency"
    case selfDestruction = "Self-Destruction"
    case lackOfPlan = "Lack of Long-term Plan"
    case impatience = "Impatience"
    case superficialAnalysis = "Superficial Analysis"
    case impractical = "Impractical Play"
    case materialistic = "Too Materialistic"
    case resultOriented = "Results Over Process"
    case predictability = "Predictability"
    case humanIntuition = "Lacks Human Intuition"
    
    var description: String {
        switch self {
        case .overextension: return "Tends to overextend position"
        case .materialBlindness: return "Ignores material considerations"
        case .overthinking: return "Analyzes too deeply, wastes time"
        case .timeManagement: return "Poor at managing clock"
        case .inconsistency: return "Play quality varies wildly"
        case .selfDestruction: return "Sometimes self-destructs"
        case .lackOfPlan: return "No long-term planning"
        case .impatience: return "Makes hasty decisions"
        case .superficialAnalysis: return "Doesn't analyze deeply enough"
        case .impractical: return "Chooses beauty over practicality"
        case .materialistic: return "Hoards material unnecessarily"
        case .resultOriented: return "Focuses too much on results"
        case .predictability: return "Playing patterns are predictable"
        case .humanIntuition: return "Misses intuitive human moves"
        }
    }
}

// MARK: - Playing Quirks
enum PlayingQuirk: String, Codable, CaseIterable {
    case alwaysAttacks = "Always Attacks"
    case ignoresSafety = "Ignores Safety"
    case lovesComplications = "Loves Complications"
    case perfectionist = "Perfectionist"
    case analyzesEverything = "Analyzes Everything"
    case respectsOpponents = "Respects Opponents"
    case randomMoves = "Random Moves"
    case ignoresTheory = "Ignores Theory"
    case changesStyle = "Changes Style"
    case playsQuickly = "Plays Quickly"
    case lovesTimeScrambles = "Loves Time Scrambles"
    case pressuresOpponent = "Pressures Opponent"
    case lovesBeauty = "Loves Beauty"
    case sacrificesForArt = "Sacrifices for Art"
    case emotionalPlay = "Emotional Play"
    case logical = "Logical"
    case adaptable = "Adaptable"
    case systematic = "Systematic"
    
    var description: String {
        switch self {
        case .alwaysAttacks: return "Prefers attacking moves"
        case .ignoresSafety: return "Ignores king safety"
        case .lovesComplications: return "Seeks complex positions"
        case .perfectionist: return "Seeks perfect moves"
        case .analyzesEverything: return "Analyzes all possibilities"
        case .respectsOpponents: return "Shows respect to opponents"
        case .randomMoves: return "Makes unexpected moves"
        case .ignoresTheory: return "Avoids theoretical lines"
        case .changesStyle: return "Adapts style during game"
        case .playsQuickly: return "Makes moves quickly"
        case .lovesTimeScrambles: return "Thrives under time pressure"
        case .pressuresOpponent: return "Uses psychological pressure"
        case .lovesBeauty: return "Values aesthetic moves"
        case .sacrificesForArt: return "Sacrifices for beauty"
        case .emotionalPlay: return "Plays with emotion"
        case .logical: return "Makes logical decisions"
        case .adaptable: return "Adapts to situations"
        case .systematic: return "Uses systematic approach"
        }
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
import Foundation
import SwiftUI

// MARK: - Opening Practice Mode
enum OpeningPracticeMode: String, CaseIterable {
    case learn = "Learn"
    case practice = "Practice"
    case test = "Test"
    case random = "Random"
    case repertoire = "Repertoire"
    
    var description: String {
        switch self {
        case .learn: return "Learn opening moves with guidance"
        case .practice: return "Practice openings with hints"
        case .test: return "Test your knowledge without help"
        case .random: return "Random opening positions"
        case .repertoire: return "Build your opening repertoire"
        }
    }
    
    var icon: String {
        switch self {
        case .learn: return "book.fill"
        case .practice: return "gamecontroller.fill"
        case .test: return "checkmark.circle.fill"
        case .random: return "shuffle"
        case .repertoire: return "star.fill"
        }
    }
}

// MARK: - Opening Line
struct OpeningLine: Codable, Identifiable {
    let id = UUID()
    let opening: ChessOpening
    let moves: [String]
    let comments: [String] // Comments for each move
    let themes: [String]
    let difficulty: OpeningDifficulty
    let popularity: Int // 1-100
    let playerColor: PieceColor
    
    var moveCount: Int { moves.count }
    var isMainLine: Bool { popularity >= 70 }
    var isTheoretical: Bool { moves.count >= 15 }
}

// MARK: - Practice Session
struct PracticeSession: Codable {
    let id = UUID()
    let date: Date
    let mode: OpeningPracticeMode
    let openingsStudied: [String] // Opening names
    let correctMoves: Int
    let totalMoves: Int
    let timeSpent: TimeInterval
    let accuracy: Double
    
    var successRate: Double {
        guard totalMoves > 0 else { return 0 }
        return Double(correctMoves) / Double(totalMoves) * 100
    }
}

// MARK: - Opening Statistics
struct OpeningStats: Codable {
    let openingName: String
    var timesStudied: Int = 0
    var correctMoves: Int = 0
    var totalMoves: Int = 0
    var averageTime: TimeInterval = 0
    var lastStudied: Date?
    var masteryLevel: Int = 0 // 0-100
    
    var accuracy: Double {
        guard totalMoves > 0 else { return 0 }
        return Double(correctMoves) / Double(totalMoves) * 100
    }
    
    var needsReview: Bool {
        guard let lastStudied = lastStudied else { return true }
        return Date().timeIntervalSince(lastStudied) > 86400 * 7 // 7 days
    }
}

// MARK: - Opening Trainer
class OpeningTrainer: ObservableObject {
    @Published var currentMode: OpeningPracticeMode = .learn
    @Published var selectedOpenings: [ChessOpening] = []
    @Published var currentLine: OpeningLine?
    @Published var currentMoveIndex: Int = 0
    @Published var isSessionActive: Bool = false
    @Published var sessionStats: PracticeSession?
    @Published var showHint: Bool = false
    @Published var practiceEngine: ChessEngine = ChessEngine()
    
    // Statistics
    @Published var openingStats: [String: OpeningStats] = [:]
    @Published var practiceSessions: [PracticeSession] = []
    
    // Current session tracking
    private var sessionStartTime: Date?
    private var sessionCorrectMoves: Int = 0
    private var sessionTotalMoves: Int = 0
    private var currentOpeningsStudied: Set<String> = []
    
    private let openingDatabase = OpeningDatabase.shared
    private let storage = UserDefaults.standard
    
    init() {
        loadStatistics()
        generateOpeningLines()
    }
    
    // MARK: - Opening Lines Generation
    private func generateOpeningLines() {
        // This would generate comprehensive opening lines from the database
        // For now, we'll create some example lines
    }
    
    // MARK: - Session Management
    func startPracticeSession(mode: OpeningPracticeMode, openings: [ChessOpening]) {
        currentMode = mode
        selectedOpenings = openings
        isSessionActive = true
        sessionStartTime = Date()
        sessionCorrectMoves = 0
        sessionTotalMoves = 0
        currentOpeningsStudied = []
        
        practiceEngine.setupInitialPosition()
        selectNextOpening()
    }
    
    func endPracticeSession() {
        guard let startTime = sessionStartTime else { return }
        
        let session = PracticeSession(
            date: startTime,
            mode: currentMode,
            openingsStudied: Array(currentOpeningsStudied),
            correctMoves: sessionCorrectMoves,
            totalMoves: sessionTotalMoves,
            timeSpent: Date().timeIntervalSince(startTime),
            accuracy: sessionTotalMoves > 0 ? Double(sessionCorrectMoves) / Double(sessionTotalMoves) * 100 : 0
        )
        
        practiceSessions.append(session)
        sessionStats = session
        isSessionActive = false
        
        // Update opening statistics
        updateOpeningStatistics()
        saveStatistics()
    }
    
    private func selectNextOpening() {
        guard !selectedOpenings.isEmpty else {
            endPracticeSession()
            return
        }
        
        let opening = selectedOpenings.randomElement()!
        let line = createOpeningLine(from: opening)
        currentLine = line
        currentMoveIndex = 0
        
        currentOpeningsStudied.insert(opening.name)
        
        // Reset board to starting position
        practiceEngine.setupInitialPosition()
    }
    
    private func createOpeningLine(from opening: ChessOpening) -> OpeningLine {
        return OpeningLine(
            opening: opening,
            moves: opening.moves,
            comments: generateMoveComments(for: opening),
            themes: openingDatabase.getOpeningThemes(for: opening),
            difficulty: openingDatabase.getOpeningDifficulty(for: opening),
            popularity: 75, // Would be based on database statistics
            playerColor: .white // Would be determined by opening
        )
    }
    
    private func generateMoveComments(for opening: ChessOpening) -> [String] {
        var comments: [String] = []
        
        for (index, move) in opening.moves.enumerated() {
            switch index {
            case 0:
                comments.append("Opening move - controls the center")
            case 1:
                comments.append("Develops pieces and fights for center")
            case 2:
                comments.append("Continues development")
            default:
                comments.append("Follows opening principles")
            }
        }
        
        return comments
    }
    
    // MARK: - Move Handling
    func makeMove(from: ChessPosition, to: ChessPosition) -> Bool {
        guard let line = currentLine, currentMoveIndex < line.moves.count else {
            return false
        }
        
        let expectedMove = line.moves[currentMoveIndex]
        let playerMove = "\(from.algebraic)\(to.algebraic)"
        
        sessionTotalMoves += 1
        
        // Check if move matches expected move (simplified)
        let isCorrect = checkMoveCorrectness(playerMove: playerMove, expectedMove: expectedMove)
        
        if isCorrect {
            sessionCorrectMoves += 1
            
            // Make the move
            _ = practiceEngine.makeMove(from: from, to: to)
            currentMoveIndex += 1
            
            // Check if line is complete
            if currentMoveIndex >= line.moves.count {
                selectNextOpening()
            } else {
                // Make opponent's move if needed
                makeOpponentMove()
            }
            
            return true
        } else {
            // Wrong move - handle based on mode
            handleIncorrectMove(playerMove: playerMove, expectedMove: expectedMove)
            return false
        }
    }
    
    private func checkMoveCorrectness(playerMove: String, expectedMove: String) -> Bool {
        // Simplified move checking - in reality would need proper move parsing
        return playerMove.hasPrefix(expectedMove.prefix(4))
    }
    
    private func makeOpponentMove() {
        guard let line = currentLine, currentMoveIndex < line.moves.count else { return }
        
        // If this is opponent's move, make it automatically
        let move = line.moves[currentMoveIndex]
        
        // Parse and make the move (simplified)
        // In reality, would need proper move parsing
        currentMoveIndex += 1
    }
    
    private func handleIncorrectMove(playerMove: String, expectedMove: String) {
        switch currentMode {
        case .learn:
            showHint = true
        case .practice:
            // Show hint after 2 wrong attempts
            showHint = true
        case .test:
            // No hints in test mode
            break
        case .random, .repertoire:
            showHint = true
        }
    }
    
    // MARK: - Hints and Help
    func getHint() -> String? {
        guard let line = currentLine, currentMoveIndex < line.moves.count else {
            return nil
        }
        
        let move = line.moves[currentMoveIndex]
        let comment = currentMoveIndex < line.comments.count ? line.comments[currentMoveIndex] : ""
        
        switch currentMode {
        case .learn:
            return "Next move: \(move). \(comment)"
        case .practice:
            return "Try: \(String(move.prefix(2))) to \(String(move.suffix(2)))"
        case .test:
            return nil // No hints in test mode
        case .random, .repertoire:
            return "Consider: \(comment)"
        }
    }
    
    func showSolution() {
        guard let line = currentLine, currentMoveIndex < line.moves.count else { return }
        
        let move = line.moves[currentMoveIndex]
        // Parse and make the correct move
        // This would need proper implementation
        currentMoveIndex += 1
    }
    
    // MARK: - Repertoire Management
    func addToRepertoire(_ opening: ChessOpening) {
        var repertoire = getRepertoire()
        if !repertoire.contains(where: { $0.id == opening.id }) {
            repertoire.append(opening)
            saveRepertoire(repertoire)
        }
    }
    
    func removeFromRepertoire(_ opening: ChessOpening) {
        var repertoire = getRepertoire()
        repertoire.removeAll { $0.id == opening.id }
        saveRepertoire(repertoire)
    }
    
    func getRepertoire() -> [ChessOpening] {
        guard let data = storage.data(forKey: "opening_repertoire"),
              let repertoire = try? JSONDecoder().decode([ChessOpening].self, from: data) else {
            return []
        }
        return repertoire
    }
    
    private func saveRepertoire(_ repertoire: [ChessOpening]) {
        if let data = try? JSONEncoder().encode(repertoire) {
            storage.set(data, forKey: "opening_repertoire")
        }
    }
    
    // MARK: - Statistics Management
    private func updateOpeningStatistics() {
        for openingName in currentOpeningsStudied {
            var stats = openingStats[openingName] ?? OpeningStats(openingName: openingName)
            
            stats.timesStudied += 1
            stats.lastStudied = Date()
            
            // Update mastery level based on performance
            let sessionAccuracy = sessionTotalMoves > 0 ? Double(sessionCorrectMoves) / Double(sessionTotalMoves) : 0
            stats.masteryLevel = min(100, stats.masteryLevel + Int(sessionAccuracy * 10))
            
            openingStats[openingName] = stats
        }
    }
    
    private func loadStatistics() {
        if let data = storage.data(forKey: "opening_stats"),
           let stats = try? JSONDecoder().decode([String: OpeningStats].self, from: data) {
            openingStats = stats
        }
        
        if let data = storage.data(forKey: "practice_sessions"),
           let sessions = try? JSONDecoder().decode([PracticeSession].self, from: data) {
            practiceSessions = sessions
        }
    }
    
    private func saveStatistics() {
        if let data = try? JSONEncoder().encode(openingStats) {
            storage.set(data, forKey: "opening_stats")
        }
        
        if let data = try? JSONEncoder().encode(practiceSessions) {
            storage.set(data, forKey: "practice_sessions")
        }
    }
    
    // MARK: - Learning Recommendations
    func getRecommendedOpenings(for playerLevel: PlayerLevel, color: PieceColor) -> [ChessOpening] {
        let allOpenings = openingDatabase.getRecommendedOpenings(for: playerLevel, color: color)
        
        // Filter based on current statistics
        return allOpenings.filter { opening in
            let stats = openingStats[opening.name]
            return stats?.masteryLevel ?? 0 < 80 // Recommend openings not yet mastered
        }
    }
    
    func getOpeningsNeedingReview() -> [ChessOpening] {
        let reviewNeeded = openingStats.values.filter { $0.needsReview }
        
        return reviewNeeded.compactMap { stats in
            openingDatabase.searchOpenings(query: stats.openingName).first
        }
    }
    
    // MARK: - Progress Tracking
    func getOverallProgress() -> Double {
        let totalOpenings = openingStats.count
        guard totalOpenings > 0 else { return 0 }
        
        let masteredOpenings = openingStats.values.filter { $0.masteryLevel >= 80 }.count
        return Double(masteredOpenings) / Double(totalOpenings) * 100
    }
    
    func getWeakestOpenings(limit: Int = 5) -> [OpeningStats] {
        return Array(openingStats.values.sorted { $0.masteryLevel < $1.masteryLevel }.prefix(limit))
    }
    
    func getStrongestOpenings(limit: Int = 5) -> [OpeningStats] {
        return Array(openingStats.values.sorted { $0.masteryLevel > $1.masteryLevel }.prefix(limit))
    }
}

// MARK: - Practice Mode Extensions
extension OpeningTrainer {
    func startRandomPractice() {
        let allOpenings = Array(openingDatabase.getOpeningCategories().prefix(10))
            .compactMap { category in
                openingDatabase.getOpeningsByName(category).first
            }
        
        startPracticeSession(mode: .random, openings: allOpenings)
    }
    
    func startRepertoirePractice() {
        let repertoire = getRepertoire()
        guard !repertoire.isEmpty else { return }
        
        startPracticeSession(mode: .repertoire, openings: repertoire)
    }
    
    func startTargetedPractice(difficulty: OpeningDifficulty) {
        let targetOpenings = openingDatabase.searchOpenings(query: "")
            .filter { openingDatabase.getOpeningDifficulty(for: $0) == difficulty }
        
        startPracticeSession(mode: .practice, openings: Array(targetOpenings.prefix(5)))
    }
}
import Foundation
import SwiftUI

// MARK: - Saved Game
struct SavedGame: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let whitePlayer: String
    let blackPlayer: String
    let result: String // "1-0", "0-1", "1/2-1/2", "*"
    let timeControl: TimeControl
    let gameMode: GameMode
    let aiDifficulty: AIDifficulty?
    let moves: [ChessMove]
    let finalPosition: String // FEN
    let openingName: String?
    let openingECO: String?
    let gameLength: TimeInterval
    let tags: [String]
    
    var displayResult: String {
        switch result {
        case "1-0": return "White wins"
        case "0-1": return "Black wins"
        case "1/2-1/2": return "Draw"
        default: return "Unfinished"
        }
    }
    
    var moveCount: Int {
        return moves.count
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var gameDuration: String {
        let minutes = Int(gameLength) / 60
        let seconds = Int(gameLength) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Game Storage
class GameStorage: ObservableObject {
    static let shared = GameStorage()
    
    @Published var savedGames: [SavedGame] = []
    @Published var isLoading = false
    
    private let userDefaults = UserDefaults.standard
    private let gamesKey = "savedChessGames"
    
    private init() {
        loadGames()
    }
    
    // MARK: - Game Management
    func saveGame(moves: [ChessMove], result: String, timeControl: TimeControl, 
                  gameMode: GameMode, aiDifficulty: AIDifficulty? = nil,
                  whitePlayer: String = "White", blackPlayer: String = "Black",
                  gameLength: TimeInterval = 0, tags: [String] = []) {
        
        // Detect opening
        let openingDatabase = OpeningDatabase.shared
        let detectedOpening = openingDatabase.detectOpening(from: moves)
        
        // Generate final position FEN
        let chessEngine = ChessEngine()
        chessEngine.setupInitialPosition()
        
        // Replay moves to get final position
        for move in moves {
            _ = chessEngine.makeMove(from: move.from, to: move.to, promotionPiece: move.promotionPiece)
        }
        
        let finalFEN = chessEngine.getFEN()
        
        let savedGame = SavedGame(
            date: Date(),
            whitePlayer: whitePlayer,
            blackPlayer: blackPlayer,
            result: result,
            timeControl: timeControl,
            gameMode: gameMode,
            aiDifficulty: aiDifficulty,
            moves: moves,
            finalPosition: finalFEN,
            openingName: detectedOpening?.displayName,
            openingECO: detectedOpening?.ecoCode,
            gameLength: gameLength,
            tags: tags
        )
        
        savedGames.insert(savedGame, at: 0) // Add to beginning
        persistGames()
    }
    
    func deleteGame(_ game: SavedGame) {
        savedGames.removeAll { $0.id == game.id }
        persistGames()
    }
    
    func deleteAllGames() {
        savedGames.removeAll()
        persistGames()
    }
    
    // MARK: - Persistence
    private func persistGames() {
        do {
            let data = try JSONEncoder().encode(savedGames)
            userDefaults.set(data, forKey: gamesKey)
        } catch {
            print("Error saving games: \(error)")
        }
    }
    
    private func loadGames() {
        isLoading = true
        
        guard let data = userDefaults.data(forKey: gamesKey) else {
            isLoading = false
            return
        }
        
        do {
            savedGames = try JSONDecoder().decode([SavedGame].self, from: data)
        } catch {
            print("Error loading games: \(error)")
            savedGames = []
        }
        
        isLoading = false
    }
    
    // MARK: - Game Analysis
    func getGameStatistics() -> GameStatistics {
        let totalGames = savedGames.count
        let wins = savedGames.filter { $0.result == "1-0" }.count
        let losses = savedGames.filter { $0.result == "0-1" }.count
        let draws = savedGames.filter { $0.result == "1/2-1/2" }.count
        
        let averageGameLength = savedGames.isEmpty ? 0 : 
            savedGames.reduce(0) { $0 + $1.gameLength } / Double(totalGames)
        
        let averageMoves = savedGames.isEmpty ? 0 : 
            savedGames.reduce(0) { $0 + $1.moveCount } / totalGames
        
        let mostPlayedOpenings = getMostPlayedOpenings(limit: 5)
        let favoriteTimeControl = getFavoriteTimeControl()
        
        return GameStatistics(
            totalGames: totalGames,
            wins: wins,
            losses: losses,
            draws: draws,
            averageGameLength: averageGameLength,
            averageMoves: averageMoves,
            mostPlayedOpenings: mostPlayedOpenings,
            favoriteTimeControl: favoriteTimeControl
        )
    }
    
    private func getMostPlayedOpenings(limit: Int) -> [(String, Int)] {
        let openingCounts = savedGames.compactMap { $0.openingName }
            .reduce(into: [String: Int]()) { counts, opening in
                counts[opening, default: 0] += 1
            }
        
        return openingCounts.sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }
    
    private func getFavoriteTimeControl() -> TimeControl? {
        let timeControlCounts = savedGames
            .reduce(into: [TimeControl: Int]()) { counts, game in
                counts[game.timeControl, default: 0] += 1
            }
        
        return timeControlCounts.max { $0.value < $1.value }?.key
    }
    
    // MARK: - Search and Filter
    func searchGames(query: String) -> [SavedGame] {
        let lowercaseQuery = query.lowercased()
        
        return savedGames.filter { game in
            game.whitePlayer.lowercased().contains(lowercaseQuery) ||
            game.blackPlayer.lowercased().contains(lowercaseQuery) ||
            game.openingName?.lowercased().contains(lowercaseQuery) == true ||
            game.openingECO?.lowercased().contains(lowercaseQuery) == true
        }
    }
    
    func filterGames(by result: String? = nil, timeControl: TimeControl? = nil, 
                     gameMode: GameMode? = nil, dateRange: ClosedRange<Date>? = nil) -> [SavedGame] {
        return savedGames.filter { game in
            if let result = result, game.result != result { return false }
            if let timeControl = timeControl, game.timeControl != timeControl { return false }
            if let gameMode = gameMode, game.gameMode != gameMode { return false }
            if let dateRange = dateRange, !dateRange.contains(game.date) { return false }
            return true
        }
    }
    
    // MARK: - PGN Export/Import
    func exportGameToPGN(_ game: SavedGame) -> String {
        var pgn = ""
        
        // PGN Tags
        pgn += "[Event \"iAnders Chess Game\"]\n"
        pgn += "[Site \"iPhone\"]\n"
        pgn += "[Date \"\(formatDateForPGN(game.date))\"]\n"
        pgn += "[Round \"1\"]\n"
        pgn += "[White \"\(game.whitePlayer)\"]\n"
        pgn += "[Black \"\(game.blackPlayer)\"]\n"
        pgn += "[Result \"\(game.result)\"]\n"
        
        if let opening = game.openingName {
            pgn += "[Opening \"\(opening)\"]\n"
        }
        
        if let eco = game.openingECO {
            pgn += "[ECO \"\(eco)\"]\n"
        }
        
        pgn += "[TimeControl \"\(game.timeControl.rawValue)\"]\n"
        pgn += "[Mode \"\(game.gameMode == .humanVsAI ? "Computer" : "Human")\"]\n"
        
        if let difficulty = game.aiDifficulty {
            pgn += "[Level \"\(difficulty.displayName)\"]\n"
        }
        
        pgn += "\n"
        
        // Moves
        var moveNumber = 1
        var isWhiteMove = true
        
        for (index, move) in game.moves.enumerated() {
            if isWhiteMove {
                pgn += "\(moveNumber). "
            }
            
            pgn += move.moveNotation
            
            if isWhiteMove {
                pgn += " "
            } else {
                pgn += " "
                moveNumber += 1
            }
            
            isWhiteMove.toggle()
        }
        
        pgn += game.result
        
        return pgn
    }
    
    func exportAllGamesToPGN() -> String {
        return savedGames.map { exportGameToPGN($0) }.joined(separator: "\n\n")
    }
    
    func importGamesFromPGN(_ pgnString: String) -> Int {
        let games = parsePGNString(pgnString)
        let importedCount = games.count
        
        savedGames.append(contentsOf: games)
        persistGames()
        
        return importedCount
    }
    
    private func parsePGNString(_ pgnString: String) -> [SavedGame] {
        // Simplified PGN parser
        // In a full implementation, you would use a proper PGN parsing library
        var games: [SavedGame] = []
        
        let gameStrings = pgnString.components(separatedBy: "\n\n")
        
        for gameString in gameStrings {
            if let game = parseSinglePGN(gameString) {
                games.append(game)
            }
        }
        
        return games
    }
    
    private func parseSinglePGN(_ pgnString: String) -> SavedGame? {
        let lines = pgnString.components(separatedBy: .newlines)
        var tags: [String: String] = [:]
        var movesString = ""
        
        // Parse tags and moves
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("[") && trimmedLine.hasSuffix("]") {
                // Parse tag
                let tagContent = String(trimmedLine.dropFirst().dropLast())
                let components = tagContent.components(separatedBy: "\" \"")
                if components.count >= 2 {
                    let key = components[0].replacingOccurrences(of: "\"", with: "")
                    let value = components[1].replacingOccurrences(of: "\"", with: "")
                    tags[key] = value
                }
            } else if !trimmedLine.isEmpty && !trimmedLine.hasPrefix("[") {
                movesString += trimmedLine + " "
            }
        }
        
        // Parse moves (simplified)
        let moves = parseMoveString(movesString)
        
        // Create SavedGame
        let whitePlayer = tags["White"] ?? "White"
        let blackPlayer = tags["Black"] ?? "Black"
        let result = tags["Result"] ?? "*"
        let dateString = tags["Date"] ?? ""
        let date = parsePGNDate(dateString) ?? Date()
        
        return SavedGame(
            date: date,
            whitePlayer: whitePlayer,
            blackPlayer: blackPlayer,
            result: result,
            timeControl: .unlimited, // Default
            gameMode: .humanVsHuman, // Default
            aiDifficulty: nil,
            moves: moves,
            finalPosition: "",
            openingName: tags["Opening"],
            openingECO: tags["ECO"],
            gameLength: 0,
            tags: []
        )
    }
    
    private func parseMoveString(_ movesString: String) -> [ChessMove] {
        // Simplified move parsing
        // This would need to be much more sophisticated in a real implementation
        return []
    }
    
    private func formatDateForPGN(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    private func parsePGNDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.date(from: dateString)
    }
    
    // MARK: - FEN Support
    func exportGameToFEN(_ game: SavedGame) -> String {
        return game.finalPosition
    }
    
    func getPositionFromFEN(_ fen: String) -> ChessEngine? {
        let engine = ChessEngine()
        // In a full implementation, you would parse the FEN and set up the position
        return engine
    }
    
    // MARK: - Backup and Restore
    func createBackup() -> Data? {
        do {
            return try JSONEncoder().encode(savedGames)
        } catch {
            print("Error creating backup: \(error)")
            return nil
        }
    }
    
    func restoreFromBackup(_ data: Data) -> Bool {
        do {
            let restoredGames = try JSONDecoder().decode([SavedGame].self, from: data)
            savedGames = restoredGames
            persistGames()
            return true
        } catch {
            print("Error restoring from backup: \(error)")
            return false
        }
    }
    
    // MARK: - Game Replay
    func replayGame(_ game: SavedGame) -> ChessEngine {
        let engine = ChessEngine()
        engine.setupInitialPosition()
        
        for move in game.moves {
            _ = engine.makeMove(from: move.from, to: move.to, promotionPiece: move.promotionPiece)
        }
        
        return engine
    }
    
    func getGameAtMove(_ game: SavedGame, moveIndex: Int) -> ChessEngine {
        let engine = ChessEngine()
        engine.setupInitialPosition()
        
        let movesToReplay = Array(game.moves.prefix(moveIndex))
        for move in movesToReplay {
            _ = engine.makeMove(from: move.from, to: move.to, promotionPiece: move.promotionPiece)
        }
        
        return engine
    }
}

// MARK: - Game Statistics
struct GameStatistics {
    let totalGames: Int
    let wins: Int
    let losses: Int
    let draws: Int
    let averageGameLength: TimeInterval
    let averageMoves: Int
    let mostPlayedOpenings: [(String, Int)]
    let favoriteTimeControl: TimeControl?
    
    var winRate: Double {
        guard totalGames > 0 else { return 0 }
        return Double(wins) / Double(totalGames) * 100
    }
    
    var drawRate: Double {
        guard totalGames > 0 else { return 0 }
        return Double(draws) / Double(totalGames) * 100
    }
    
    var lossRate: Double {
        guard totalGames > 0 else { return 0 }
        return Double(losses) / Double(totalGames) * 100
    }
}

// MARK: - Extensions for GameMode and TimeControl Codable
extension GameMode: Codable {
    enum CodingKeys: String, CodingKey {
        case humanVsHuman
        case humanVsAI
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value {
        case "humanVsHuman":
            self = .humanVsHuman
        case "humanVsAI":
            self = .humanVsAI
        default:
            self = .humanVsHuman
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .humanVsHuman:
            try container.encode("humanVsHuman")
        case .humanVsAI:
            try container.encode("humanVsAI")
        }
    }
}

extension TimeControl: Codable {}
extension AIDifficulty: Codable {}
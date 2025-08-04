import Foundation

// MARK: - Chess Opening
struct ChessOpening: Codable, Identifiable {
    let id = UUID()
    let ecoCode: String
    let name: String
    let variation: String?
    let moves: [String]
    let fen: String?
    
    var displayName: String {
        if let variation = variation, !variation.isEmpty {
            return "\(name): \(variation)"
        }
        return name
    }
    
    var fullName: String {
        return "\(ecoCode) - \(displayName)"
    }
}

// MARK: - Opening Database
class OpeningDatabase: ObservableObject {
    static let shared = OpeningDatabase()
    
    private var openings: [ChessOpening] = []
    private var moveSequenceMap: [String: ChessOpening] = [:]
    
    @Published var isLoaded = false
    
    private init() {
        loadOpenings()
    }
    
    // MARK: - Database Loading
    private func loadOpenings() {
        // Load from JSON file
        if let path = Bundle.main.path(forResource: "opening_book", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            loadFromData(data)
        } else {
            // Fallback to hardcoded openings
            loadHardcodedOpenings()
        }
        
        buildMoveSequenceMap()
        isLoaded = true
    }
    
    private func loadFromData(_ data: Data) {
        do {
            openings = try JSONDecoder().decode([ChessOpening].self, from: data)
        } catch {
            print("Error loading opening database: \(error)")
            loadHardcodedOpenings()
        }
    }
    
    private func loadHardcodedOpenings() {
        openings = [
            // King's Pawn Openings (E00-E99)
            ChessOpening(
                ecoCode: "C20",
                name: "King's Pawn Game",
                variation: nil,
                moves: ["e4", "e5"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "C25",
                name: "Vienna Game",
                variation: nil,
                moves: ["e4", "e5", "Nc3"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "C30",
                name: "King's Gambit",
                variation: nil,
                moves: ["e4", "e5", "f4"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "C44",
                name: "Scotch Game",
                variation: nil,
                moves: ["e4", "e5", "Nf3", "Nc6", "d4"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "C50",
                name: "Italian Game",
                variation: nil,
                moves: ["e4", "e5", "Nf3", "Nc6", "Bc4"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "C60",
                name: "Spanish Opening",
                variation: "Ruy Lopez",
                moves: ["e4", "e5", "Nf3", "Nc6", "Bb5"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "C65",
                name: "Spanish Opening",
                variation: "Berlin Defense",
                moves: ["e4", "e5", "Nf3", "Nc6", "Bb5", "Nf6"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "C70",
                name: "Spanish Opening",
                variation: "Morphy Defense",
                moves: ["e4", "e5", "Nf3", "Nc6", "Bb5", "a6"],
                fen: nil
            ),
            
            // Queen's Pawn Openings (D00-D99)
            ChessOpening(
                ecoCode: "D00",
                name: "Queen's Pawn Game",
                variation: nil,
                moves: ["d4", "d5"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "D06",
                name: "Queen's Gambit",
                variation: nil,
                moves: ["d4", "d5", "c4"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "D08",
                name: "Queen's Gambit Declined",
                variation: "Albin Counter-Gambit",
                moves: ["d4", "d5", "c4", "e5"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "D20",
                name: "Queen's Gambit Accepted",
                variation: nil,
                moves: ["d4", "d5", "c4", "dxc4"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "D30",
                name: "Queen's Gambit Declined",
                variation: nil,
                moves: ["d4", "d5", "c4", "e6"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "D35",
                name: "Queen's Gambit Declined",
                variation: "Exchange Variation",
                moves: ["d4", "d5", "c4", "e6", "cxd5"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "D50",
                name: "Queen's Gambit Declined",
                variation: "4.Bg5",
                moves: ["d4", "d5", "c4", "e6", "Nc3", "Nf6", "Bg5"],
                fen: nil
            ),
            
            // English Opening (A10-A39)
            ChessOpening(
                ecoCode: "A10",
                name: "English Opening",
                variation: nil,
                moves: ["c4"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "A13",
                name: "English Opening",
                variation: "Anglo-Indian Defense",
                moves: ["c4", "Nf6"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "A20",
                name: "English Opening",
                variation: "Reversed Sicilian",
                moves: ["c4", "e5"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "A30",
                name: "English Opening",
                variation: "Symmetrical",
                moves: ["c4", "c5"],
                fen: nil
            ),
            
            // Réti Opening (A04-A09)
            ChessOpening(
                ecoCode: "A04",
                name: "Réti Opening",
                variation: nil,
                moves: ["Nf3"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "A05",
                name: "Réti Opening",
                variation: "King's Indian Attack",
                moves: ["Nf3", "Nf6"],
                fen: nil
            ),
            
            // Sicilian Defense (B20-B99)
            ChessOpening(
                ecoCode: "B20",
                name: "Sicilian Defense",
                variation: nil,
                moves: ["e4", "c5"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "B22",
                name: "Sicilian Defense",
                variation: "Alapin Variation",
                moves: ["e4", "c5", "c3"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "B30",
                name: "Sicilian Defense",
                variation: "Old Sicilian",
                moves: ["e4", "c5", "Nf3", "Nc6"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "B40",
                name: "Sicilian Defense",
                variation: "French Variation",
                moves: ["e4", "c5", "Nf3", "e6"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "B50",
                name: "Sicilian Defense",
                variation: nil,
                moves: ["e4", "c5", "Nf3", "d6"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "B70",
                name: "Sicilian Defense",
                variation: "Dragon Variation",
                moves: ["e4", "c5", "Nf3", "d6", "d4", "cxd4", "Nxd4", "Nf6", "Nc3", "g6"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "B90",
                name: "Sicilian Defense",
                variation: "Najdorf Variation",
                moves: ["e4", "c5", "Nf3", "d6", "d4", "cxd4", "Nxd4", "Nf6", "Nc3", "a6"],
                fen: nil
            ),
            
            // French Defense (C00-C19)
            ChessOpening(
                ecoCode: "C00",
                name: "French Defense",
                variation: nil,
                moves: ["e4", "e6"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "C02",
                name: "French Defense",
                variation: "Advance Variation",
                moves: ["e4", "e6", "d4", "d5", "e5"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "C10",
                name: "French Defense",
                variation: "Exchange Variation",
                moves: ["e4", "e6", "d4", "d5", "exd5"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "C11",
                name: "French Defense",
                variation: "Steinitz Variation",
                moves: ["e4", "e6", "d4", "d5", "Nc3"],
                fen: nil
            ),
            
            // Caro-Kann Defense (B10-B19)
            ChessOpening(
                ecoCode: "B10",
                name: "Caro-Kann Defense",
                variation: nil,
                moves: ["e4", "c6"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "B12",
                name: "Caro-Kann Defense",
                variation: "Advance Variation",
                moves: ["e4", "c6", "d4", "d5", "e5"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "B15",
                name: "Caro-Kann Defense",
                variation: "Main Line",
                moves: ["e4", "c6", "d4", "d5", "Nc3"],
                fen: nil
            ),
            
            // Nimzo-Indian Defense (E20-E59)
            ChessOpening(
                ecoCode: "E20",
                name: "Nimzo-Indian Defense",
                variation: nil,
                moves: ["d4", "Nf6", "c4", "e6", "Nc3", "Bb4"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "E30",
                name: "Nimzo-Indian Defense",
                variation: "Leningrad Variation",
                moves: ["d4", "Nf6", "c4", "e6", "Nc3", "Bb4", "Bg5"],
                fen: nil
            ),
            
            // King's Indian Defense (E60-E99)
            ChessOpening(
                ecoCode: "E60",
                name: "King's Indian Defense",
                variation: nil,
                moves: ["d4", "Nf6", "c4", "g6"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "E70",
                name: "King's Indian Defense",
                variation: "Normal Variation",
                moves: ["d4", "Nf6", "c4", "g6", "Nc3", "Bg7", "e4"],
                fen: nil
            ),
            ChessOpening(
                ecoCode: "E90",
                name: "King's Indian Defense",
                variation: "Classical Variation",
                moves: ["d4", "Nf6", "c4", "g6", "Nc3", "Bg7", "e4", "d6", "Nf3", "O-O", "Be2"],
                fen: nil
            )
        ]
    }
    
    private func buildMoveSequenceMap() {
        moveSequenceMap.removeAll()
        
        for opening in openings {
            let moveSequence = opening.moves.joined(separator: " ")
            moveSequenceMap[moveSequence] = opening
            
            // Also add partial sequences for progressive detection
            for i in 1..<opening.moves.count {
                let partialSequence = Array(opening.moves.prefix(i)).joined(separator: " ")
                if moveSequenceMap[partialSequence] == nil {
                    moveSequenceMap[partialSequence] = opening
                }
            }
        }
    }
    
    // MARK: - Opening Detection
    func detectOpening(from moves: [ChessMove]) -> ChessOpening? {
        let algebraicMoves = moves.map { $0.moveNotation }
        return detectOpening(from: algebraicMoves)
    }
    
    func detectOpening(from algebraicMoves: [String]) -> ChessOpening? {
        // Try to match the exact sequence first
        let moveSequence = algebraicMoves.joined(separator: " ")
        if let opening = moveSequenceMap[moveSequence] {
            return opening
        }
        
        // Try partial matches, starting from the longest possible
        for length in (1...algebraicMoves.count).reversed() {
            let partialMoves = Array(algebraicMoves.prefix(length))
            let partialSequence = partialMoves.joined(separator: " ")
            
            if let opening = moveSequenceMap[partialSequence] {
                return opening
            }
        }
        
        return nil
    }
    
    func detectOpening(from fen: String) -> ChessOpening? {
        // Convert FEN to move sequence (simplified approach)
        // In a full implementation, you would need to reconstruct the game
        return nil
    }
    
    // MARK: - Opening Search
    func searchOpenings(query: String) -> [ChessOpening] {
        let lowercaseQuery = query.lowercased()
        
        return openings.filter { opening in
            opening.name.lowercased().contains(lowercaseQuery) ||
            opening.ecoCode.lowercased().contains(lowercaseQuery) ||
            (opening.variation?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }
    
    func getOpeningsByECO(code: String) -> [ChessOpening] {
        return openings.filter { $0.ecoCode.hasPrefix(code) }
    }
    
    func getOpeningsByName(_ name: String) -> [ChessOpening] {
        return openings.filter { $0.name.lowercased().contains(name.lowercased()) }
    }
    
    // MARK: - Opening Categories
    func getOpeningCategories() -> [String] {
        let categories = Set(openings.map { $0.name })
        return Array(categories).sorted()
    }
    
    func getECOCodes() -> [String] {
        let codes = Set(openings.map { $0.ecoCode })
        return Array(codes).sorted()
    }
    
    // MARK: - Opening Statistics
    func getOpeningFrequency() -> [String: Int] {
        var frequency: [String: Int] = [:]
        
        for opening in openings {
            frequency[opening.name, default: 0] += 1
        }
        
        return frequency
    }
    
    func getMostPopularOpenings(limit: Int = 10) -> [ChessOpening] {
        // In a real implementation, this would be based on actual game statistics
        // For now, return the first few openings
        return Array(openings.prefix(limit))
    }
    
    // MARK: - Opening Analysis
    func getOpeningThemes(for opening: ChessOpening) -> [String] {
        var themes: [String] = []
        
        // Analyze the opening moves to determine themes
        let moves = opening.moves
        
        // Center control
        if moves.contains("e4") || moves.contains("d4") {
            themes.append("Center Control")
        }
        
        // King safety
        if moves.contains("O-O") || moves.contains("O-O-O") {
            themes.append("King Safety")
        }
        
        // Piece development
        if moves.filter({ $0.contains("N") || $0.contains("B") }).count >= 2 {
            themes.append("Piece Development")
        }
        
        // Pawn structure
        if moves.contains("c4") || moves.contains("f4") || moves.contains("g3") {
            themes.append("Pawn Structure")
        }
        
        // Tactical motifs
        if opening.name.contains("Gambit") {
            themes.append("Tactical")
        }
        
        // Positional play
        if opening.name.contains("System") || opening.name.contains("Setup") {
            themes.append("Positional")
        }
        
        return themes
    }
    
    func getOpeningDifficulty(for opening: ChessOpening) -> OpeningDifficulty {
        // Determine difficulty based on various factors
        let moveCount = opening.moves.count
        let name = opening.name.lowercased()
        
        // Beginner openings
        if name.contains("italian") || name.contains("scholar") || moveCount <= 3 {
            return .beginner
        }
        
        // Intermediate openings
        if name.contains("spanish") || name.contains("french") || name.contains("caro-kann") {
            return .intermediate
        }
        
        // Advanced openings
        if name.contains("nimzo") || name.contains("dragon") || name.contains("najdorf") {
            return .advanced
        }
        
        // Expert openings
        if name.contains("accelerated") || name.contains("hyper") || moveCount > 8 {
            return .expert
        }
        
        return .intermediate
    }
    
    // MARK: - Opening Recommendations
    func getRecommendedOpenings(for playerLevel: PlayerLevel, color: PieceColor) -> [ChessOpening] {
        let allSuitableOpenings = openings.filter { opening in
            let difficulty = getOpeningDifficulty(for: opening)
            
            switch playerLevel {
            case .beginner:
                return difficulty == .beginner
            case .intermediate:
                return difficulty == .beginner || difficulty == .intermediate
            case .advanced:
                return difficulty != .expert
            case .expert:
                return true
            }
        }
        
        // Filter by color (first move indicates color)
        let colorFilteredOpenings = allSuitableOpenings.filter { opening in
            guard let firstMove = opening.moves.first else { return true }
            
            if color == .white {
                return !firstMove.contains("...") // White moves don't have "..."
            } else {
                return firstMove.contains("...") || opening.moves.count > 1 // Black responses
            }
        }
        
        return Array(colorFilteredOpenings.prefix(5))
    }
}

// MARK: - Supporting Types
enum OpeningDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .expert: return .red
        }
    }
}

enum PlayerLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
}

// MARK: - Opening Book JSON Structure
struct OpeningBookEntry: Codable {
    let eco: String
    let name: String
    let fen: String
    let moves: String
    let uci: String
    
    func toChessOpening() -> ChessOpening {
        let movesList = moves.split(separator: " ").map(String.init)
        return ChessOpening(
            ecoCode: eco,
            name: name,
            variation: nil,
            moves: movesList,
            fen: fen.isEmpty ? nil : fen
        )
    }
}

// MARK: - Extensions
extension OpeningDatabase {
    func exportToJSON() -> Data? {
        do {
            return try JSONEncoder().encode(openings)
        } catch {
            print("Error exporting opening database: \(error)")
            return nil
        }
    }
    
    func importFromJSON(_ data: Data) -> Bool {
        do {
            let importedOpenings = try JSONDecoder().decode([ChessOpening].self, from: data)
            openings = importedOpenings
            buildMoveSequenceMap()
            return true
        } catch {
            print("Error importing opening database: \(error)")
            return false
        }
    }
}
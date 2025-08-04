import Foundation

// MARK: - Chess Piece Types
enum PieceType: String, CaseIterable {
    case pawn = "p"
    case rook = "r"
    case knight = "n"
    case bishop = "b"
    case queen = "q"
    case king = "k"
    
    var value: Int {
        switch self {
        case .pawn: return 1
        case .knight, .bishop: return 3
        case .rook: return 5
        case .queen: return 9
        case .king: return 1000
        }
    }
}

enum PieceColor: String, CaseIterable {
    case white = "w"
    case black = "b"
    
    var opposite: PieceColor {
        return self == .white ? .black : .white
    }
}

// MARK: - Chess Piece
struct ChessPiece: Codable, Equatable {
    let type: PieceType
    let color: PieceColor
    var hasMoved: Bool = false
    
    var symbol: String {
        let symbols: [PieceType: [PieceColor: String]] = [
            .king: [.white: "♔", .black: "♚"],
            .queen: [.white: "♕", .black: "♛"],
            .rook: [.white: "♖", .black: "♜"],
            .bishop: [.white: "♗", .black: "♝"],
            .knight: [.white: "♘", .black: "♞"],
            .pawn: [.white: "♙", .black: "♟"]
        ]
        return symbols[type]?[color] ?? ""
    }
}

// MARK: - Chess Position
struct ChessPosition: Codable, Equatable, Hashable {
    let file: Int // 0-7 (a-h)
    let rank: Int // 0-7 (1-8)
    
    init(_ file: Int, _ rank: Int) {
        self.file = file
        self.rank = rank
    }
    
    init?(algebraic: String) {
        guard algebraic.count == 2,
              let fileChar = algebraic.first,
              let rankChar = algebraic.last,
              let file = "abcdefgh".firstIndex(of: fileChar),
              let rank = Int(String(rankChar)) else {
            return nil
        }
        
        self.file = "abcdefgh".distance(from: "abcdefgh".startIndex, to: file)
        self.rank = rank - 1
    }
    
    var algebraic: String {
        let files = "abcdefgh"
        let fileIndex = files.index(files.startIndex, offsetBy: file)
        return "\(files[fileIndex])\(rank + 1)"
    }
    
    var isValid: Bool {
        return file >= 0 && file < 8 && rank >= 0 && rank < 8
    }
    
    func offset(by fileOffset: Int, _ rankOffset: Int) -> ChessPosition? {
        let newPos = ChessPosition(file + fileOffset, rank + rankOffset)
        return newPos.isValid ? newPos : nil
    }
}

// MARK: - Chess Move
struct ChessMove: Codable, Equatable {
    let from: ChessPosition
    let to: ChessPosition
    let piece: ChessPiece
    let capturedPiece: ChessPiece?
    let isEnPassant: Bool
    let isCastling: Bool
    let promotionPiece: PieceType?
    let isCheck: Bool
    let isCheckmate: Bool
    let moveNotation: String
    
    init(from: ChessPosition, to: ChessPosition, piece: ChessPiece, 
         capturedPiece: ChessPiece? = nil, isEnPassant: Bool = false, 
         isCastling: Bool = false, promotionPiece: PieceType? = nil,
         isCheck: Bool = false, isCheckmate: Bool = false, moveNotation: String = "") {
        self.from = from
        self.to = to
        self.piece = piece
        self.capturedPiece = capturedPiece
        self.isEnPassant = isEnPassant
        self.isCastling = isCastling
        self.promotionPiece = promotionPiece
        self.isCheck = isCheck
        self.isCheckmate = isCheckmate
        self.moveNotation = moveNotation
    }
}

// MARK: - Game State
enum GameState {
    case active
    case check(PieceColor)
    case checkmate(PieceColor) // Winner
    case stalemate
    case draw
    case resigned(PieceColor) // Winner
}

// MARK: - Chess Engine
class ChessEngine: ObservableObject {
    @Published var board: [[ChessPiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var currentPlayer: PieceColor = .white
    @Published var gameState: GameState = .active
    @Published var moveHistory: [ChessMove] = []
    @Published var capturedPieces: [ChessPiece] = []
    
    // Special move tracking
    private var enPassantTarget: ChessPosition?
    private var whiteKingMoved = false
    private var blackKingMoved = false
    private var whiteKingsideRookMoved = false
    private var whiteQueensideRookMoved = false
    private var blackKingsideRookMoved = false
    private var blackQueensideRookMoved = false
    
    // Fifty-move rule and repetition
    private var halfmoveClock = 0
    private var positionHistory: [String] = []
    
    init() {
        setupInitialPosition()
    }
    
    // MARK: - Board Setup
    func setupInitialPosition() {
        // Clear board
        board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        
        // Place white pieces
        board[0][0] = ChessPiece(type: .rook, color: .white)
        board[1][0] = ChessPiece(type: .knight, color: .white)
        board[2][0] = ChessPiece(type: .bishop, color: .white)
        board[3][0] = ChessPiece(type: .queen, color: .white)
        board[4][0] = ChessPiece(type: .king, color: .white)
        board[5][0] = ChessPiece(type: .bishop, color: .white)
        board[6][0] = ChessPiece(type: .knight, color: .white)
        board[7][0] = ChessPiece(type: .rook, color: .white)
        
        for file in 0..<8 {
            board[file][1] = ChessPiece(type: .pawn, color: .white)
        }
        
        // Place black pieces
        board[0][7] = ChessPiece(type: .rook, color: .black)
        board[1][7] = ChessPiece(type: .knight, color: .black)
        board[2][7] = ChessPiece(type: .bishop, color: .black)
        board[3][7] = ChessPiece(type: .queen, color: .black)
        board[4][7] = ChessPiece(type: .king, color: .black)
        board[5][7] = ChessPiece(type: .bishop, color: .black)
        board[6][7] = ChessPiece(type: .knight, color: .black)
        board[7][7] = ChessPiece(type: .rook, color: .black)
        
        for file in 0..<8 {
            board[file][6] = ChessPiece(type: .pawn, color: .black)
        }
        
        // Reset game state
        currentPlayer = .white
        gameState = .active
        moveHistory = []
        capturedPieces = []
        enPassantTarget = nil
        whiteKingMoved = false
        blackKingMoved = false
        whiteKingsideRookMoved = false
        whiteQueensideRookMoved = false
        blackKingsideRookMoved = false
        blackQueensideRookMoved = false
        halfmoveClock = 0
        positionHistory = [getFEN()]
    }
    
    // MARK: - Move Validation and Execution
    func isValidMove(from: ChessPosition, to: ChessPosition) -> Bool {
        guard from.isValid && to.isValid else { return false }
        guard let piece = board[from.file][from.rank] else { return false }
        guard piece.color == currentPlayer else { return false }
        
        // Can't capture own piece
        if let targetPiece = board[to.file][to.rank], targetPiece.color == piece.color {
            return false
        }
        
        // Check piece-specific movement rules
        if !isValidPieceMove(piece: piece, from: from, to: to) {
            return false
        }
        
        // Check if move would leave king in check
        return !wouldLeaveKingInCheck(from: from, to: to)
    }
    
    func makeMove(from: ChessPosition, to: ChessPosition, promotionPiece: PieceType? = nil) -> Bool {
        guard isValidMove(from: from, to: to) else { return false }
        
        let piece = board[from.file][from.rank]!
        let capturedPiece = board[to.file][to.rank]
        
        // Handle special moves
        let isEnPassant = handleEnPassant(piece: piece, from: from, to: to)
        let isCastling = handleCastling(piece: piece, from: from, to: to)
        
        // Execute the move
        board[to.file][to.rank] = piece
        board[from.file][from.rank] = nil
        
        // Handle pawn promotion
        if piece.type == .pawn && (to.rank == 0 || to.rank == 7) {
            let promoteTo = promotionPiece ?? .queen
            board[to.file][to.rank] = ChessPiece(type: promoteTo, color: piece.color, hasMoved: true)
        } else {
            board[to.file][to.rank]?.hasMoved = true
        }
        
        // Update castling rights
        updateCastlingRights(piece: piece, from: from, to: to)
        
        // Add captured piece to list
        if let captured = capturedPiece {
            capturedPieces.append(captured)
        }
        
        // Update en passant target
        updateEnPassantTarget(piece: piece, from: from, to: to)
        
        // Create move record
        let isCheck = isKingInCheck(color: currentPlayer.opposite)
        let isCheckmate = isCheck && isCheckmate(color: currentPlayer.opposite)
        let moveNotation = generateMoveNotation(from: from, to: to, piece: piece, 
                                              capturedPiece: capturedPiece, isCheck: isCheck, 
                                              isCheckmate: isCheckmate, isCastling: isCastling,
                                              promotionPiece: promotionPiece)
        
        let move = ChessMove(from: from, to: to, piece: piece, capturedPiece: capturedPiece,
                           isEnPassant: isEnPassant, isCastling: isCastling, 
                           promotionPiece: promotionPiece, isCheck: isCheck, 
                           isCheckmate: isCheckmate, moveNotation: moveNotation)
        
        moveHistory.append(move)
        
        // Update halfmove clock
        if piece.type == .pawn || capturedPiece != nil {
            halfmoveClock = 0
        } else {
            halfmoveClock += 1
        }
        
        // Switch players
        currentPlayer = currentPlayer.opposite
        
        // Update game state
        updateGameState()
        
        // Add position to history
        positionHistory.append(getFEN())
        
        return true
    }
    
    // MARK: - Piece Movement Rules
    private func isValidPieceMove(piece: ChessPiece, from: ChessPosition, to: ChessPosition) -> Bool {
        switch piece.type {
        case .pawn:
            return isValidPawnMove(piece: piece, from: from, to: to)
        case .rook:
            return isValidRookMove(from: from, to: to)
        case .knight:
            return isValidKnightMove(from: from, to: to)
        case .bishop:
            return isValidBishopMove(from: from, to: to)
        case .queen:
            return isValidQueenMove(from: from, to: to)
        case .king:
            return isValidKingMove(from: from, to: to)
        }
    }
    
    private func isValidPawnMove(piece: ChessPiece, from: ChessPosition, to: ChessPosition) -> Bool {
        let direction = piece.color == .white ? 1 : -1
        let startRank = piece.color == .white ? 1 : 6
        let fileDiff = to.file - from.file
        let rankDiff = to.rank - from.rank
        
        // Forward move
        if fileDiff == 0 {
            if rankDiff == direction && board[to.file][to.rank] == nil {
                return true
            }
            // Double move from starting position
            if from.rank == startRank && rankDiff == 2 * direction && board[to.file][to.rank] == nil {
                return true
            }
        }
        
        // Diagonal capture
        if abs(fileDiff) == 1 && rankDiff == direction {
            if board[to.file][to.rank] != nil {
                return true
            }
            // En passant
            if let enPassantPos = enPassantTarget, enPassantPos == to {
                return true
            }
        }
        
        return false
    }
    
    private func isValidRookMove(from: ChessPosition, to: ChessPosition) -> Bool {
        return (from.file == to.file || from.rank == to.rank) && isPathClear(from: from, to: to)
    }
    
    private func isValidKnightMove(from: ChessPosition, to: ChessPosition) -> Bool {
        let fileDiff = abs(to.file - from.file)
        let rankDiff = abs(to.rank - from.rank)
        return (fileDiff == 2 && rankDiff == 1) || (fileDiff == 1 && rankDiff == 2)
    }
    
    private func isValidBishopMove(from: ChessPosition, to: ChessPosition) -> Bool {
        return abs(to.file - from.file) == abs(to.rank - from.rank) && isPathClear(from: from, to: to)
    }
    
    private func isValidQueenMove(from: ChessPosition, to: ChessPosition) -> Bool {
        return isValidRookMove(from: from, to: to) || isValidBishopMove(from: from, to: to)
    }
    
    private func isValidKingMove(from: ChessPosition, to: ChessPosition) -> Bool {
        let fileDiff = abs(to.file - from.file)
        let rankDiff = abs(to.rank - from.rank)
        
        // Normal king move
        if fileDiff <= 1 && rankDiff <= 1 {
            return true
        }
        
        // Castling
        if rankDiff == 0 && fileDiff == 2 {
            return canCastle(from: from, to: to)
        }
        
        return false
    }
    
    // MARK: - Path Checking
    private func isPathClear(from: ChessPosition, to: ChessPosition) -> Bool {
        let fileStep = to.file == from.file ? 0 : (to.file > from.file ? 1 : -1)
        let rankStep = to.rank == from.rank ? 0 : (to.rank > from.rank ? 1 : -1)
        
        var currentFile = from.file + fileStep
        var currentRank = from.rank + rankStep
        
        while currentFile != to.file || currentRank != to.rank {
            if board[currentFile][currentRank] != nil {
                return false
            }
            currentFile += fileStep
            currentRank += rankStep
        }
        
        return true
    }
    
    // MARK: - Special Moves
    private func canCastle(from: ChessPosition, to: ChessPosition) -> Bool {
        guard let king = board[from.file][from.rank], king.type == .king else { return false }
        
        let isKingside = to.file > from.file
        let rookFile = isKingside ? 7 : 0
        let rookPosition = ChessPosition(rookFile, from.rank)
        
        guard let rook = board[rookFile][from.rank], rook.type == .rook, rook.color == king.color else {
            return false
        }
        
        // Check if king or rook have moved
        if king.hasMoved || rook.hasMoved {
            return false
        }
        
        // Check if path is clear
        let startFile = min(from.file, rookFile) + 1
        let endFile = max(from.file, rookFile) - 1
        for file in startFile...endFile {
            if board[file][from.rank] != nil {
                return false
            }
        }
        
        // Check if king is in check or would pass through check
        if isKingInCheck(color: king.color) {
            return false
        }
        
        let kingPath = isKingside ? [from.file + 1, from.file + 2] : [from.file - 1, from.file - 2]
        for file in kingPath {
            let testPos = ChessPosition(file, from.rank)
            if isPositionAttacked(position: testPos, by: king.color.opposite) {
                return false
            }
        }
        
        return true
    }
    
    private func handleCastling(piece: ChessPiece, from: ChessPosition, to: ChessPosition) -> Bool {
        guard piece.type == .king && abs(to.file - from.file) == 2 else { return false }
        
        let isKingside = to.file > from.file
        let rookFromFile = isKingside ? 7 : 0
        let rookToFile = isKingside ? 5 : 3
        
        // Move the rook
        let rook = board[rookFromFile][from.rank]!
        board[rookToFile][from.rank] = rook
        board[rookFromFile][from.rank] = nil
        board[rookToFile][from.rank]?.hasMoved = true
        
        return true
    }
    
    private func handleEnPassant(piece: ChessPiece, from: ChessPosition, to: ChessPosition) -> Bool {
        guard piece.type == .pawn,
              let enPassantPos = enPassantTarget,
              enPassantPos == to else { return false }
        
        // Remove the captured pawn
        let capturedPawnRank = piece.color == .white ? to.rank - 1 : to.rank + 1
        if let capturedPawn = board[to.file][capturedPawnRank] {
            capturedPieces.append(capturedPawn)
            board[to.file][capturedPawnRank] = nil
        }
        
        return true
    }
    
    private func updateEnPassantTarget(piece: ChessPiece, from: ChessPosition, to: ChessPosition) {
        enPassantTarget = nil
        
        if piece.type == .pawn && abs(to.rank - from.rank) == 2 {
            let targetRank = piece.color == .white ? from.rank + 1 : from.rank - 1
            enPassantTarget = ChessPosition(from.file, targetRank)
        }
    }
    
    private func updateCastlingRights(piece: ChessPiece, from: ChessPosition, to: ChessPosition) {
        if piece.type == .king {
            if piece.color == .white {
                whiteKingMoved = true
            } else {
                blackKingMoved = true
            }
        } else if piece.type == .rook {
            if piece.color == .white {
                if from.file == 0 { whiteQueensideRookMoved = true }
                if from.file == 7 { whiteKingsideRookMoved = true }
            } else {
                if from.file == 0 { blackQueensideRookMoved = true }
                if from.file == 7 { blackKingsideRookMoved = true }
            }
        }
    }
    
    // MARK: - Check Detection
    func isKingInCheck(color: PieceColor) -> Bool {
        guard let kingPosition = findKing(color: color) else { return false }
        return isPositionAttacked(position: kingPosition, by: color.opposite)
    }
    
    private func findKing(color: PieceColor) -> ChessPosition? {
        for file in 0..<8 {
            for rank in 0..<8 {
                if let piece = board[file][rank], piece.type == .king && piece.color == color {
                    return ChessPosition(file, rank)
                }
            }
        }
        return nil
    }
    
    private func isPositionAttacked(position: ChessPosition, by color: PieceColor) -> Bool {
        for file in 0..<8 {
            for rank in 0..<8 {
                if let piece = board[file][rank], piece.color == color {
                    let from = ChessPosition(file, rank)
                    if isValidPieceMove(piece: piece, from: from, to: position) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func wouldLeaveKingInCheck(from: ChessPosition, to: ChessPosition) -> Bool {
        // Make temporary move
        let piece = board[from.file][from.rank]!
        let capturedPiece = board[to.file][to.rank]
        
        board[to.file][to.rank] = piece
        board[from.file][from.rank] = nil
        
        let inCheck = isKingInCheck(color: piece.color)
        
        // Undo temporary move
        board[from.file][from.rank] = piece
        board[to.file][to.rank] = capturedPiece
        
        return inCheck
    }
    
    // MARK: - Game State Management
    private func updateGameState() {
        let opponent = currentPlayer
        
        if isKingInCheck(color: opponent) {
            if isCheckmate(color: opponent) {
                gameState = .checkmate(currentPlayer.opposite)
            } else {
                gameState = .check(opponent)
            }
        } else if isStalemate(color: opponent) {
            gameState = .stalemate
        } else if isDraw() {
            gameState = .draw
        } else {
            gameState = .active
        }
    }
    
    private func isCheckmate(color: PieceColor) -> Bool {
        return !hasLegalMoves(color: color) && isKingInCheck(color: color)
    }
    
    private func isStalemate(color: PieceColor) -> Bool {
        return !hasLegalMoves(color: color) && !isKingInCheck(color: color)
    }
    
    private func hasLegalMoves(color: PieceColor) -> Bool {
        for file in 0..<8 {
            for rank in 0..<8 {
                if let piece = board[file][rank], piece.color == color {
                    let from = ChessPosition(file, rank)
                    for toFile in 0..<8 {
                        for toRank in 0..<8 {
                            let to = ChessPosition(toFile, toRank)
                            if isValidMove(from: from, to: to) {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    private func isDraw() -> Bool {
        // Fifty-move rule
        if halfmoveClock >= 100 {
            return true
        }
        
        // Threefold repetition
        let currentPosition = getFEN()
        let repetitions = positionHistory.filter { $0 == currentPosition }.count
        if repetitions >= 3 {
            return true
        }
        
        // Insufficient material
        return isInsufficientMaterial()
    }
    
    private func isInsufficientMaterial() -> Bool {
        var whitePieces: [PieceType] = []
        var blackPieces: [PieceType] = []
        
        for file in 0..<8 {
            for rank in 0..<8 {
                if let piece = board[file][rank] {
                    if piece.color == .white {
                        whitePieces.append(piece.type)
                    } else {
                        blackPieces.append(piece.type)
                    }
                }
            }
        }
        
        // King vs King
        if whitePieces.count == 1 && blackPieces.count == 1 {
            return true
        }
        
        // King and Bishop/Knight vs King
        if (whitePieces.count == 2 && blackPieces.count == 1) ||
           (whitePieces.count == 1 && blackPieces.count == 2) {
            let allPieces = whitePieces + blackPieces
            let nonKings = allPieces.filter { $0 != .king }
            return nonKings.count == 1 && (nonKings.contains(.bishop) || nonKings.contains(.knight))
        }
        
        return false
    }
    
    // MARK: - Utility Functions
    func getLegalMoves(from position: ChessPosition) -> [ChessPosition] {
        var legalMoves: [ChessPosition] = []
        
        for file in 0..<8 {
            for rank in 0..<8 {
                let to = ChessPosition(file, rank)
                if isValidMove(from: position, to: to) {
                    legalMoves.append(to)
                }
            }
        }
        
        return legalMoves
    }
    
    func getAllLegalMoves(for color: PieceColor) -> [(from: ChessPosition, to: ChessPosition)] {
        var moves: [(ChessPosition, ChessPosition)] = []
        
        for file in 0..<8 {
            for rank in 0..<8 {
                if let piece = board[file][rank], piece.color == color {
                    let from = ChessPosition(file, rank)
                    let legalMoves = getLegalMoves(from: from)
                    for to in legalMoves {
                        moves.append((from, to))
                    }
                }
            }
        }
        
        return moves
    }
    
    // MARK: - FEN Support
    func getFEN() -> String {
        var fen = ""
        
        // Board position
        for rank in (0..<8).reversed() {
            var emptyCount = 0
            for file in 0..<8 {
                if let piece = board[file][rank] {
                    if emptyCount > 0 {
                        fen += "\(emptyCount)"
                        emptyCount = 0
                    }
                    let symbol = piece.type.rawValue
                    fen += piece.color == .white ? symbol.uppercased() : symbol
                } else {
                    emptyCount += 1
                }
            }
            if emptyCount > 0 {
                fen += "\(emptyCount)"
            }
            if rank > 0 {
                fen += "/"
            }
        }
        
        // Active color
        fen += " \(currentPlayer.rawValue)"
        
        // Castling rights
        var castling = ""
        if !whiteKingMoved && !whiteKingsideRookMoved { castling += "K" }
        if !whiteKingMoved && !whiteQueensideRookMoved { castling += "Q" }
        if !blackKingMoved && !blackKingsideRookMoved { castling += "k" }
        if !blackKingMoved && !blackQueensideRookMoved { castling += "q" }
        fen += " \(castling.isEmpty ? "-" : castling)"
        
        // En passant
        if let enPassant = enPassantTarget {
            fen += " \(enPassant.algebraic)"
        } else {
            fen += " -"
        }
        
        // Halfmove clock and fullmove number
        let fullmoves = (moveHistory.count / 2) + 1
        fen += " \(halfmoveClock) \(fullmoves)"
        
        return fen
    }
    
    // MARK: - Move Notation
    private func generateMoveNotation(from: ChessPosition, to: ChessPosition, piece: ChessPiece,
                                    capturedPiece: ChessPiece?, isCheck: Bool, isCheckmate: Bool,
                                    isCastling: Bool, promotionPiece: PieceType?) -> String {
        if isCastling {
            return to.file > from.file ? "O-O" : "O-O-O"
        }
        
        var notation = ""
        
        // Piece symbol (except for pawns)
        if piece.type != .pawn {
            notation += piece.type.rawValue.uppercased()
        }
        
        // Disambiguation if needed
        let ambiguousFrom = getAmbiguousFromSquares(piece: piece, from: from, to: to)
        if !ambiguousFrom.isEmpty {
            if ambiguousFrom.allSatisfy({ $0.file != from.file }) {
                notation += String("abcdefgh"["abcdefgh".index("abcdefgh".startIndex, offsetBy: from.file)])
            } else if ambiguousFrom.allSatisfy({ $0.rank != from.rank }) {
                notation += "\(from.rank + 1)"
            } else {
                notation += from.algebraic
            }
        } else if piece.type == .pawn && capturedPiece != nil {
            notation += String("abcdefgh"["abcdefgh".index("abcdefgh".startIndex, offsetBy: from.file)])
        }
        
        // Capture
        if capturedPiece != nil {
            notation += "x"
        }
        
        // Destination square
        notation += to.algebraic
        
        // Promotion
        if let promotion = promotionPiece {
            notation += "=\(promotion.rawValue.uppercased())"
        }
        
        // Check/Checkmate
        if isCheckmate {
            notation += "#"
        } else if isCheck {
            notation += "+"
        }
        
        return notation
    }
    
    private func getAmbiguousFromSquares(piece: ChessPiece, from: ChessPosition, to: ChessPosition) -> [ChessPosition] {
        var ambiguous: [ChessPosition] = []
        
        for file in 0..<8 {
            for rank in 0..<8 {
                let pos = ChessPosition(file, rank)
                if pos != from,
                   let otherPiece = board[file][rank],
                   otherPiece.type == piece.type && otherPiece.color == piece.color,
                   isValidMove(from: pos, to: to) {
                    ambiguous.append(pos)
                }
            }
        }
        
        return ambiguous
    }
    
    // MARK: - Game Control
    func resign(color: PieceColor) {
        gameState = .resigned(color.opposite)
    }
    
    func offerDraw() {
        gameState = .draw
    }
    
    func undoLastMove() {
        // Implementation for undo functionality
        // This would require storing more game state information
    }
}
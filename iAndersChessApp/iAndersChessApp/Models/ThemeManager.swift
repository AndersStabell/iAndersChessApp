import Foundation
import SwiftUI

// MARK: - Advanced Board Theme
struct AdvancedBoardTheme: Codable, Identifiable {
    let id = UUID()
    let name: String
    let lightSquareColor: Color
    let darkSquareColor: Color
    let borderColor: Color
    let coordinateColor: Color
    let highlightColor: Color
    let selectionColor: Color
    let lastMoveColor: Color
    let checkColor: Color
    let backgroundGradient: [Color]?
    let texture: String? // Asset name for texture
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let shadowEnabled: Bool
    let shadowColor: Color
    let shadowRadius: CGFloat
    let animationDuration: Double
    
    // Predefined themes
    static let classic = AdvancedBoardTheme(
        name: "Classic",
        lightSquareColor: Color(red: 0.93, green: 0.93, blue: 0.82),
        darkSquareColor: Color(red: 0.46, green: 0.59, blue: 0.34),
        borderColor: Color(red: 0.3, green: 0.3, blue: 0.3),
        coordinateColor: Color.black,
        highlightColor: Color.yellow.opacity(0.6),
        selectionColor: Color.blue,
        lastMoveColor: Color.yellow.opacity(0.4),
        checkColor: Color.red.opacity(0.6),
        backgroundGradient: nil,
        texture: nil,
        borderWidth: 2,
        cornerRadius: 0,
        shadowEnabled: false,
        shadowColor: Color.black.opacity(0.3),
        shadowRadius: 5,
        animationDuration: 0.25
    )
    
    static let modern = AdvancedBoardTheme(
        name: "Modern",
        lightSquareColor: Color(red: 0.95, green: 0.95, blue: 0.95),
        darkSquareColor: Color(red: 0.4, green: 0.4, blue: 0.4),
        borderColor: Color.gray,
        coordinateColor: Color.primary,
        highlightColor: Color.blue.opacity(0.5),
        selectionColor: Color.blue,
        lastMoveColor: Color.orange.opacity(0.5),
        checkColor: Color.red.opacity(0.7),
        backgroundGradient: [Color.white, Color.gray.opacity(0.1)],
        texture: nil,
        borderWidth: 1,
        cornerRadius: 8,
        shadowEnabled: true,
        shadowColor: Color.black.opacity(0.2),
        shadowRadius: 10,
        animationDuration: 0.3
    )
    
    static let wood = AdvancedBoardTheme(
        name: "Wood",
        lightSquareColor: Color(red: 0.96, green: 0.87, blue: 0.70),
        darkSquareColor: Color(red: 0.65, green: 0.42, blue: 0.24),
        borderColor: Color(red: 0.4, green: 0.2, blue: 0.1),
        coordinateColor: Color(red: 0.3, green: 0.15, blue: 0.05),
        highlightColor: Color.yellow.opacity(0.7),
        selectionColor: Color.orange,
        lastMoveColor: Color.yellow.opacity(0.5),
        checkColor: Color.red.opacity(0.8),
        backgroundGradient: [Color(red: 0.8, green: 0.6, blue: 0.4), Color(red: 0.6, green: 0.4, blue: 0.2)],
        texture: "wood_texture",
        borderWidth: 3,
        cornerRadius: 12,
        shadowEnabled: true,
        shadowColor: Color.black.opacity(0.4),
        shadowRadius: 8,
        animationDuration: 0.2
    )
    
    static let neon = AdvancedBoardTheme(
        name: "Neon",
        lightSquareColor: Color.black,
        darkSquareColor: Color(red: 0.1, green: 0.1, blue: 0.2),
        borderColor: Color.cyan,
        coordinateColor: Color.cyan,
        highlightColor: Color.cyan.opacity(0.8),
        selectionColor: Color.cyan,
        lastMoveColor: Color.purple.opacity(0.6),
        checkColor: Color.red,
        backgroundGradient: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.15)],
        texture: nil,
        borderWidth: 2,
        cornerRadius: 4,
        shadowEnabled: true,
        shadowColor: Color.cyan.opacity(0.5),
        shadowRadius: 15,
        animationDuration: 0.4
    )
}

// MARK: - Piece Theme
struct PieceTheme: Codable, Identifiable {
    let id = UUID()
    let name: String
    let style: PieceStyle
    let whiteColor: Color
    let blackColor: Color
    let outlineColor: Color?
    let outlineWidth: CGFloat
    let shadowEnabled: Bool
    let shadowColor: Color
    let shadowOffset: CGSize
    let shadowRadius: CGFloat
    let glowEnabled: Bool
    let glowColor: Color
    let glowRadius: CGFloat
    let customSymbols: [PieceType: [PieceColor: String]]?
    
    static let traditional = PieceTheme(
        name: "Traditional",
        style: .traditional,
        whiteColor: Color.primary,
        blackColor: Color.primary,
        outlineColor: nil,
        outlineWidth: 0,
        shadowEnabled: true,
        shadowColor: Color.black.opacity(0.3),
        shadowOffset: CGSize(width: 1, height: 1),
        shadowRadius: 2,
        glowEnabled: false,
        glowColor: Color.clear,
        glowRadius: 0,
        customSymbols: nil
    )
    
    static let colorful = PieceTheme(
        name: "Colorful",
        style: .traditional,
        whiteColor: Color.white,
        blackColor: Color.black,
        outlineColor: Color.gray,
        outlineWidth: 1,
        shadowEnabled: true,
        shadowColor: Color.black.opacity(0.5),
        shadowOffset: CGSize(width: 2, height: 2),
        shadowRadius: 3,
        glowEnabled: false,
        glowColor: Color.clear,
        glowRadius: 0,
        customSymbols: nil
    )
    
    static let neon = PieceTheme(
        name: "Neon",
        style: .modern,
        whiteColor: Color.cyan,
        blackColor: Color.purple,
        outlineColor: Color.white,
        outlineWidth: 2,
        shadowEnabled: false,
        shadowColor: Color.clear,
        shadowOffset: CGSize.zero,
        shadowRadius: 0,
        glowEnabled: true,
        glowColor: Color.cyan,
        glowRadius: 5,
        customSymbols: nil
    )
}

// MARK: - Animation Theme
struct AnimationTheme: Codable {
    let name: String
    let moveAnimationDuration: Double
    let captureAnimationDuration: Double
    let selectionAnimationDuration: Double
    let highlightAnimationDuration: Double
    let pieceScaleOnSelection: CGFloat
    let bounceAnimation: Bool
    let fadeAnimation: Bool
    let rotateOnCapture: Bool
    let particleEffects: Bool
    
    static let subtle = AnimationTheme(
        name: "Subtle",
        moveAnimationDuration: 0.25,
        captureAnimationDuration: 0.3,
        selectionAnimationDuration: 0.15,
        highlightAnimationDuration: 0.2,
        pieceScaleOnSelection: 1.05,
        bounceAnimation: false,
        fadeAnimation: true,
        rotateOnCapture: false,
        particleEffects: false
    )
    
    static let dynamic = AnimationTheme(
        name: "Dynamic",
        moveAnimationDuration: 0.4,
        captureAnimationDuration: 0.5,
        selectionAnimationDuration: 0.2,
        highlightAnimationDuration: 0.3,
        pieceScaleOnSelection: 1.1,
        bounceAnimation: true,
        fadeAnimation: true,
        rotateOnCapture: true,
        particleEffects: true
    )
    
    static let instant = AnimationTheme(
        name: "Instant",
        moveAnimationDuration: 0.0,
        captureAnimationDuration: 0.0,
        selectionAnimationDuration: 0.0,
        highlightAnimationDuration: 0.0,
        pieceScaleOnSelection: 1.0,
        bounceAnimation: false,
        fadeAnimation: false,
        rotateOnCapture: false,
        particleEffects: false
    )
}

// MARK: - Complete Theme
struct CompleteTheme: Codable, Identifiable {
    let id = UUID()
    let name: String
    let boardTheme: AdvancedBoardTheme
    let pieceTheme: PieceTheme
    let animationTheme: AnimationTheme
    let isCustom: Bool
    let createdDate: Date
    
    static let classicTheme = CompleteTheme(
        name: "Classic",
        boardTheme: .classic,
        pieceTheme: .traditional,
        animationTheme: .subtle,
        isCustom: false,
        createdDate: Date()
    )
    
    static let modernTheme = CompleteTheme(
        name: "Modern",
        boardTheme: .modern,
        pieceTheme: .colorful,
        animationTheme: .dynamic,
        isCustom: false,
        createdDate: Date()
    )
    
    static let neonTheme = CompleteTheme(
        name: "Neon",
        boardTheme: .neon,
        pieceTheme: .neon,
        animationTheme: .dynamic,
        isCustom: false,
        createdDate: Date()
    )
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var currentTheme: CompleteTheme = .classicTheme
    @Published var customThemes: [CompleteTheme] = []
    @Published var presetThemes: [CompleteTheme] = [.classicTheme, .modernTheme, .neonTheme]
    
    // Theme editor state
    @Published var isEditing: Bool = false
    @Published var editingTheme: CompleteTheme?
    
    private let storage = UserDefaults.standard
    private let themesKey = "custom_themes"
    private let currentThemeKey = "current_theme"
    
    init() {
        loadThemes()
        loadCurrentTheme()
    }
    
    // MARK: - Theme Management
    func setCurrentTheme(_ theme: CompleteTheme) {
        currentTheme = theme
        saveCurrentTheme()
    }
    
    func createCustomTheme(name: String, boardTheme: AdvancedBoardTheme, 
                          pieceTheme: PieceTheme, animationTheme: AnimationTheme) {
        let customTheme = CompleteTheme(
            name: name,
            boardTheme: boardTheme,
            pieceTheme: pieceTheme,
            animationTheme: animationTheme,
            isCustom: true,
            createdDate: Date()
        )
        
        customThemes.append(customTheme)
        saveThemes()
    }
    
    func updateCustomTheme(_ theme: CompleteTheme) {
        if let index = customThemes.firstIndex(where: { $0.id == theme.id }) {
            customThemes[index] = theme
            saveThemes()
            
            // Update current theme if it's the one being edited
            if currentTheme.id == theme.id {
                currentTheme = theme
                saveCurrentTheme()
            }
        }
    }
    
    func deleteCustomTheme(_ theme: CompleteTheme) {
        customThemes.removeAll { $0.id == theme.id }
        saveThemes()
        
        // Switch to default theme if current theme was deleted
        if currentTheme.id == theme.id {
            currentTheme = .classicTheme
            saveCurrentTheme()
        }
    }
    
    func duplicateTheme(_ theme: CompleteTheme) -> CompleteTheme {
        return CompleteTheme(
            name: "\(theme.name) Copy",
            boardTheme: theme.boardTheme,
            pieceTheme: theme.pieceTheme,
            animationTheme: theme.animationTheme,
            isCustom: true,
            createdDate: Date()
        )
    }
    
    // MARK: - Theme Editor
    func startEditing(_ theme: CompleteTheme? = nil) {
        editingTheme = theme ?? createBlankTheme()
        isEditing = true
    }
    
    func saveEditingTheme() {
        guard let theme = editingTheme else { return }
        
        if theme.isCustom && customThemes.contains(where: { $0.id == theme.id }) {
            updateCustomTheme(theme)
        } else {
            createCustomTheme(
                name: theme.name,
                boardTheme: theme.boardTheme,
                pieceTheme: theme.pieceTheme,
                animationTheme: theme.animationTheme
            )
        }
        
        isEditing = false
        editingTheme = nil
    }
    
    func cancelEditing() {
        isEditing = false
        editingTheme = nil
    }
    
    private func createBlankTheme() -> CompleteTheme {
        return CompleteTheme(
            name: "Custom Theme",
            boardTheme: .classic,
            pieceTheme: .traditional,
            animationTheme: .subtle,
            isCustom: true,
            createdDate: Date()
        )
    }
    
    // MARK: - Preset Theme Creation
    func createWoodTheme() -> CompleteTheme {
        return CompleteTheme(
            name: "Wood",
            boardTheme: .wood,
            pieceTheme: .traditional,
            animationTheme: .subtle,
            isCustom: false,
            createdDate: Date()
        )
    }
    
    func createMinimalistTheme() -> CompleteTheme {
        let minimalistBoard = AdvancedBoardTheme(
            name: "Minimalist",
            lightSquareColor: Color.white,
            darkSquareColor: Color(red: 0.9, green: 0.9, blue: 0.9),
            borderColor: Color.clear,
            coordinateColor: Color.gray,
            highlightColor: Color.blue.opacity(0.3),
            selectionColor: Color.blue.opacity(0.5),
            lastMoveColor: Color.gray.opacity(0.3),
            checkColor: Color.red.opacity(0.4),
            backgroundGradient: nil,
            texture: nil,
            borderWidth: 0,
            cornerRadius: 0,
            shadowEnabled: false,
            shadowColor: Color.clear,
            shadowRadius: 0,
            animationDuration: 0.2
        )
        
        let minimalistPieces = PieceTheme(
            name: "Minimalist",
            style: .minimalist,
            whiteColor: Color.black,
            blackColor: Color.gray,
            outlineColor: nil,
            outlineWidth: 0,
            shadowEnabled: false,
            shadowColor: Color.clear,
            shadowOffset: CGSize.zero,
            shadowRadius: 0,
            glowEnabled: false,
            glowColor: Color.clear,
            glowRadius: 0,
            customSymbols: nil
        )
        
        return CompleteTheme(
            name: "Minimalist",
            boardTheme: minimalistBoard,
            pieceTheme: minimalistPieces,
            animationTheme: .subtle,
            isCustom: false,
            createdDate: Date()
        )
    }
    
    // MARK: - Theme Import/Export
    func exportTheme(_ theme: CompleteTheme) -> Data? {
        do {
            return try JSONEncoder().encode(theme)
        } catch {
            print("Error exporting theme: \(error)")
            return nil
        }
    }
    
    func importTheme(from data: Data) -> Bool {
        do {
            let theme = try JSONDecoder().decode(CompleteTheme.self, from: data)
            let importedTheme = CompleteTheme(
                name: "\(theme.name) (Imported)",
                boardTheme: theme.boardTheme,
                pieceTheme: theme.pieceTheme,
                animationTheme: theme.animationTheme,
                isCustom: true,
                createdDate: Date()
            )
            customThemes.append(importedTheme)
            saveThemes()
            return true
        } catch {
            print("Error importing theme: \(error)")
            return false
        }
    }
    
    // MARK: - Theme Sharing
    func shareTheme(_ theme: CompleteTheme) -> String {
        // Create a shareable theme code
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(theme),
           let base64 = data.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlSafe) {
            return "ianderschess://theme/\(base64)"
        }
        return ""
    }
    
    func importThemeFromCode(_ code: String) -> Bool {
        guard code.hasPrefix("ianderschess://theme/"),
              let base64 = code.replacingOccurrences(of: "ianderschess://theme/", with: "")
                .removingPercentEncoding,
              let data = Data(base64Encoded: base64) else {
            return false
        }
        
        return importTheme(from: data)
    }
    
    // MARK: - Color Utilities
    func generateRandomTheme() -> CompleteTheme {
        let randomColors = [
            Color.red, Color.blue, Color.green, Color.orange,
            Color.purple, Color.pink, Color.yellow, Color.cyan
        ]
        
        let lightColor = randomColors.randomElement()!.opacity(0.3)
        let darkColor = randomColors.randomElement()!.opacity(0.7)
        
        let randomBoard = AdvancedBoardTheme(
            name: "Random",
            lightSquareColor: lightColor,
            darkSquareColor: darkColor,
            borderColor: randomColors.randomElement()!,
            coordinateColor: Color.primary,
            highlightColor: Color.yellow.opacity(0.6),
            selectionColor: Color.blue,
            lastMoveColor: Color.orange.opacity(0.5),
            checkColor: Color.red.opacity(0.7),
            backgroundGradient: [randomColors.randomElement()!.opacity(0.1), randomColors.randomElement()!.opacity(0.2)],
            texture: nil,
            borderWidth: CGFloat.random(in: 0...3),
            cornerRadius: CGFloat.random(in: 0...15),
            shadowEnabled: Bool.random(),
            shadowColor: Color.black.opacity(0.3),
            shadowRadius: CGFloat.random(in: 5...15),
            animationDuration: Double.random(in: 0.1...0.5)
        )
        
        let randomPieces = PieceTheme(
            name: "Random",
            style: PieceStyle.allCases.randomElement()!,
            whiteColor: randomColors.randomElement()!,
            blackColor: randomColors.randomElement()!,
            outlineColor: Bool.random() ? randomColors.randomElement()! : nil,
            outlineWidth: CGFloat.random(in: 0...2),
            shadowEnabled: Bool.random(),
            shadowColor: Color.black.opacity(0.4),
            shadowOffset: CGSize(width: Double.random(in: -2...2), height: Double.random(in: -2...2)),
            shadowRadius: CGFloat.random(in: 1...5),
            glowEnabled: Bool.random(),
            glowColor: randomColors.randomElement()!,
            glowRadius: CGFloat.random(in: 2...8),
            customSymbols: nil
        )
        
        return CompleteTheme(
            name: "Random Theme",
            boardTheme: randomBoard,
            pieceTheme: randomPieces,
            animationTheme: AnimationTheme.allCases.randomElement()!,
            isCustom: true,
            createdDate: Date()
        )
    }
    
    // MARK: - Persistence
    private func saveThemes() {
        if let data = try? JSONEncoder().encode(customThemes) {
            storage.set(data, forKey: themesKey)
        }
    }
    
    private func loadThemes() {
        if let data = storage.data(forKey: themesKey),
           let themes = try? JSONDecoder().decode([CompleteTheme].self, from: data) {
            customThemes = themes
        }
    }
    
    private func saveCurrentTheme() {
        if let data = try? JSONEncoder().encode(currentTheme) {
            storage.set(data, forKey: currentThemeKey)
        }
    }
    
    private func loadCurrentTheme() {
        if let data = storage.data(forKey: currentThemeKey),
           let theme = try? JSONDecoder().decode(CompleteTheme.self, from: data) {
            currentTheme = theme
        }
    }
}

// MARK: - Extensions
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        try container.encode(Double(red), forKey: .red)
        try container.encode(Double(green), forKey: .green)
        try container.encode(Double(blue), forKey: .blue)
        try container.encode(Double(alpha), forKey: .alpha)
    }
}

extension CGSize: Codable {
    enum CodingKeys: String, CodingKey {
        case width, height
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(width: width, height: height)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
}

extension AnimationTheme: CaseIterable {
    static var allCases: [AnimationTheme] {
        return [.subtle, .dynamic, .instant]
    }
}
# iAnders Chess App

A comprehensive, fully offline iOS chess application built with SwiftUI and integrated with a local Stockfish engine.

## Features

### 🎮 Chess Gameplay
- **Full Chess Rules**: Complete implementation of all chess rules including castling, en passant, pawn promotion, and special moves
- **Legal Move Validation**: Comprehensive move validation with check/checkmate detection
- **Game Modes**: 
  - Human vs Human (local multiplayer)
  - Human vs AI (with Stockfish integration)
- **Multiple Time Controls**: Bullet (1+0), Blitz (3+2), Rapid (10+0), Classical (30+0), and unlimited time

### 🤖 AI Integration
- **Local Stockfish Engine**: Fully integrated Stockfish chess engine running locally on device
- **6 Difficulty Levels**: From Beginner to Master with adjustable thinking time and depth
- **Position Evaluation**: Real-time position analysis and evaluation
- **Move Analysis**: Post-game analysis with best move suggestions

### 📚 Opening Database
- **ECO Code System**: Comprehensive opening database with ECO classification
- **Opening Detection**: Automatic detection and naming of chess openings during play
- **50+ Popular Openings**: Including Sicilian Defense, Queen's Gambit, King's Indian, Spanish Opening, and more
- **Opening Themes**: Analysis of opening characteristics and strategic themes

### 🎨 User Interface
- **Beautiful SwiftUI Design**: Modern, clean interface optimized for iOS
- **Multiple Board Themes**: Classic, Modern, Wood, and Marble themes
- **Piece Styles**: Traditional, Modern, and Minimalist piece sets
- **Responsive Layout**: Optimized for all iPhone screen sizes
- **Smooth Animations**: Fluid piece movement and UI transitions

### 📊 Game Analysis
- **Move History**: Complete game notation with algebraic notation
- **Position Evaluation**: Visual evaluation bar showing position assessment
- **Game Statistics**: Win/loss records, average game length, opening frequency
- **Move Quality Analysis**: Identification of blunders, inaccuracies, and excellent moves

### 💾 Storage & History
- **Local Game Database**: All games stored locally on device
- **PGN Export/Import**: Full PGN (Portable Game Notation) support
- **FEN Support**: Position import/export using FEN notation
- **Game Replay**: Step through any saved game move by move
- **Search & Filter**: Find games by player, opening, result, or date

### ⚙️ Additional Features
- **Sound Effects**: Audio feedback for moves, captures, and game events
- **Coordinate Display**: Optional board coordinates for learning
- **Auto-promotion**: Option to automatically promote pawns to queens
- **Game Pause/Resume**: Pause and resume games at any time
- **Backup/Restore**: Export and import game databases

## Technical Architecture

### Core Components

#### ChessEngine.swift
- Complete chess rule implementation
- Move validation and generation
- Game state management
- FEN parsing and generation
- Check/checkmate detection

#### GameManager.swift
- Game flow coordination
- Timer management
- AI integration
- User interface state management
- Sound and visual effects

#### StockfishEngine.swift
- Swift wrapper for Stockfish C++ engine
- Position evaluation
- Best move calculation
- Difficulty adjustment
- Threading for background analysis

#### ChessBoardView.swift
- SwiftUI chess board implementation
- Interactive piece movement
- Visual highlights and indicators
- Responsive design
- Animation system

#### OpeningDatabase.swift
- ECO code classification
- Opening detection algorithm
- Database search and filtering
- Opening recommendations
- Theme analysis

#### GameStorage.swift
- Local persistence using UserDefaults
- PGN export/import functionality
- Game statistics calculation
- Search and filtering
- Backup/restore capabilities

### Project Structure
```
iAndersChessApp/
├── iAndersChessApp/
│   ├── Models/
│   │   ├── ChessEngine.swift
│   │   └── GameManager.swift
│   ├── Views/
│   │   └── ChessBoardView.swift
│   ├── Engines/
│   │   ├── StockfishEngine.swift
│   │   └── stockfish.cpp
│   ├── Storage/
│   │   ├── OpeningDatabase.swift
│   │   └── GameStorage.swift
│   ├── Resources/
│   │   └── opening_book.json
│   ├── Assets.xcassets
│   ├── iAndersChessAppApp.swift
│   ├── ContentView.swift
│   └── iAndersChessApp-Bridging-Header.h
└── README.md
```

## Requirements

- **iOS 15.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **iPhone/iPad compatible**

## Installation & Setup

1. **Clone the Repository**
   ```bash
   git clone [repository-url]
   cd iAndersChessApp
   ```

2. **Open in Xcode**
   ```bash
   open iAndersChessApp.xcodeproj
   ```

3. **Build Configuration**
   - Ensure iOS Deployment Target is set to 15.0+
   - Enable C++ compilation for Stockfish integration
   - Configure code signing for your development team

4. **Run the App**
   - Select your target device or simulator
   - Build and run (⌘+R)

## Usage

### Starting a New Game
1. Launch the app and tap "Play vs Computer" or "Play vs Human"
2. Select your preferred time control (or unlimited)
3. For AI games, choose difficulty level (Beginner to Master)
4. Tap "Start Game" to begin

### Playing Chess
- Tap a piece to select it (legal moves will be highlighted)
- Tap the destination square to move
- The app enforces all chess rules automatically
- Timers will count down if time control is enabled

### Game Analysis
- View move history during or after games
- Opening names appear automatically as you play
- Access post-game analysis for move evaluation
- Export games in PGN format for external analysis

### Managing Games
- Access game history from the main menu
- Search games by player, opening, or result
- View detailed statistics and performance trends
- Export/import game databases for backup

## Customization

### Board Themes
Choose from multiple visual themes:
- **Classic**: Traditional green and cream colors
- **Modern**: Sleek gray and white design
- **Wood**: Warm wooden board appearance
- **Marble**: Elegant marble texture

### AI Difficulty Levels
- **Beginner (Depth 1)**: Perfect for learning, 0.5s thinking time
- **Easy (Depth 3)**: Casual play, 1.0s thinking time
- **Medium (Depth 5)**: Balanced challenge, 2.0s thinking time
- **Hard (Depth 8)**: Strong opponent, 3.0s thinking time
- **Expert (Depth 12)**: Very challenging, 5.0s thinking time
- **Master (Depth 16)**: Maximum difficulty, 8.0s thinking time

## Contributing

This project is designed to be modular and extensible. Key areas for contribution:

1. **Enhanced AI**: Integration with full Stockfish source code
2. **Additional Themes**: New board and piece designs
3. **Analysis Features**: Advanced position analysis tools
4. **Opening Database**: Expanded opening coverage
5. **Performance**: Optimization for older devices

## Technical Notes

### Stockfish Integration
The current implementation includes a simplified Stockfish wrapper. For production use, integrate the full Stockfish source code:

1. Download Stockfish source from official repository
2. Compile as static library for iOS
3. Implement UCI protocol communication
4. Add proper threading for engine calculations

### Performance Considerations
- Move generation is optimized for mobile devices
- Game storage uses efficient JSON encoding
- UI updates are batched for smooth performance
- Memory usage is minimized through lazy loading

### Offline Operation
The app is designed to work completely offline:
- No network requests required
- All data stored locally
- Stockfish engine runs on-device
- Opening database embedded in app bundle

## License

This project is created for educational and demonstration purposes. Stockfish is licensed under GPL v3. Please ensure compliance with all applicable licenses when using this code.

## Acknowledgments

- **Stockfish Team**: For the incredible open-source chess engine
- **Chess Programming Community**: For algorithms and techniques
- **Apple**: For SwiftUI and iOS development tools
- **ECO Classification**: Based on Encyclopedia of Chess Openings

## Support

For issues, questions, or contributions, please refer to the project documentation or create an issue in the repository.

---

**iAnders Chess App** - Master the Royal Game 🏰♛
import SwiftUI

struct AnalysisView: View {
    @ObservedObject var analysisEngine: AnalysisEngine
    @ObservedObject var gameManager: GameManager
    @State private var selectedMoveIndex: Int = 0
    @State private var showingAnalysisReport = false
    @State private var showingPositionAnalysis = false
    @State private var analysisDepth: Int = 15
    @State private var showingSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top toolbar
                analysisToolbar
                
                if geometry.size.width > geometry.size.height {
                    // Landscape layout
                    HStack(spacing: 0) {
                        // Chess board
                        boardSection
                            .frame(width: geometry.size.height * 0.8)
                        
                        // Analysis panel
                        analysisPanel
                    }
                } else {
                    // Portrait layout
                    VStack(spacing: 0) {
                        // Chess board
                        boardSection
                            .frame(height: geometry.size.width)
                        
                        // Analysis panel
                        analysisPanel
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAnalysisReport) {
            AnalysisReportView(analysis: analysisEngine.gameAnalysis)
        }
        .sheet(isPresented: $showingPositionAnalysis) {
            PositionAnalysisView(
                analysis: analysisEngine.currentAnalysis,
                fen: gameManager.chessEngine.getFEN()
            )
        }
        .sheet(isPresented: $showingSettings) {
            AnalysisSettingsView(depth: $analysisDepth)
        }
    }
    
    private var analysisToolbar: some View {
        HStack {
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text("Chess Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: analyzeCurrentPosition) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                
                Button(action: analyzeFullGame) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                
                Button(action: { showingAnalysisReport = true }) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var boardSection: some View {
        VStack {
            ChessBoardView(gameManager: gameManager)
            
            // Move navigation
            moveNavigationControls
        }
    }
    
    private var moveNavigationControls: some View {
        HStack {
            Button(action: goToFirstMove) {
                Image(systemName: "backward.end.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .disabled(selectedMoveIndex == 0)
            
            Button(action: goToPreviousMove) {
                Image(systemName: "backward.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .disabled(selectedMoveIndex == 0)
            
            Spacer()
            
            Text("Move \(selectedMoveIndex + 1) / \(gameManager.chessEngine.moveHistory.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: goToNextMove) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .disabled(selectedMoveIndex >= gameManager.chessEngine.moveHistory.count - 1)
            
            Button(action: goToLastMove) {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .disabled(selectedMoveIndex >= gameManager.chessEngine.moveHistory.count - 1)
        }
        .padding()
    }
    
    private var analysisPanel: some View {
        VStack(spacing: 0) {
            // Evaluation bar
            evaluationBar
            
            // Analysis content
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Current position analysis
                    if let analysis = analysisEngine.currentAnalysis {
                        PositionAnalysisCard(analysis: analysis)
                    }
                    
                    // Move list with analysis
                    moveAnalysisList
                    
                    // Best moves section
                    bestMovesSection
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var evaluationBar: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Position Evaluation")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if analysisEngine.isAnalyzing {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Analyzing...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(evaluationText)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(evaluationColor)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.black.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(evaluationColor)
                        .frame(width: evaluationBarWidth(geometry.size.width), height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.3), value: currentEvaluation)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var moveAnalysisList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Move Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(Array(analysisEngine.gameAnalysis.enumerated()), id: \.offset) { index, moveAnalysis in
                MoveAnalysisRow(
                    moveAnalysis: moveAnalysis,
                    moveNumber: index + 1,
                    isSelected: index == selectedMoveIndex
                ) {
                    selectedMoveIndex = index
                    navigateToMove(index)
                }
            }
        }
    }
    
    private var bestMovesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Best Moves")
                .font(.headline)
                .fontWeight(.bold)
            
            if let analysis = analysisEngine.currentAnalysis {
                ForEach(Array(analysis.bestMoves.enumerated()), id: \.offset) { index, move in
                    HStack {
                        Text("\(index + 1).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(move)
                            .font(.body)
                            .fontFamily(.monospaced)
                        
                        Spacer()
                        
                        if index == 0 {
                            Text("Best")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                    .background(index == 0 ? Color.green.opacity(0.1) : Color.clear)
                    .cornerRadius(6)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var currentEvaluation: Double {
        return analysisEngine.currentAnalysis?.evaluation ?? 0.0
    }
    
    private var evaluationText: String {
        let eval = currentEvaluation
        if abs(eval) > 5.0 {
            let mateIn = Int(10.0 - abs(eval))
            return eval > 0 ? "M\(mateIn)" : "-M\(mateIn)"
        } else {
            let centipawns = Int(eval * 100)
            return centipawns >= 0 ? "+\(centipawns)" : "\(centipawns)"
        }
    }
    
    private var evaluationColor: Color {
        let eval = currentEvaluation
        if eval > 1.0 { return .green }
        else if eval > 0.5 { return .green.opacity(0.7) }
        else if eval < -1.0 { return .red }
        else if eval < -0.5 { return .red.opacity(0.7) }
        else { return .gray }
    }
    
    private func evaluationBarWidth(_ totalWidth: CGFloat) -> CGFloat {
        let eval = max(-5.0, min(5.0, currentEvaluation))
        let normalizedEval = (eval + 5.0) / 10.0
        return totalWidth * normalizedEval
    }
    
    // MARK: - Actions
    private func analyzeCurrentPosition() {
        Task {
            let fen = gameManager.chessEngine.getFEN()
            let analysis = await analysisEngine.analyzePosition(fen, depth: analysisDepth)
            
            await MainActor.run {
                analysisEngine.currentAnalysis = analysis
                showingPositionAnalysis = true
            }
        }
    }
    
    private func analyzeFullGame() {
        Task {
            let moves = gameManager.chessEngine.moveHistory
            await analysisEngine.analyzeGame(moves)
        }
    }
    
    private func navigateToMove(_ moveIndex: Int) {
        // Navigate to specific move in the game
        // This would require implementing game navigation in GameManager
    }
    
    private func goToFirstMove() {
        selectedMoveIndex = 0
        navigateToMove(0)
    }
    
    private func goToPreviousMove() {
        if selectedMoveIndex > 0 {
            selectedMoveIndex -= 1
            navigateToMove(selectedMoveIndex)
        }
    }
    
    private func goToNextMove() {
        if selectedMoveIndex < gameManager.chessEngine.moveHistory.count - 1 {
            selectedMoveIndex += 1
            navigateToMove(selectedMoveIndex)
        }
    }
    
    private func goToLastMove() {
        selectedMoveIndex = gameManager.chessEngine.moveHistory.count - 1
        navigateToMove(selectedMoveIndex)
    }
}

// MARK: - Supporting Views
struct MoveAnalysisRow: View {
    let moveAnalysis: MoveAnalysis
    let moveNumber: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            // Move number
            Text("\(moveNumber).")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)
            
            // Move notation
            Text(moveAnalysis.move.moveNotation)
                .font(.body)
                .fontFamily(.monospaced)
                .fontWeight(isSelected ? .bold : .regular)
            
            // Move quality indicator
            Text(moveAnalysis.quality.rawValue)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(moveAnalysis.quality.color)
            
            Spacer()
            
            // Evaluation
            Text(String(format: "%.2f", moveAnalysis.evaluation))
                .font(.caption)
                .fontFamily(.monospaced)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
}

struct PositionAnalysisCard: View {
    let analysis: PositionAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Position Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            // Position themes
            if !analysis.positionThemes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Themes")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 6) {
                        ForEach(analysis.positionThemes, id: \.rawValue) { theme in
                            Text(theme.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(theme.color.opacity(0.2))
                                .foregroundColor(theme.color)
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Tactical motifs
            if !analysis.tacticalMotifs.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tactical Motifs")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 6) {
                        ForEach(analysis.tacticalMotifs, id: \.rawValue) { motif in
                            HStack(spacing: 4) {
                                Image(systemName: motif.icon)
                                    .font(.caption2)
                                Text(motif.rawValue)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Position characteristics
            HStack {
                VStack(alignment: .leading) {
                    Text("Position Type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if analysis.isWinning {
                        Text("Winning")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else if analysis.isDrawish {
                        Text("Drawish")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    } else {
                        Text("Balanced")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Complexity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(analysis.isTactical ? "Tactical" : "Positional")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(analysis.isTactical ? .red : .blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct AnalysisReportView: View {
    let analysis: [MoveAnalysis]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary statistics
                    analysisStatistics
                    
                    // Move-by-move breakdown
                    moveBreakdown
                }
                .padding()
            }
            .navigationTitle("Analysis Report")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private var analysisStatistics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Summary")
                .font(.title2)
                .fontWeight(.bold)
            
            let stats = calculateStatistics()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(title: "Total Moves", value: "\(analysis.count)")
                StatCard(title: "Brilliant", value: "\(stats.brilliant)", color: .purple)
                StatCard(title: "Excellent", value: "\(stats.excellent)", color: .green)
                StatCard(title: "Good", value: "\(stats.good)", color: .blue)
                StatCard(title: "Inaccuracies", value: "\(stats.inaccuracies)", color: .yellow)
                StatCard(title: "Mistakes", value: "\(stats.mistakes)", color: .orange)
                StatCard(title: "Blunders", value: "\(stats.blunders)", color: .red)
                StatCard(title: "Accuracy", value: "\(Int(stats.accuracy))%", color: .green)
            }
        }
    }
    
    private var moveBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Move Analysis")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(Array(analysis.enumerated()), id: \.offset) { index, moveAnalysis in
                MoveAnalysisDetailRow(moveAnalysis: moveAnalysis, moveNumber: index + 1)
            }
        }
    }
    
    private func calculateStatistics() -> (brilliant: Int, excellent: Int, good: Int, inaccuracies: Int, mistakes: Int, blunders: Int, accuracy: Double) {
        let brilliant = analysis.filter { $0.quality == .brilliant }.count
        let excellent = analysis.filter { $0.quality == .excellent }.count
        let good = analysis.filter { $0.quality == .good }.count
        let inaccuracies = analysis.filter { $0.quality == .inaccuracy }.count
        let mistakes = analysis.filter { $0.quality == .mistake }.count
        let blunders = analysis.filter { $0.quality == .blunder }.count
        
        let goodMoves = brilliant + excellent + good
        let accuracy = analysis.count > 0 ? Double(goodMoves) / Double(analysis.count) * 100 : 0
        
        return (brilliant, excellent, good, inaccuracies, mistakes, blunders, accuracy)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    init(title: String, value: String, color: Color = .primary) {
        self.title = title
        self.value = value
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

struct MoveAnalysisDetailRow: View {
    let moveAnalysis: MoveAnalysis
    let moveNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(moveNumber). \(moveAnalysis.move.moveNotation)")
                    .font(.body)
                    .fontFamily(.monospaced)
                    .fontWeight(.semibold)
                
                Text(moveAnalysis.quality.rawValue)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(moveAnalysis.quality.color)
                
                Spacer()
                
                Text(String(format: "%.2f", moveAnalysis.evaluation))
                    .font(.caption)
                    .fontFamily(.monospaced)
                    .foregroundColor(.secondary)
            }
            
            if let comment = moveAnalysis.comment {
                Text(comment)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            if !moveAnalysis.principalVariation.isEmpty {
                Text("Best line: \(moveAnalysis.principalVariation.prefix(5).joined(separator: " "))")
                    .font(.caption)
                    .fontFamily(.monospaced)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(8)
    }
}

struct PositionAnalysisView: View {
    let analysis: PositionAnalysis?
    let fen: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let analysis = analysis {
                    VStack(alignment: .leading, spacing: 20) {
                        // Position evaluation
                        evaluationSection(analysis)
                        
                        // Best moves
                        bestMovesSection(analysis)
                        
                        // Position themes
                        themesSection(analysis)
                        
                        // Tactical analysis
                        tacticalSection(analysis)
                        
                        // Structural analysis
                        structuralSection(analysis)
                    }
                    .padding()
                } else {
                    Text("No analysis available")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Position Analysis")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private func evaluationSection(_ analysis: PositionAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Position Evaluation")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Evaluation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.2f", analysis.evaluation))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(analysis.evaluation > 0 ? .green : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Position Type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if analysis.isWinning {
                        Text("Winning")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else if analysis.isDrawish {
                        Text("Drawish")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    } else {
                        Text("Balanced")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func bestMovesSection(_ analysis: PositionAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Best Moves")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(Array(analysis.bestMoves.enumerated()), id: \.offset) { index, move in
                HStack {
                    Text("\(index + 1).")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(width: 25, alignment: .leading)
                    
                    Text(move)
                        .font(.body)
                        .fontFamily(.monospaced)
                    
                    Spacer()
                    
                    if index == 0 {
                        Text("Best")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(6)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func themesSection(_ analysis: PositionAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Position Themes")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(analysis.positionThemes, id: \.rawValue) { theme in
                    Text(theme.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.color.opacity(0.2))
                        .foregroundColor(theme.color)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func tacticalSection(_ analysis: PositionAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tactical Analysis")
                .font(.title2)
                .fontWeight(.bold)
            
            if analysis.tacticalMotifs.isEmpty {
                Text("No tactical motifs detected")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(analysis.tacticalMotifs, id: \.rawValue) { motif in
                        HStack(spacing: 6) {
                            Image(systemName: motif.icon)
                                .font(.caption)
                            Text(motif.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func structuralSection(_ analysis: PositionAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Structural Analysis")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                if analysis.pawnStructure.hasWeaknesses {
                    Label("Pawn weaknesses detected", systemImage: "exclamationmark.triangle")
                        .font(.body)
                        .foregroundColor(.orange)
                } else {
                    Label("Solid pawn structure", systemImage: "checkmark.circle")
                        .font(.body)
                        .foregroundColor(.green)
                }
                
                if analysis.kingSafety.isUnderAttack {
                    Label("King under attack", systemImage: "exclamationmark.triangle.fill")
                        .font(.body)
                        .foregroundColor(.red)
                } else {
                    Label("King is safe", systemImage: "shield")
                        .font(.body)
                        .foregroundColor(.green)
                }
                
                Label("Piece activity: \(String(format: "%.1f", analysis.pieceActivity.overallActivity))", systemImage: "arrow.up.right")
                    .font(.body)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AnalysisSettingsView: View {
    @Binding var depth: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Analysis Settings") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Analysis Depth: \(depth)")
                            .font(.body)
                        
                        Slider(value: Binding(
                            get: { Double(depth) },
                            set: { depth = Int($0) }
                        ), in: 5...25, step: 1)
                        
                        Text("Higher depth provides more accurate analysis but takes longer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Analysis Settings")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

#Preview {
    AnalysisView(
        analysisEngine: AnalysisEngine(),
        gameManager: GameManager()
    )
}
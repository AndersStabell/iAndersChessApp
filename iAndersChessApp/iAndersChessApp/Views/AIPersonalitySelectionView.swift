import SwiftUI

struct AIPersonalitySelectionView: View {
    @Binding var selectedPersonality: AIPersonality?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedDifficultyRange: ClosedRange<Int> = 1...20
    @State private var showingPersonalityDetail: AIPersonality?
    
    private var filteredPersonalities: [AIPersonality] {
        let personalities = AIPersonality.personalities
        
        let difficultyFiltered = personalities.filter { selectedDifficultyRange.contains($0.skillLevel) }
        
        if searchText.isEmpty {
            return difficultyFiltered
        } else {
            return difficultyFiltered.filter { personality in
                personality.name.localizedCaseInsensitiveContains(searchText) ||
                personality.type.rawValue.localizedCaseInsensitiveContains(searchText) ||
                personality.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filters
                searchAndFiltersSection
                
                // Personality grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredPersonalities) { personality in
                            PersonalityCard(
                                personality: personality,
                                isSelected: selectedPersonality?.id == personality.id
                            ) {
                                selectedPersonality = personality
                            } onInfo: {
                                showingPersonalityDetail = personality
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Choose Your Opponent")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Random") { selectRandomPersonality() }
            )
        }
        .sheet(item: $showingPersonalityDetail) { personality in
            PersonalityDetailView(personality: personality)
        }
    }
    
    private var searchAndFiltersSection: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search personalities...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Difficulty range filter
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Skill Level: \(selectedDifficultyRange.lowerBound) - \(selectedDifficultyRange.upperBound)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button("Reset") {
                        selectedDifficultyRange = 1...20
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                RangeSlider(
                    range: $selectedDifficultyRange,
                    bounds: 1...20,
                    step: 1
                )
            }
            
            // Quick filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickFilterButton(title: "Beginner", range: 1...8) {
                        selectedDifficultyRange = 1...8
                    }
                    QuickFilterButton(title: "Intermediate", range: 9...15) {
                        selectedDifficultyRange = 9...15
                    }
                    QuickFilterButton(title: "Advanced", range: 16...20) {
                        selectedDifficultyRange = 16...20
                    }
                    QuickFilterButton(title: "Aggressive", range: 1...20) {
                        searchText = "aggressive"
                    }
                    QuickFilterButton(title: "Tactical", range: 1...20) {
                        searchText = "tactical"
                    }
                    QuickFilterButton(title: "Positional", range: 1...20) {
                        searchText = "positional"
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private func selectRandomPersonality() {
        let filtered = filteredPersonalities
        if !filtered.isEmpty {
            selectedPersonality = filtered.randomElement()
        }
    }
}

struct PersonalityCard: View {
    let personality: AIPersonality
    let isSelected: Bool
    let onSelect: () -> Void
    let onInfo: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with icon and difficulty
            HStack {
                Image(systemName: personality.type.icon)
                    .font(.title2)
                    .foregroundColor(personality.type.color)
                    .frame(width: 30, height: 30)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Level \(personality.skillLevel)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    DifficultyIndicator(level: personality.skillLevel)
                }
            }
            
            // Name and type
            VStack(spacing: 4) {
                Text(personality.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(personality.type.rawValue)
                    .font(.caption)
                    .foregroundColor(personality.type.color)
                    .fontWeight(.medium)
            }
            
            // Motto
            Text(personality.motto)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Playing style indicators
            PlayingStyleIndicators(personality: personality)
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button(action: onInfo) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: onSelect) {
                    Text(isSelected ? "Selected" : "Choose")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? personality.type.color : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct PlayingStyleIndicators: View {
    let personality: AIPersonality
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                StyleBar(
                    title: "Aggression",
                    value: personality.playingStyle.aggressionLevel,
                    color: .red
                )
                
                StyleBar(
                    title: "Risk",
                    value: personality.playingStyle.riskTolerance,
                    color: .orange
                )
            }
            
            HStack {
                StyleBar(
                    title: "Tactical",
                    value: personality.playingStyle.tacticalTendency,
                    color: .purple
                )
                
                StyleBar(
                    title: "Speed",
                    value: 1.0 - personality.playingStyle.timeUsage,
                    color: .cyan
                )
            }
        }
    }
}

struct StyleBar: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * value, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
    }
}

struct DifficultyIndicator: View {
    let level: Int
    
    private var stars: Int {
        switch level {
        case 1...4: return 1
        case 5...8: return 2
        case 9...12: return 3
        case 13...16: return 4
        default: return 5
        }
    }
    
    private var color: Color {
        switch stars {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4: return .red
        default: return .purple
        }
    }
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= stars ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundColor(index <= stars ? color : Color.gray.opacity(0.3))
            }
        }
    }
}

struct QuickFilterButton: View {
    let title: String
    let range: ClosedRange<Int>?
    let action: () -> Void
    
    init(title: String, range: ClosedRange<Int>? = nil, action: @escaping () -> Void) {
        self.title = title
        self.range = range
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RangeSlider: View {
    @Binding var range: ClosedRange<Int>
    let bounds: ClosedRange<Int>
    let step: Int
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let lowerPosition = CGFloat(range.lowerBound - bounds.lowerBound) / CGFloat(bounds.upperBound - bounds.lowerBound) * width
            let upperPosition = CGFloat(range.upperBound - bounds.lowerBound) / CGFloat(bounds.upperBound - bounds.lowerBound) * width
            
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Active range
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: upperPosition - lowerPosition, height: 4)
                    .offset(x: lowerPosition)
                    .cornerRadius(2)
                
                // Lower thumb
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .offset(x: lowerPosition - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = bounds.lowerBound + Int((value.location.x / width) * CGFloat(bounds.upperBound - bounds.lowerBound))
                                let clampedValue = max(bounds.lowerBound, min(range.upperBound - step, newValue))
                                range = clampedValue...range.upperBound
                            }
                    )
                
                // Upper thumb
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .offset(x: upperPosition - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = bounds.lowerBound + Int((value.location.x / width) * CGFloat(bounds.upperBound - bounds.lowerBound))
                                let clampedValue = max(range.lowerBound + step, min(bounds.upperBound, newValue))
                                range = range.lowerBound...clampedValue
                            }
                    )
            }
        }
        .frame(height: 20)
    }
}

struct PersonalityDetailView: View {
    let personality: AIPersonality
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    personalityHeader
                    
                    // Description
                    descriptionSection
                    
                    // Playing style details
                    playingStyleSection
                    
                    // Evaluation bonuses
                    evaluationBonusesSection
                    
                    // Preferred openings
                    openingsSection
                    
                    // Personality quotes
                    quotesSection
                }
                .padding()
            }
            .navigationTitle(personality.name)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private var personalityHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: personality.type.icon)
                        .font(.title)
                        .foregroundColor(personality.type.color)
                    
                    VStack(alignment: .leading) {
                        Text(personality.type.rawValue)
                            .font(.headline)
                            .foregroundColor(personality.type.color)
                        
                        Text("Skill Level \(personality.skillLevel)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(personality.motto)
                    .font(.title3)
                    .italic()
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            DifficultyIndicator(level: personality.skillLevel)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(personality.type.color.opacity(0.1))
        )
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Playing Style")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(personality.type.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private var playingStyleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Style Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                DetailStyleRow(title: "Tactical Tendency", value: personality.playingStyle.tacticalTendency, color: .purple)
                DetailStyleRow(title: "Aggression Level", value: personality.playingStyle.aggressionLevel, color: .red)
                DetailStyleRow(title: "Risk Tolerance", value: personality.playingStyle.riskTolerance, color: .orange)
                DetailStyleRow(title: "Time Usage", value: personality.playingStyle.timeUsage, color: .blue)
                DetailStyleRow(title: "Piece Activity", value: personality.playingStyle.pieceActivityPreference, color: .green)
                DetailStyleRow(title: "King Safety Priority", value: personality.playingStyle.kingSafetyPriority, color: .cyan)
            }
        }
    }
    
    private var evaluationBonusesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Evaluation Preferences")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 6) {
                BonusRow(title: "Attacking Chances", value: personality.evaluationBonuses.attackingChancesBonus)
                BonusRow(title: "Tactical Motifs", value: personality.evaluationBonuses.tacticalMotifBonus)
                BonusRow(title: "Initiative", value: personality.evaluationBonuses.initiativeBonus)
                BonusRow(title: "King Safety", value: personality.evaluationBonuses.kingSafetyBonus)
                BonusRow(title: "Pawn Structure", value: personality.evaluationBonuses.pawnStructureBonus)
                BonusRow(title: "Endgame", value: personality.evaluationBonuses.endgameBonus)
            }
        }
    }
    
    private var openingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Opening Preferences")
                .font(.headline)
                .fontWeight(.bold)
            
            if !personality.preferredOpenings.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Prefers:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    ForEach(personality.preferredOpenings, id: \.self) { opening in
                        Text("• \(opening)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !personality.avoidedOpenings.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Avoids:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    ForEach(personality.avoidedOpenings, id: \.self) { opening in
                        Text("• \(opening)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var quotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personality Quotes")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                if !personality.moveComments.isEmpty {
                    Text("During Play:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(personality.moveComments.prefix(3), id: \.self) { comment in
                        Text(""\(comment)"")
                            .font(.caption)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
                
                if !personality.victoryMessages.isEmpty {
                    Text("When Winning:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    ForEach(personality.victoryMessages.prefix(2), id: \.self) { message in
                        Text(""\(message)"")
                            .font(.caption)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct DetailStyleRow: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * value, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(width: 100, height: 6)
            
            Text(String(format: "%.0f%%", value * 100))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 35, alignment: .trailing)
        }
    }
}

struct BonusRow: View {
    let title: String
    let value: Double
    
    private var intensity: String {
        switch value {
        case 0.0..<0.3: return "Low"
        case 0.3..<0.7: return "Medium"
        case 0.7..<1.2: return "High"
        default: return "Very High"
        }
    }
    
    private var color: Color {
        switch value {
        case 0.0..<0.3: return .gray
        case 0.3..<0.7: return .blue
        case 0.7..<1.2: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(intensity)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
                .frame(width: 70, alignment: .trailing)
        }
    }
}

#Preview {
    AIPersonalitySelectionView(selectedPersonality: .constant(nil))
}
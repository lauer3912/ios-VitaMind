import SwiftUI

// MARK: - 3D Card View
struct GameCardView: View {
    let card: HealthCard
    let isInteractive: Bool
    var onTap: (() -> Void)?
    
    @State private var isFlipped = false
    @State private var rotation: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var isPressed = false
    @State private var cardLift: CGFloat = 0
    @State private var shinePosition: CGFloat = -100
    
    var body: some View {
        ZStack {
            // Shadow layer (makes card appear lifted)
            RoundedRectangle(cornerRadius: VitaTheme.Radius.card)
                .fill(Color.black.opacity(0.4))
                .blur(radius: 12)
                .offset(y: 8 + cardLift)
                .scaleEffect(0.95)
            
            // Glow effect for rare cards
            if card.rarity.stars >= 3 {
                RoundedRectangle(cornerRadius: VitaTheme.Radius.card)
                    .fill(card.rarity.glowColor)
                    .blur(radius: 25)
                    .opacity(glowOpacity)
                    .offset(y: cardLift)
            }
            
            // Main Card with 3D transform
            ZStack {
                // Card face with perspective
                CardFaceView(card: card, isFlipped: isFlipped)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.3
                    )
                    .offset(y: cardLift)
                    
                // Shine overlay animation
                LinearGradient(
                    colors: [
                        .white.opacity(0),
                        .white.opacity(0.1),
                        .white.opacity(0),
                        .white.opacity(0.2),
                        .white.opacity(0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .mask(
                    RoundedRectangle(cornerRadius: VitaTheme.Radius.card)
                        .padding(20)
                )
                .offset(x: shinePosition, y: cardLift)
                .clipped()
            }
        }
        .frame(width: 160, height: 220)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .onAppear {
            if card.rarity.stars >= 4 {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowOpacity = 0.6
                }
            }
            // Start shine animation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shinePosition = 200
            }
        }
        .onTapGesture {
            if isInteractive {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    rotation += 180
                    isPressed = true
                    cardLift = -10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFlipped.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = false
                        cardLift = 0
                    }
                }
                onTap?()
            }
        }
    }
}

// MARK: - Card Face
struct CardFaceView: View {
    let card: HealthCard
    let isFlipped: Bool
    
    var body: some View {
        ZStack {
            // Back of card
            CardBackView()
                .opacity(isFlipped ? 0 : 1)
            
            // Front of card
            CardFrontView(card: card)
                .opacity(isFlipped ? 1 : 0)
        }
    }
}

// MARK: - Card Front
struct CardFrontView: View {
    let card: HealthCard
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                // Rarity stars
                HStack(spacing: 2) {
                    ForEach(0..<card.rarity.stars, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(card.rarity.color)
                    }
                }
                
                Spacer()
                
                // Card type icon
                Image(systemName: card.type.icon)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Card artwork area
            ZStack {
                // Gradient background based on card color
                RoundedRectangle(cornerRadius: VitaTheme.Radius.md)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: card.color).opacity(0.8), Color(hex: card.color).opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Main icon
                Image(systemName: card.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                
                // Shiny sparkle
                if card.isShiny {
                    SparkleOverlay()
                }
            }
            .frame(height: 100)
            .padding(.horizontal, 12)
            
            // Stats area
            VStack(spacing: 4) {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: card.color))
                            .frame(width: geo.size.width * card.progress)
                    }
                }
                .frame(height: 8)
                
                // Value display
                HStack {
                    Text("\(Int(card.currentValue))")
                        .font(VitaTheme.Fonts.statNumber)
                        .foregroundColor(.white)
                    
                    Text("/\(Int(card.maxValue)) \(card.unit)")
                        .font(VitaTheme.Fonts.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Bottom info
            VStack(spacing: 2) {
                Text(card.name)
                    .font(VitaTheme.Fonts.titleMedium)
                    .foregroundColor(.white)
                
                Text(card.description)
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: VitaTheme.Radius.card)
                .fill(VitaTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: VitaTheme.Radius.card)
                        .stroke(card.rarity.color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Card Back
struct CardBackView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: VitaTheme.Radius.card)
                .fill(VitaTheme.Colors.surface)
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            RoundedRectangle(cornerRadius: VitaTheme.Radius.card)
                .stroke(VitaTheme.Colors.primary, lineWidth: 2)
            
            VStack(spacing: 16) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(VitaTheme.Colors.primary)
                
                Text("VitaMindGo")
                    .font(VitaTheme.Fonts.title)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Sparkle Overlay (for shiny cards)
struct SparkleOverlay: View {
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat.random(in: 8...16)))
                    .foregroundColor(.white)
                    .position(
                        x: CGFloat.random(in: 20...(geo.size.width - 20)),
                        y: CGFloat.random(in: 20...(geo.size.height - 20))
                    )
                    .opacity(animate ? 0.8 : 0)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.1),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

// MARK: - Habit Card View
struct HabitCardView: View {
    let habit: HabitCard
    var onComplete: () -> Void
    
    @State private var cardOffset: CGFloat = 0
    @State private var cardRotation: Double = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Icon and info
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: habit.color).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: habit.color))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(VitaTheme.Fonts.titleMedium)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: habit.streakIcon)
                            .font(.system(size: 12))
                            .foregroundColor(habit.currentStreak > 0 ? VitaTheme.Colors.warning : .gray)
                        
                        Text("\(habit.currentStreak) day streak")
                            .font(VitaTheme.Fonts.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            // Right: Complete button
            Button(action: {
                if !habit.isCompletedToday {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        cardOffset = -20
                        cardRotation = -5
                        scale = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            cardOffset = 0
                            cardRotation = 0
                            scale = 1
                        }
                    }
                    onComplete()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(habit.isCompletedToday ? VitaTheme.Colors.success : VitaTheme.Colors.primary)
                        .frame(width: 44, height: 44)
                    
                    if habit.isCompletedToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .disabled(habit.isCompletedToday)
            .scaleEffect(scale)
            .offset(x: cardOffset)
            .rotationEffect(.degrees(cardRotation))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                .fill(VitaTheme.Colors.surface)
        )
    }
}

// MARK: - Achievement Card View
struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: VitaTheme.Radius.md)
                    .fill(achievement.isUnlocked ? achievement.rarity.color : Color.gray.opacity(0.3))
                    .frame(width: 56, height: 56)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(VitaTheme.Fonts.titleMedium)
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(achievement.rarity.color)
                            .frame(width: geo.size.width * achievement.progressPercent)
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
            
            // XP Badge
            VStack(spacing: 2) {
                Text("+\(achievement.xpReward)")
                    .font(VitaTheme.Fonts.captionBold)
                    .foregroundColor(VitaTheme.Colors.accent)
                
                Text("XP")
                    .font(VitaTheme.Fonts.statLabel)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                .fill(VitaTheme.Colors.surface)
                .opacity(achievement.isUnlocked ? 1 : 0.6)
        )
    }
}

// MARK: - XP Progress Bar
struct XPProgressBar: View {
    let level: UserLevel
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Lv. \(level.level)")
                    .font(VitaTheme.Fonts.captionBold)
                    .foregroundColor(VitaTheme.Colors.accent)
                
                Text(level.title)
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("\(level.currentXP)/\(level.xpForNextLevel) XP")
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [VitaTheme.Colors.primary, VitaTheme.Colors.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animatedProgress)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                .fill(VitaTheme.Colors.surface)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = level.progress
            }
        }
    }
}
//
//  OnboardingQuestionsView.swift
//  orsa
//
//  Created by Rome on 6/5/26.
//

import SwiftUI

private struct OnboardingCompletedItem: Identifiable {
    let id = UUID()
    let questionKey: OnboardingQuestion
    let question: String
    let answer: String
}

private enum OnboardingQuestion: Int, Hashable {
    case name
    case setup
    case dose
}

private enum OnboardingQuestionCopy {
    static let name = "What's your name?"
    static let setup = "What's your main setup?"
    static let dose = "Nice, what's your usual dose?"
}

private enum OnboardingMotion {
    static let heroDuration: TimeInterval = 1.0
    static let step = Animation.smooth(duration: heroDuration)
    static let stepDuration: TimeInterval = heroDuration

    static let entranceDuration: TimeInterval = 0.9
    static let entrance = Animation.smooth(duration: entranceDuration)

    static let stepRevealDelay: TimeInterval = 0.3
    static let fieldEntranceDelay: TimeInterval = 0.32
    static let transitionSettleDuration: TimeInterval = 1.22
}

private enum OnboardingFrameAnchor: Hashable {
    case active(OnboardingQuestion)
    case activeInput(OnboardingQuestion)
    case archived(OnboardingQuestion)
    case archivedAnswer(OnboardingQuestion)
}

private struct OnboardingFramePreferenceKey: PreferenceKey {
    static var defaultValue: [OnboardingFrameAnchor: CGRect] = [:]

    static func reduce(
        value: inout [OnboardingFrameAnchor: CGRect],
        nextValue: () -> [OnboardingFrameAnchor: CGRect]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private struct PendingArchive: Equatable {
    let key: OnboardingQuestion
    let question: String
    let answer: String
}

private struct HeroFlight: Equatable {
    let pending: PendingArchive
    let startFrame: CGRect
    let endFrame: CGRect
    let inputStartFrame: CGRect
    let answerEndFrame: CGRect
}

private enum HeroPhase: Equatable {
    case idle
    case measuring(PendingArchive, startFrame: CGRect, inputStartFrame: CGRect)
    case flying(HeroFlight)
}

struct OnboardingQuestionsView: View {
    @Binding var userName: String
    @Binding var machineName: String
    @Binding var grinderName: String
    @Binding var defaultDose: String

    let onComplete: () -> Void
    let onSkip: () -> Void
    let onBackToIntro: () -> Void

    @State private var currentQuestion: OnboardingQuestion = .name
    @State private var completedItems: [OnboardingCompletedItem] = []
    @State private var pendingArchiveRow: PendingArchive?
    @State private var heroPhase: HeroPhase = .idle
    @State private var heroProgress: CGFloat = 0
    @State private var measuredFrames: [OnboardingFrameAnchor: CGRect] = [:]
    @State private var isTransitioning = false
    @State private var pendingHeroCompletion: (() -> Void)?
    @FocusState private var focusedField: Field?

    private enum Field {
        case name, machine, grinder, dose
    }

    private var isCurrentStepValid: Bool {
        switch currentQuestion {
        case .name:
            return !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .setup:
            let machine = machineName.trimmingCharacters(in: .whitespacesAndNewlines)
            let grinder = grinderName.trimmingCharacters(in: .whitespacesAndNewlines)
            return !machine.isEmpty && !grinder.isEmpty
        case .dose:
            return !defaultDose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private var primaryIcon: String {
        currentQuestion == .dose ? "arrow.right" : "checkmark"
    }

    private var hasName: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            mainContent
            heroOverlay
        }
        .coordinateSpace(name: "onboarding")
        .background(Color.appBackground)
        .keyboardDoneToolbar()
        .onPreferenceChange(OnboardingFramePreferenceKey.self) { frames in
            measuredFrames = frames
            beginHeroFlightIfReady(using: frames)
        }
        .onTapGesture {
            KeyboardDismissal.dismiss()
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(completedItems) { item in
                    archivedQuestionRow(
                        question: item.question,
                        answer: item.answer,
                        key: item.questionKey,
                        visible: !isHeroAnimating(item.questionKey)
                    )
                }

                if let pendingArchiveRow {
                    archivedQuestionRow(
                        question: pendingArchiveRow.question,
                        answer: pendingArchiveRow.answer,
                        key: pendingArchiveRow.key,
                        visible: false
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 60)

            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                activeQuestionHeadline

                if showsActiveInputs {
                    activeStepInputs
                        .onboardingGrowIn(
                            isPresented: showsActiveInputs,
                            delay: OnboardingMotion.fieldEntranceDelay
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)

            Spacer()

            OnboardingActionBar(
                primaryIcon: primaryIcon,
                isPrimaryEnabled: isCurrentStepValid && !isTransitioning,
                isSkipEnabled: hasName && !isTransitioning,
                showsSkip: currentQuestion != .name,
                isBackEnabled: !isTransitioning,
                onPrimary: handlePrimaryAction,
                onSkip: onSkip,
                onBack: goBack
            )
        }
    }

    @ViewBuilder
    private var heroOverlay: some View {
        if case .flying(let flight) = heroPhase {
            let progress = easeOut(heroProgress)
            let activeSize = activeQuestionFontSize(flight.pending.key)
            let endScale = archivedQuestionFontSize / activeSize
            let questionScale = lerp(1, endScale, progress)
            let questionOrigin = CGPoint(
                x: lerp(flight.startFrame.minX, flight.endFrame.minX, progress),
                y: lerp(flight.startFrame.minY, flight.endFrame.minY, progress)
            )

            let answerStart = answerStartPoint(in: flight.inputStartFrame)
            let answerOrigin = CGPoint(
                x: lerp(answerStart.x, flight.answerEndFrame.minX, progress),
                y: lerp(answerStart.y, flight.answerEndFrame.minY, progress)
            )
            let fieldFade = min(1, heroProgress * 1.35)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
                .frame(width: flight.inputStartFrame.width, height: flight.inputStartFrame.height)
                .opacity(Double(1 - fieldFade))
                .offset(x: flight.inputStartFrame.minX, y: flight.inputStartFrame.minY)

            Text(flight.pending.answer)
                .font(.oscineRegular(size: 17))
                .foregroundColor(.primary)
                .opacity(Double(lerp(0.15, 1, progress)))
                .offset(x: answerOrigin.x, y: answerOrigin.y)

            questionText(
                flight.pending.question,
                key: flight.pending.key,
                style: .active
            )
            .foregroundColor(heroForegroundColor(for: flight.pending.key, progress: progress))
            .scaleEffect(questionScale, anchor: .topLeading)
            .offset(x: questionOrigin.x, y: questionOrigin.y)
            .allowsHitTesting(false)
        }
    }

    private var showsActiveInputs: Bool {
        if heroPhase != .idle {
            return false
        }

        switch currentQuestion {
        case .name:
            return !isArchived(.name)
        case .setup:
            return !isArchived(.setup)
        case .dose:
            return true
        }
    }

    @ViewBuilder
    private var activeQuestionHeadline: some View {
        switch currentQuestion {
        case .name:
            if !isArchived(.name) {
                questionText(
                    OnboardingQuestionCopy.name,
                    key: .name,
                    style: .active
                )
                .opacity(isHeroAnimating(.name) ? 0 : 1)
                .onboardingGrowIn(isPresented: isStepReady(.name))
                .onboardingFrameAnchor(.active(.name))
            }

        case .setup:
            if !isArchived(.setup) {
                questionText(
                    OnboardingQuestionCopy.setup,
                    key: .setup,
                    style: .active
                )
                .opacity(isHeroAnimating(.setup) ? 0 : 1)
                .onboardingGrowIn(isPresented: isStepReady(.setup))
                .onboardingFrameAnchor(.active(.setup))
            }

        case .dose:
            if !isArchived(.dose) {
                questionText(
                    OnboardingQuestionCopy.dose,
                    key: .dose,
                    style: .active
                )
                .onboardingGrowIn(isPresented: isStepReady(.dose))
                .onboardingFrameAnchor(.active(.dose))
            }
        }
    }

    @ViewBuilder
    private var activeStepInputs: some View {
        Group {
            switch currentQuestion {
            case .name:
                TextField("Enter your name", text: $userName)
                    .font(.oscineRegular(size: 17))
                    .foregroundColor(.primary)
                    .appInputFieldStyle()
                    .focused($focusedField, equals: .name)
                    .submitLabel(.done)

            case .setup:
                VStack(spacing: 16) {
                    TextField("Machine", text: $machineName)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary)
                        .appInputFieldStyle()
                        .focused($focusedField, equals: .machine)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .grinder
                        }

                    TextField("Grinder", text: $grinderName)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary)
                        .appInputFieldStyle()
                        .focused($focusedField, equals: .grinder)
                        .submitLabel(.done)
                }

            case .dose:
                HStack(spacing: 12) {
                    TextField("18.0", text: $defaultDose)
                        .keyboardType(.decimalPad)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary)
                        .appInputFieldStyle()
                        .focused($focusedField, equals: .dose)

                    Text("g")
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary.opacity(0.7))
                }
            }
        }
        .onboardingFrameAnchor(.activeInput(currentQuestion))
    }

    private enum QuestionTextStyle {
        case active
        case archived
    }

    @ViewBuilder
    private func archivedQuestionRow(
        question: String,
        answer: String,
        key: OnboardingQuestion,
        visible: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            questionText(question, key: key, style: .archived)
                .onboardingFrameAnchor(.archived(key))

            Text(answer)
                .font(.oscineRegular(size: 17))
                .foregroundColor(.primary)
                .onboardingFrameAnchor(.archivedAnswer(key))
                .opacity(visible ? 1 : 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(visible ? 1 : 0)
    }

    private func questionText(
        _ text: String,
        key: OnboardingQuestion,
        style: QuestionTextStyle
    ) -> some View {
        Text(text)
            .font(.oscineRegular(size: style == .active ? activeQuestionFontSize(key) : archivedQuestionFontSize))
            .foregroundColor(style == .active ? activeQuestionColor(key) : .secondaryText)
            .lineLimit(style == .active ? 1 : nil)
            .minimumScaleFactor(style == .active ? 0.8 : 1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func activeQuestionFontSize(_ key: OnboardingQuestion) -> CGFloat {
        switch key {
        case .name: 34
        case .setup: 28
        case .dose: 26
        }
    }

    private func activeQuestionColor(_ key: OnboardingQuestion) -> Color {
        .primary
    }

    private var archivedQuestionFontSize: CGFloat { 15 }

    private func isArchived(_ key: OnboardingQuestion) -> Bool {
        completedItems.contains { $0.questionKey == key }
    }

    private func isHeroAnimating(_ key: OnboardingQuestion) -> Bool {
        switch heroPhase {
        case .idle:
            false
        case .measuring(let pending, _, _):
            pending.key == key
        case .flying(let flight):
            flight.pending.key == key
        }
    }

    private func isStepReady(_ step: OnboardingQuestion) -> Bool {
        guard currentQuestion == step, heroPhase == .idle, !isHeroAnimating(step) else {
            return false
        }

        switch step {
        case .name:
            return !isArchived(.name)
        case .setup:
            return !isArchived(.setup)
        case .dose:
            return !isArchived(.dose)
        }
    }

    private func handlePrimaryAction() {
        guard isCurrentStepValid, !isTransitioning else { return }

        if currentQuestion == .dose {
            onComplete()
            return
        }

        confirmAndAdvance()
    }

    private func confirmAndAdvance() {
        focusedField = nil

        let answer: String
        switch currentQuestion {
        case .name:
            answer = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        case .setup:
            let machine = machineName.trimmingCharacters(in: .whitespacesAndNewlines)
            let grinder = grinderName.trimmingCharacters(in: .whitespacesAndNewlines)
            answer = "\(machine) · \(grinder)"
        case .dose:
            return
        }

        let question: String = switch currentQuestion {
        case .name: OnboardingQuestionCopy.name
        case .setup: OnboardingQuestionCopy.setup
        case .dose: OnboardingQuestionCopy.dose
        }

        let advancingFrom = currentQuestion
        isTransitioning = true

        archiveQuestionWithHero(
            key: advancingFrom,
            question: question,
            answer: answer
        ) {
            switch advancingFrom {
            case .name:
                revealNextStep(.setup)

            case .setup:
                revealNextStep(.dose)

            case .dose:
                break
            }
        }
    }

    private func revealNextStep(_ step: OnboardingQuestion) {
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingMotion.stepRevealDelay) {
            withAnimation(OnboardingMotion.entrance) {
                currentQuestion = step
            }
            finishTransition()
        }
    }

    private func finishTransition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingMotion.transitionSettleDuration) {
            isTransitioning = false
        }
    }

    private func archiveQuestionWithHero(
        key: OnboardingQuestion,
        question: String,
        answer: String,
        completion: @escaping () -> Void
    ) {
        let pending = PendingArchive(key: key, question: question, answer: answer)

        guard
            let startFrame = measuredFrames[.active(key)],
            let inputStartFrame = measuredFrames[.activeInput(key)]
        else {
            completedItems.append(
                OnboardingCompletedItem(
                    questionKey: key,
                    question: question,
                    answer: answer
                )
            )
            completion()
            return
        }

        pendingArchiveRow = pending
        heroPhase = .measuring(pending, startFrame: startFrame, inputStartFrame: inputStartFrame)
        heroProgress = 0
        pendingHeroCompletion = completion
    }

    private func beginHeroFlightIfReady(using frames: [OnboardingFrameAnchor: CGRect]) {
        guard case .measuring(let pending, let startFrame, let inputStartFrame) = heroPhase else { return }
        guard
            let endFrame = frames[.archived(pending.key)],
            let answerEndFrame = frames[.archivedAnswer(pending.key)]
        else { return }

        heroPhase = .flying(
            HeroFlight(
                pending: pending,
                startFrame: startFrame,
                endFrame: endFrame,
                inputStartFrame: inputStartFrame,
                answerEndFrame: answerEndFrame
            )
        )

        withAnimation(OnboardingMotion.step) {
            heroProgress = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingMotion.stepDuration) {
            finishHeroFlight()
        }
    }

    private func finishHeroFlight() {
        guard case .flying(let flight) = heroPhase else { return }

        completedItems.append(
            OnboardingCompletedItem(
                questionKey: flight.pending.key,
                question: flight.pending.question,
                answer: flight.pending.answer
            )
        )

        pendingArchiveRow = nil
        heroPhase = .idle
        heroProgress = 0

        let completion = pendingHeroCompletion
        pendingHeroCompletion = nil
        completion?()
    }

    private func goBack() {
        guard !isTransitioning, heroPhase == .idle else { return }

        if currentQuestion == .name {
            focusedField = nil
            onBackToIntro()
            return
        }

        isTransitioning = true
        focusedField = nil

        withAnimation(OnboardingMotion.step) {
            if !completedItems.isEmpty {
                completedItems.removeLast()
            }

            switch currentQuestion {
            case .setup:
                currentQuestion = .name
            case .dose:
                currentQuestion = .setup
            case .name:
                break
            }
        }

        finishTransition()
    }

    private func answerStartPoint(in inputFrame: CGRect) -> CGPoint {
        CGPoint(x: inputFrame.minX + 16, y: inputFrame.minY + 12)
    }

    private func lerp(_ start: CGFloat, _ end: CGFloat, _ progress: CGFloat) -> CGFloat {
        start + (end - start) * progress
    }

    private func easeOut(_ progress: CGFloat) -> CGFloat {
        1 - pow(1 - progress, 2)
    }

    private func heroForegroundColor(for key: OnboardingQuestion, progress: CGFloat) -> Color {
        progress > 0.82 ? .secondaryText : activeQuestionColor(key)
    }
}

private struct OnboardingGrowInModifier: ViewModifier {
    let isPresented: Bool
    let delay: TimeInterval

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.94, anchor: .topLeading)
            .offset(y: isVisible ? 0 : 10)
            .allowsHitTesting(isVisible)
            .onChange(of: isPresented) { _, presented in
                updateVisibility(presented: presented)
            }
            .onAppear {
                updateVisibility(presented: isPresented)
            }
    }

    private func updateVisibility(presented: Bool) {
        if presented {
            withAnimation(OnboardingMotion.entrance.delay(delay)) {
                isVisible = true
            }
        } else {
            withAnimation(OnboardingMotion.step) {
                isVisible = false
            }
        }
    }
}

private extension View {
    func onboardingGrowIn(isPresented: Bool, delay: TimeInterval = 0) -> some View {
        modifier(OnboardingGrowInModifier(isPresented: isPresented, delay: delay))
    }

    func onboardingFrameAnchor(_ anchor: OnboardingFrameAnchor) -> some View {
        background {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: OnboardingFramePreferenceKey.self,
                    value: [anchor: geometry.frame(in: .named("onboarding"))]
                )
            }
        }
    }
}

#Preview {
    OnboardingQuestionsView(
        userName: .constant(""),
        machineName: .constant(""),
        grinderName: .constant(""),
        defaultDose: .constant("18.0"),
        onComplete: {},
        onSkip: {},
        onBackToIntro: {}
    )
}

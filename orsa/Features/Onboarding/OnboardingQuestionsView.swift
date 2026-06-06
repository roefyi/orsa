//
//  OnboardingQuestionsView.swift
//  orsa
//
//  Created by Rome on 6/5/26.
//

import SwiftUI

private struct OnboardingCompletedItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

private enum OnboardingQuestion: Int {
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
    static let step = Animation.smooth(duration: 0.6)
    static let focusDelay: TimeInterval = 0.45
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
    @State private var isTransitioning = false
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
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(completedItems) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.question)
                            .font(.oscineRegular(size: 15))
                            .foregroundColor(.secondaryText)
                        
                        Text(item.answer)
                            .font(.oscineRegular(size: 17))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        )
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 60)
            
            Spacer()
            
            Group {
                switch currentQuestion {
                case .name:
                    nameStep
                case .setup:
                    setupStep
                case .dose:
                    doseStep
                }
            }
            .padding(.horizontal, 32)
            .transition(
                .asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.98)),
                    removal: .opacity.combined(with: .offset(y: -12))
                )
            )
            .id(currentQuestion)
            
            Spacer()
            
            OnboardingActionBar(
                primaryIcon: primaryIcon,
                isPrimaryEnabled: isCurrentStepValid && !isTransitioning,
                isBackEnabled: !isTransitioning,
                onPrimary: handlePrimaryAction,
                onSkip: onSkip,
                onBack: goBack
            )
        }
        .background(Color.appBackground)
        .animation(OnboardingMotion.step, value: completedItems.count)
        .animation(OnboardingMotion.step, value: currentQuestion)
        .onTapGesture {
            KeyboardDismissal.dismiss()
        }
        .onAppear {
            focusedField = .name
        }
    }
    
    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(OnboardingQuestionCopy.name)
                .font(.oscineRegular(size: 34))
                .foregroundColor(.primary)
            
            TextField("Enter your name", text: $userName)
                .font(.oscineRegular(size: 17))
                .foregroundColor(.primary)
                .appInputFieldStyle()
                .focused($focusedField, equals: .name)
                .submitLabel(.done)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var setupStep: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("glad you're here \(userName)")
                .font(.oscineRegular(size: 34))
                .foregroundColor(.primary)
            
            Text(OnboardingQuestionCopy.setup)
                .font(.oscineRegular(size: 20))
                .foregroundColor(.secondaryText)
            
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var doseStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(OnboardingQuestionCopy.dose)
                .font(.oscineRegular(size: 34))
                .foregroundColor(.primary)
            
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
        .frame(maxWidth: .infinity, alignment: .leading)
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
        
        isTransitioning = true
        
        withAnimation(OnboardingMotion.step) {
            completedItems.append(
                OnboardingCompletedItem(question: question, answer: answer)
            )
            
            switch currentQuestion {
            case .name:
                currentQuestion = .setup
            case .setup:
                currentQuestion = .dose
            case .dose:
                break
            }
        }
        
        let nextFocus: Field? = switch currentQuestion {
        case .name: .name
        case .setup: .machine
        case .dose: .dose
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingMotion.focusDelay) {
            focusedField = nextFocus
            isTransitioning = false
        }
    }
    
    private func goBack() {
        guard !isTransitioning else { return }
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingMotion.focusDelay) {
            refocusCurrentField()
            isTransitioning = false
        }
    }
    
    private func refocusCurrentField() {
        focusedField = switch currentQuestion {
        case .name: .name
        case .setup: .machine
        case .dose: .dose
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

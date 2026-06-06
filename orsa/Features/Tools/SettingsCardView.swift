//
//  SettingsCardView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData
import UIKit
import StoreKit
import WebKit

/// Settings screen — pushed from Tools; hosts grouped settings cards plus a version footer.
struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SettingsCardView()

                Text("version 1.0")
                    .font(.oscineRegular(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SettingsCardView: View {
    @Query private var userProfiles: [UserProfile]

    @State private var showingProfile = false
    @State private var showingMeasurements = false
    @State private var showingAppearance = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false

    private var profileName: String {
        let trimmed = userProfiles.first?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "Add your name" : trimmed
    }

    var body: some View {
        VStack(spacing: 24) {
            // Profile — name (and other identity bits) live here so they can be
            // edited after onboarding instead of being a one-shot during setup.
            SettingsGroup("profile") {
                SettingsRowView(title: "name", value: profileName) { showingProfile = true }
            }

            // App preferences
            SettingsGroup("preferences") {
                SettingsRowView(title: "measurements") { showingMeasurements = true }
                SettingsDivider()
                SettingsRowView(title: "appearance") { showingAppearance = true }
            }

            // Feedback / community
            SettingsGroup("about") {
                SettingsRowView(title: "leave a review") { requestReview() }
                SettingsDivider()
                SettingsRowView(title: "report a bug") { openBugReport() }
                SettingsDivider()
                SettingsRowView(title: "meet the builder") { openBuilder() }
            }

            // Legal
            SettingsGroup("legal") {
                SettingsRowView(title: "privacy policy") { showingPrivacyPolicy = true }
                SettingsDivider()
                SettingsRowView(title: "terms of service") { showingTermsOfService = true }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingMeasurements) {
            MeasurementsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAppearance) {
            AppearanceView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            WebViewSheet(title: "Privacy Policy", url: "https://www.roe.fyi/orsa/privacy-policy.html")
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingTermsOfService) {
            WebViewSheet(title: "Terms of Service", url: "https://www.roe.fyi/orsa/terms-of-use.html")
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        if #available(iOS 18.0, *) {
            AppStore.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func openBuilder() {
        if let url = URL(string: "https://twitter.com/roefyi") {
            UIApplication.shared.open(url)
        }
    }

    private func openBugReport() {
        let email = "romansdenson@gmail.com"
        let subject = "Orsa Bug"
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "mailto:\(email)?subject=\(subjectEncoded)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Building blocks

/// A titled card grouping related settings rows.
struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.oscineCaption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
            )
        }
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .background(Color.secondary.opacity(0.2))
    }
}

struct SettingsPickerField: View {
    let title: String
    let options: [(label: String, value: String)]
    @Binding var selection: String

    private var selectedLabel: String {
        options.first(where: { $0.value == selection })?.label ?? selection
    }

    var body: some View {
        SettingsGroup(title) {
            Menu {
                ForEach(options, id: \.value) { option in
                    Button(option.label) {
                        HapticFeedback.light()
                        selection = option.value
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selectedLabel)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
        }
    }
}

struct SettingsRowView: View {
    let title: String
    var value: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.oscineHeadline)
                    .foregroundColor(.primary)
                Spacer()
                if let value {
                    Text(value)
                        .font(.oscineRegular(size: 15))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]

    @State private var name = ""
    @State private var defaultDose = ""

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    SettingsGroup("name") {
                        TextField("Enter your name", text: $name)
                            .font(.oscineRegular(size: 17))
                            .foregroundColor(.primary)
                            .tint(AppColors.inputTint)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                    }

                    SettingsGroup("default dose") {
                        HStack(spacing: 8) {
                            TextField("18.0", text: $defaultDose)
                                .font(.oscineRegular(size: 17))
                                .foregroundColor(.primary)
                                .keyboardType(.decimalPad)
                                .tint(AppColors.inputTint)
                            Text("g")
                                .font(.oscineRegular(size: 17))
                                .foregroundColor(.secondaryText)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .settingsSheetStyle()
            .keyboardDoneToolbar()
            .navigationTitle("profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.oscineHeadline)
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .font(.oscineHeadline)
                        .foregroundColor(.primary)
                        .disabled(!isValid)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let profile = userProfiles.first else { return }
        name = profile.name
        defaultDose = profile.defaultDose > 0 ? String(profile.defaultDose) : ""
    }

    private func save() {
        let profile: UserProfile
        if let existing = userProfiles.first {
            profile = existing
        } else {
            profile = UserProfile()
            modelContext.insert(profile)
        }
        profile.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let dose = Double(defaultDose), dose > 0 {
            profile.defaultDose = dose
        }
        modelContext.saveOrLog("edit profile")
        dismiss()
    }
}

// MARK: - Preferences sheets

struct MeasurementsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("yieldUnit") private var yieldUnit: String = "grams"
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "F"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    SettingsPickerField(
                        title: "yield unit",
                        options: [
                            (label: "Grams", value: "grams"),
                            (label: "Milliliters", value: "ml")
                        ],
                        selection: $yieldUnit
                    )

                    SettingsPickerField(
                        title: "temperature unit",
                        options: [
                            (label: "Fahrenheit (°F)", value: "F"),
                            (label: "Celsius (°C)", value: "C")
                        ],
                        selection: $temperatureUnit
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .settingsSheetStyle()
            .navigationTitle("measurements")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.oscineHeadline)
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

struct AppearanceView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    SettingsPickerField(
                        title: "theme",
                        options: [
                            (label: "Light", value: "light"),
                            (label: "Dark", value: "dark"),
                            (label: "System", value: "system")
                        ],
                        selection: $appearanceMode
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .settingsSheetStyle()
            .navigationTitle("appearance")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.oscineHeadline)
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

private extension View {
    func settingsSheetStyle() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
    }
}

private struct SettingsWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct WebViewSheet: View {
    let title: String
    let url: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let pageURL = URL(string: url) {
                    SettingsWebView(url: pageURL)
                } else {
                    Text("Unable to load page")
                        .font(.oscineBody)
                        .foregroundColor(.primary)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.oscineHeadline)
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    List {
        SettingsCardView()
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
    }
    .scrollContentBackground(.hidden)
    .background(Color.appBackground)
    .modelContainer(for: [UserProfile.self])
}

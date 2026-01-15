//
//  SettingsCardView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import StoreKit
import MessageUI

struct SettingsCardView: View {
    @State private var showingMeasurements = false
    @State private var showingAppearance = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    var body: some View {
        VStack(spacing: 0) {
            SettingsRowView(title: "measurements", action: {
                showingMeasurements = true
            })
            
            Divider()
                .background(Color.secondary.opacity(0.2))
            
            SettingsRowView(title: "appearance", action: {
                showingAppearance = true
            })
            
            Divider()
                .background(Color.secondary.opacity(0.2))
            
            SettingsRowView(title: "privacy policy", action: {
                showingPrivacyPolicy = true
            })
            
            Divider()
                .background(Color.secondary.opacity(0.2))
            
            SettingsRowView(title: "terms of service", action: {
                showingTermsOfService = true
            })
            
            Divider()
                .background(Color.secondary.opacity(0.2))
            
            SettingsRowView(title: "report a bug", action: {
                openBugReport()
            })
            
            Divider()
                .background(Color.secondary.opacity(0.2))
            
            SettingsRowView(title: "leave a review", action: {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    if #available(iOS 18.0, *) {
                        AppStore.requestReview(in: scene)
                    } else {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
            })
            
            Divider()
                .background(Color.secondary.opacity(0.2))
            
            SettingsRowView(title: "meet the builder", action: {
                if let url = URL(string: "https://twitter.com/roefyi") {
                    UIApplication.shared.open(url)
                }
            })
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
        )
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
            WebViewSheet(title: "Privacy Policy", url: "https://example.com/privacy")
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingTermsOfService) {
            WebViewSheet(title: "Terms of Service", url: "https://example.com/terms")
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func openBugReport() {
        let email = "romansdenson@gmail.com"
        let subject = "Orsa Bug"
        let body = ""
        
        // Create mailto URL
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(email)?subject=\(subjectEncoded)&body=\(bodyEncoded)") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRowView: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            HStack {
                Text(title)
                    .font(.oscineHeadline)
                    .foregroundColor(.primary)
                Spacer()
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

// Placeholder views for settings options
struct MeasurementsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("yieldUnit") private var yieldUnit: String = "grams"
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Yield Unit", selection: $yieldUnit) {
                        Text("Grams").tag("grams")
                        Text("Milliliters").tag("ml")
                    }
                } header: {
                    Text("yield unit")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
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
            Form {
                Section {
                    Picker("Appearance", selection: $appearanceMode) {
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                        Text("System").tag("system")
                    }
                } header: {
                    Text("appearance")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

struct WebViewSheet: View {
    let title: String
    let url: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(title) content coming soon")
                        .font(.oscineBody)
                        .foregroundColor(.primary)
                        .padding()
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
                    .foregroundStyle(.tint)
                }
            }
        }
    }
}

#Preview {
    List {
        SettingsCardView()
            .listRowBackground(AppColors.cardCream)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
    }
    .scrollContentBackground(.hidden)
    .background(Color.appBackground)
}

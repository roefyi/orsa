//
//  SettingsCardView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import StoreKit

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
                .background(Color.cardText.opacity(0.2))
            
            SettingsRowView(title: "appearance", action: {
                showingAppearance = true
            })
            
            Divider()
                .background(Color.cardText.opacity(0.2))
            
            SettingsRowView(title: "privacy policy", action: {
                showingPrivacyPolicy = true
            })
            
            Divider()
                .background(Color.cardText.opacity(0.2))
            
            SettingsRowView(title: "terms of service", action: {
                showingTermsOfService = true
            })
            
            Divider()
                .background(Color.cardText.opacity(0.2))
            
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
                .background(Color.cardText.opacity(0.2))
            
            SettingsRowView(title: "meet the builder", action: {
                if let url = URL(string: "https://twitter.com/roefyi") {
                    UIApplication.shared.open(url)
                }
            })
        }
        .background(Color.cardBackground)
        .cornerRadius(12)
        .sheet(isPresented: $showingMeasurements) {
            MeasurementsView()
        }
        .sheet(isPresented: $showingAppearance) {
            AppearanceView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            WebViewSheet(title: "Privacy Policy", url: "https://example.com/privacy")
        }
        .sheet(isPresented: $showingTermsOfService) {
            WebViewSheet(title: "Terms of Service", url: "https://example.com/terms")
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
                    .foregroundColor(.cardText)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.cardText.opacity(0.5))
            }
            .padding(.vertical, 12)
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
            .background(Color.appBackground)
            .navigationTitle("measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
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
            .background(Color.appBackground)
            .navigationTitle("appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
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
                        .foregroundColor(.primaryText)
                        .padding()
                }
            }
            .background(Color.appBackground)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
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

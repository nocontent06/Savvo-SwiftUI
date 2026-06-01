import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var store: GoalsStore

    private let tips: [(icon: String, title: String, description: String)] = [
        ("lightbulb.fill", "50-30-20 Regel", "50 % für Bedürfnisse, 30 % für Wünsche, 20 % zum Sparen – ein bewährter Budgetansatz."),
        ("arrow.trianglehead.2.clockwise", "Automatisch sparen", "Richte einen Dauerauftrag ein, der automatisch nach jedem Gehaltseingang einen Betrag überweist."),
        ("chart.line.uptrend.xyaxis", "Zinseszinseffekt", "Je früher du anfängst zu sparen, desto stärker arbeitet der Zinseszins für dich."),
        ("cart.fill", "Einkaufslisten nutzen", "Plane Einkäufe im Voraus und vermeide Spontankäufe – das spart überraschend viel."),
        ("tag.fill", "Kleine Ziele setzen", "Unterteile große Sparziele in kleinere Meilensteine, um motiviert zu bleiben."),
        ("banknote.fill", "Notgroschen aufbauen", "Lege 3–6 Monatsausgaben als Notgroschen zurück, bevor du in andere Ziele investierst."),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(tips, id: \.title) { tip in
                        TipCardView(icon: tip.icon, title: tip.title, description: tip.description)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Explore")
        }
    }
}

private struct TipCardView: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primary)
                .frame(width: 40, height: 40)
                .background(AppColors.primary.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

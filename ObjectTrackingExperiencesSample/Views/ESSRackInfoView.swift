/*
ESS Rack information panel view
*/
import SwiftUI

struct ESSRackInfoView: View {
    let rack: BatteryRack

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(rack.id)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, 8)

            // Main metrics
            HStack(spacing: 30) {
                MetricCard(
                    label: "Rack#001",
                    value: String(format: "%.1fV", rack.totalVoltage),
                    icon: "bolt.fill",
                    color: .yellow
                )

                MetricCard(
                    label: "Current",
                    value: String(format: "%.1fA", rack.totalCurrent),
                    icon: "waveform.path.ecg",
                    color: .green
                )

                MetricCard(
                    label: "Power",
                    value: String(format: "%.1fkW", rack.power),
                    icon: "bolt.circle.fill",
                    color: .orange
                )

                MetricCard(
                    label: "SOC",
                    value: String(format: "%.0f%%", rack.averageSOC),
                    icon: "battery.75",
                    color: .blue
                )
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(width: 700)
    }
}

struct MetricCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/*
State of Charge (SoC) heatmap visualization
*/
import SwiftUI

struct SoCHeatmapView: View {
    let rack: BatteryRack
    let columns: Int = 12
    let rows: Int = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            HStack {
                Text("Cell SoC Heatmap")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "square.grid.3x3.fill")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.bottom, 8)

            // Heatmap Grid
            VStack(spacing: 4) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<columns, id: \.self) { col in
                            let cellIndex = row * columns + col
                            if cellIndex < allCells.count {
                                CellHeatmapTile(cell: allCells[cellIndex])
                            }
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 20) {
                Text("SOC")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    LegendItem(color: .blue, label: "0-20%")
                    LegendItem(color: .cyan, label: "20-40%")
                    LegendItem(color: .green, label: "40-60%")
                    LegendItem(color: .yellow, label: "60-80%")
                    LegendItem(color: .orange, label: "80-100%")
                }
            }
            .padding(.top, 12)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(width: 700)
    }

    private var allCells: [BatteryCell] {
        rack.modules.flatMap { $0.cells }
    }
}

struct CellHeatmapTile: View {
    let cell: BatteryCell

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(cell.socColor.opacity(0.8))
            .frame(width: 45, height: 30)
            .overlay(
                Text(String(format: "%.0f", cell.soc))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white)
            )
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 20, height: 12)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

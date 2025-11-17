/*
ESS (Energy Storage System) data model for monitoring battery racks, modules, and cells.
*/
import Foundation
import SwiftUI

/// Represents a single battery cell
struct BatteryCell: Identifiable {
    let id: Int
    var voltage: Double      // Voltage in V
    var current: Double      // Current in A
    var temperature: Double  // Temperature in °C
    var soc: Double         // State of Charge in % (0-100)

    var socColor: Color {
        switch soc {
        case 0..<20: return .blue
        case 20..<40: return .cyan
        case 40..<60: return .green
        case 60..<80: return .yellow
        default: return .orange
        }
    }
}

/// Represents a battery module containing multiple cells
struct BatteryModule: Identifiable {
    let id: Int
    var cells: [BatteryCell]

    var totalVoltage: Double {
        cells.reduce(0) { $0 + $1.voltage }
    }

    var averageCurrent: Double {
        guard !cells.isEmpty else { return 0 }
        return cells.reduce(0) { $0 + $1.current } / Double(cells.count)
    }

    var averageSOC: Double {
        guard !cells.isEmpty else { return 0 }
        return cells.reduce(0) { $0 + $1.soc } / Double(cells.count)
    }
}

/// Represents a complete battery rack containing multiple modules
@Observable
class BatteryRack {
    let id: String
    var modules: [BatteryModule]

    init(id: String, moduleCount: Int = 8, cellsPerModule: Int = 12) {
        self.id = id
        self.modules = []

        // Initialize with sample data
        for moduleIndex in 0..<moduleCount {
            var cells: [BatteryCell] = []
            for cellIndex in 0..<cellsPerModule {
                let cell = BatteryCell(
                    id: moduleIndex * cellsPerModule + cellIndex,
                    voltage: Double.random(in: 3.2...4.2),
                    current: Double.random(in: 0...10),
                    temperature: Double.random(in: 20...45),
                    soc: Double.random(in: 60...95)
                )
                cells.append(cell)
            }
            let module = BatteryModule(id: moduleIndex, cells: cells)
            modules.append(module)
        }
    }

    var totalVoltage: Double {
        modules.reduce(0) { $0 + $1.totalVoltage }
    }

    var totalCurrent: Double {
        guard !modules.isEmpty else { return 0 }
        return modules.reduce(0) { $0 + $1.averageCurrent } / Double(modules.count)
    }

    var averageSOC: Double {
        guard !modules.isEmpty else { return 0 }
        return modules.reduce(0) { $0 + $1.averageSOC } / Double(modules.count)
    }

    var power: Double {
        totalVoltage * totalCurrent / 1000 // kW
    }

    /// Update data to simulate real-time monitoring
    func updateData() {
        for moduleIndex in modules.indices {
            for cellIndex in modules[moduleIndex].cells.indices {
                // Simulate slight variations in readings
                modules[moduleIndex].cells[cellIndex].voltage += Double.random(in: -0.05...0.05)
                modules[moduleIndex].cells[cellIndex].current += Double.random(in: -0.5...0.5)
                modules[moduleIndex].cells[cellIndex].temperature += Double.random(in: -0.2...0.2)
                modules[moduleIndex].cells[cellIndex].soc += Double.random(in: -0.1...0.1)

                // Keep values in valid ranges
                modules[moduleIndex].cells[cellIndex].voltage = max(3.0, min(4.2, modules[moduleIndex].cells[cellIndex].voltage))
                modules[moduleIndex].cells[cellIndex].current = max(0, min(15, modules[moduleIndex].cells[cellIndex].current))
                modules[moduleIndex].cells[cellIndex].temperature = max(15, min(60, modules[moduleIndex].cells[cellIndex].temperature))
                modules[moduleIndex].cells[cellIndex].soc = max(0, min(100, modules[moduleIndex].cells[cellIndex].soc))
            }
        }
    }
}

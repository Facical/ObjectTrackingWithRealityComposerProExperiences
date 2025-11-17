/*
ESS (Energy Storage System) monitoring immersive view with object tracking
*/
import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct ESSImmersiveView: View {
    @State private var rootEntity: Entity!
    @State private var anchorEntity: Entity!
    @State private var rackEntity: Entity!
    @State private var targetEntity: Entity!
    @State private var objectTrackingGuide: ObjectTrackingGuide!
    @State private var updateTimer: Timer?

    @Environment(AppModel.self) private var appModel

    // ESS Data
    @State private var batteryRack = BatteryRack(id: "Rack#001", moduleCount: 8, cellsPerModule: 12)

    // UI IDs
    private let rackInfoID = "rackInfoPanel"
    private let heatmapID = "heatmapPanel"
    private let lookAroundLabelsID = "lookAroundLabel"

    // Entity names
    private let anchorEntityName = "Anchor"
    private let targetEntityName = "Target"
    private let rackRefObjPath = "Rack"  // Path to Rack.usdz in RealityKit Content

    var body: some View {
        RealityView { content, attachments in
            // Load the main scene
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
                setupEntities(content, rootEntity: immersiveContentEntity)
                setupAttachments(attachments)
                await setupGuide(content, attachments: attachments)
                startDataUpdateTimer()
            }
        } update: { content, attachments in
            // Update UI when data changes
            updateAttachments(attachments)
        }
        attachments: {
            // Rack information panel
            Attachment(id: rackInfoID) {
                ESSRackInfoView(rack: batteryRack)
            }

            // SoC Heatmap panel
            Attachment(id: heatmapID) {
                SoCHeatmapView(rack: batteryRack)
            }

            // Look around instruction
            Attachment(id: lookAroundLabelsID) {
                Text("Look around for the battery rack")
                    .font(.title2)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .task {
            FadeOutSystem.registerSystem()
        }
        .onDisappear {
            stopDataUpdateTimer()
        }
    }

    private func setupEntities(_ content: RealityViewContent, rootEntity: Entity) {
        self.rootEntity = rootEntity
        anchorEntity = rootEntity.findEntity(named: anchorEntityName)
        targetEntity = rootEntity.findEntity(named: targetEntityName)

        // Load the Rack model
        Task {
            if let rackModel = try? await Entity(named: rackRefObjPath, in: realityKitContentBundle) {
                self.rackEntity = rackModel
            }
        }
    }

    private func setupAttachments(_ attachments: RealityViewAttachments) {
        // Position the rack info panel above the rack
        if let rackInfoPanel = attachments.entity(for: rackInfoID) {
            rackInfoPanel.position = [0, 0.6, 0]  // Above the rack
            anchorEntity?.addChild(rackInfoPanel)
        }

        // Position the heatmap panel to the side
        if let heatmapPanel = attachments.entity(for: heatmapID) {
            heatmapPanel.position = [0.8, 0.3, 0]  // To the right of the rack
            anchorEntity?.addChild(heatmapPanel)
        }
    }

    private func updateAttachments(_ attachments: RealityViewAttachments) {
        // Attachments update automatically with @State changes
    }

    private func setupGuide(_ content: RealityViewContent, attachments: RealityViewAttachments) async {
        guard let guideEntity = try? await Entity(named: rackRefObjPath, in: realityKitContentBundle) else {
            AppLogger.logError("Could not create guide entity from \(rackRefObjPath)")
            return
        }

        guard let lookAroundLabelEntity = attachments.entity(for: lookAroundLabelsID) else {
            AppLogger.logWarning("Look around label not available")
            return
        }

        targetEntity?.setOpacity(0.0)

        // Adjust guide entity orientation for better visibility
        guideEntity.orientation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))

        objectTrackingGuide = await ObjectTrackingGuide(
            content: content,
            anchorEntity: anchorEntity!,
            guideEntity: guideEntity,
            guideTextEntity: lookAroundLabelEntity,
            targetEntity: targetEntity!
        ) {
            // Completion handler - called when object is found
            targetEntity?.setOpacity(1.0)
            showESSPanels()
        }

        let initialState = appModel.immersiveSpaceState
        appModel.immersiveSpaceState = .inTransition
        await objectTrackingGuide.show()
        appModel.immersiveSpaceState = initialState
    }

    private func showESSPanels() {
        // Panels are shown via attachments
        AppLogger.logInfo("Battery rack detected - showing ESS panels")
    }

    // Simulate real-time data updates
    private func startDataUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            batteryRack.updateData()
        }
    }

    private func stopDataUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}

extension Entity {
    func setOpacity(_ opacity: Float) {
        if var opacityComponent = components[OpacityComponent.self] {
            opacityComponent.opacity = opacity
            components.set(opacityComponent)
        } else {
            components.set(OpacityComponent(opacity: opacity))
        }
    }
}

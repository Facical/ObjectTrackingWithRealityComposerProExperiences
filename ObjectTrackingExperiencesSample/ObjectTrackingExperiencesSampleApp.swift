/*
ESS XR Visualization App
Initializes the app, manages the main content and immersive AR spaces for ESS monitoring.
*/
import SwiftUI

@main
struct ObjectTrackingExperiencesSampleApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ESSImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
     }
}

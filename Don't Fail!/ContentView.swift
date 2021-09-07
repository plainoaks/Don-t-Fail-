import SwiftUI
import SpriteKit

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var scene = GameScene(size: CGSize(width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height))
    
    var body: some View {
        SpriteView(scene: scene)
            .frame(width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height)
            .ignoresSafeArea()
            .onChange(of: scenePhase, perform: { phase in
                if phase == .inactive {
                    scene.isPaused = true
                    scene.isPausing = true
                }
                if phase == .active {
                    scene.isPaused = false
                }
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

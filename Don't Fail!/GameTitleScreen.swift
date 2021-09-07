import SwiftUI
import SpriteKit

class GameTitleScreen {
    
    func initializeScreen(scene: GameScene) {
        scene.removeAllChildren()
        scene.isPausing = false
        scene.isStarted = false
        
        let title = SKLabelNode(fontNamed: "Cochin")
        title.text = "Don't Fail!"
        title.fontSize = 64
        title.position = CGPoint(x: scene.frame.midX, y: scene.frame.height * 0.6)
        scene.addChild(title)
        
        scene.startButton = SKShapeNode(rectOf: CGSize(width: scene.frame.width * 0.4, height: 80), cornerRadius: 10)
        scene.startButton.name = "START"
        scene.startButton.position = CGPoint(x: scene.frame.midX, y: scene.frame.height * 0.3)
        scene.addChild(scene.startButton)
        
        let startButtonLabel = SKLabelNode(fontNamed: "Cochin")
        startButtonLabel.text = "START"
        startButtonLabel.name = "START"
        startButtonLabel.position = scene.startButton.position
        startButtonLabel.zPosition = 2
        startButtonLabel.verticalAlignmentMode = .center
        scene.addChild(startButtonLabel)
        
        scene.isStarted = false
    }
    
    func touchesBegan(scene: GameScene) {
        if !scene.isStarted {
            let touchPoint = scene.atPoint(scene.lastTouch)
            if touchPoint.name == "START" {
                scene.startButton.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            }
        }
    }
    
    func touchesMoved(scene: GameScene, touching: CGPoint) {
        if !scene.isStarted {
            scene.lastTouch = touching
            let firstTouchPoint = scene.atPoint(scene.firstTouch)
            if firstTouchPoint.name == "START" {
                let touchPoint = scene.atPoint(scene.lastTouch)
                if touchPoint.name == "START" {
                    scene.startButton.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
                } else {
                    scene.startButton.fillColor = UIColor.clear
                }
            }
        }
    }
    
    func touchesEnded(scene: GameScene) {
        if !scene.isStarted {
            let firstTouchPoint = scene.atPoint(scene.firstTouch)
            if firstTouchPoint.name == "START" {
                let touchPoint = scene.atPoint(scene.lastTouch)
                if touchPoint.name == "START" {
                    scene.startButton.fillColor = UIColor.clear
                    scene.isStarted = true
                    GameScreen().initializeScreen(scene: scene)
                }
            }
        }
    }
}

import SwiftUI
import SpriteKit

class Barrage {
    
    var scene: GameScene
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func fire(enemyPosition: CGPoint, dx: CGFloat, dy: CGFloat, color: UIColor) {
        let enemyBullet = SKShapeNode(circleOfRadius: 3.0)
        enemyBullet.glowWidth = 0.1
        enemyBullet.fillColor = .white
        enemyBullet.strokeColor = color
        enemyBullet.position = enemyPosition
        enemyBullet.physicsBody = SKPhysicsBody(circleOfRadius: 2.5)
        enemyBullet.physicsBody?.categoryBitMask = self.scene.enemyBulletCategory
        enemyBullet.physicsBody?.contactTestBitMask = self.scene.spaceshipCategory + self.scene.screenCategory
        enemyBullet.physicsBody?.collisionBitMask = 0
        enemyBullet.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
        enemyBullet.physicsBody?.linearDamping = 0
        enemyBullet.zRotation = atan(dy/dx)
        self.scene.addChild(enemyBullet)
    }
    
    func run() {
        // code
    }
}

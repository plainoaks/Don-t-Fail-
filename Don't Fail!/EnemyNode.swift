import SwiftUI
import SpriteKit

class EnemyNode: SKSpriteNode {
    var body: SKSpriteNode!
    var hp: CGFloat!
    let max_hp: CGFloat
    var healthBar: SKSpriteNode!
    
    var isInvincible: Bool = true
    var isCrazy: Bool = false
    var isDead: Bool = false
    
//    var mainWeapon: (() -> Void)!
    var mainWeapon: Barrage!
    var attackStarted: Bool = false
    var attackEnded: Bool = false
    var lastBarrage: TimeInterval!
    var lastBullet: TimeInterval!
    var frameCount: Int
    
    init(scene: GameScene, max_hp: CGFloat) {
        self.max_hp = max_hp
        self.hp = max_hp
        self.lastBarrage = nil
        self.lastBullet = nil
        self.frameCount = 0

        let enemyTexture = SKTexture(imageNamed: "enemy")
        super.init(texture: nil, color: .clear, size: enemyTexture.size())
        
        self.body = SKSpriteNode(imageNamed: "enemy")
        addChild(self.body)
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 6.0)
        self.body.run(SKAction.repeatForever(rotate))
        
        self.healthBar = SKSpriteNode(color: .blue, size: CGSize(width: self.size.width, height: 5))
        self.healthBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        self.healthBar.position = CGPoint(x: -self.size.width * 0.5, y: self.size.height * 0.5 + 15)
        self.healthBar.zRotation = 0
        addChild(self.healthBar)
        let healthBarBackground = SKSpriteNode(imageNamed: "healthBarBackground")
        healthBarBackground.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        healthBarBackground.position = CGPoint(x: 0, y: 0)
        self.healthBar.addChild(healthBarBackground)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHealthBar() {
        let scale = self.hp / self.max_hp
        self.healthBar.size.width = self.size.width * scale
    }
}

import SwiftUI
import SpriteKit
import Foundation

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    
    private var gameTitleScreen: GameTitleScreen!
    private var gameScreen: GameScreen!
    
    var firstTouch: CGPoint!
    var lastTouch: CGPoint!
    
    let missileInterval: Double = 0.1
    
    var startTime: TimeInterval!
    var currentTime: TimeInterval!
    var lastUpdateTime: TimeInterval!
    var lastEnemyAppear: TimeInterval!
    
    var isStarted: Bool = false
    var isEnded: Bool = true
    var isPausing: Bool = false
    var isReleased: Bool = false
    
    let spaceshipCategory: UInt32 = 1<<0
    let missileCategory: UInt32 = 1<<1
    let enemyCategory: UInt32 = 1<<2
    let enemyBulletCategory: UInt32 = 1<<3
    let screenCategory: UInt32 = 1<<4
    
    var spaceship: SKSpriteNode!
    var spaceshipSize: CGSize = CGSize(width: 10, height: 20)
    var spaceship_x: CGFloat!
    var spaceship_y: CGFloat!
    
    var enemies: [String : EnemyNode]!
    var enemyCount: Int!
    var maxEnemyNumber: Int = 2
    var killCount: Int!
    
    var startButton: SKShapeNode!
    var retryButton: SKShapeNode!
    var toTopButton: SKShapeNode!
    
    override func didMove(to view: SKView) {
        self.gameTitleScreen = GameTitleScreen()
        self.gameScreen = GameScreen()
        
        self.gameTitleScreen.initializeScreen(scene: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        self.firstTouch = t.location(in: self)
        self.lastTouch = self.firstTouch
        
        self.gameTitleScreen.touchesBegan(scene: self)
        gameScreen.touchesBegan(scene: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let touching = t.location(in: self)
        
        self.gameTitleScreen.touchesMoved(scene: self, touching: touching)
        gameScreen.touchesMoved(scene: self, touching: touching)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        self.lastTouch = t.location(in: self)
        
        self.gameTitleScreen.touchesEnded(scene: self)
        gameScreen.touchesEnded(scene: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !isEnded {
            if self.startTime == nil {
                self.startTime = currentTime
            }
            if self.currentTime == nil {
                self.currentTime = currentTime
                gameScreen.addEnemy(scene: self)
                self.lastEnemyAppear = currentTime
            }
            
            if isPausing {
                for enemy in self.enemies.values {
                    enemy.lastBarrage += currentTime - self.currentTime
                }
                self.startTime += currentTime - self.currentTime
                isPausing = false
            }
            
            self.currentTime = currentTime
            
            for enemy in self.enemies.values {
                if enemy.lastBarrage == nil {
                    enemy.lastBarrage = currentTime + 5.0
                }
                if enemy.lastBullet == nil {
                    enemy.lastBullet = enemy.lastBarrage
                }
                if !isPausing {
                    enemy.mainWeapon()
                }
            }
            if self.lastUpdateTime == nil {
                self.lastUpdateTime = currentTime
            }
            
            if self.lastEnemyAppear + 10.0 <= currentTime && self.enemyCount < self.maxEnemyNumber {
                self.gameScreen.addEnemy(scene: self)
                self.lastEnemyAppear = currentTime
            }
            
            if self.lastUpdateTime + self.missileInterval <= currentTime {
                self.gameScreen.shootMissile(scene: self, -60, 600)
                self.gameScreen.shootMissile(scene: self, 0, 600)
                self.gameScreen.shootMissile(scene: self, 60, 600)
                self.lastUpdateTime = currentTime
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // missile -- screen, enemy
        // enemyBullet -- screen, spaceship
        // enemy -- missile
        // spaceship -- enemyBullet
        // screen -- missile, enemyBullet
        
        let target = contact.bodyA
        switch target.categoryBitMask {
        case self.screenCategory:
            guard let anyNode = contact.bodyB.node else { return }
            anyNode.removeFromParent()
//            print("collided with screen")
        case self.missileCategory:
            guard let missileNode = target.node else { return }
            missileNode.removeFromParent()
            if contact.bodyB.categoryBitMask == self.enemyCategory {
                self.gameScreen.hitting(scene: self, enemy: contact.bodyB)
            } else {
//                print("collided with screen")
            }
        case self.enemyBulletCategory:
            guard let enemyBulletNode = target.node else { return }
            enemyBulletNode.removeFromParent()
            if contact.bodyB.categoryBitMask == self.spaceshipCategory {
                self.gameScreen.failed(scene: self)
            } else {
//                print("collided with screen")
            }
        case self.enemyCategory:
            guard let missileNode = contact.bodyB.node else { return }
            missileNode.removeFromParent()
            self.gameScreen.hitting(scene: self, enemy: contact.bodyA)
        case self.spaceshipCategory:
            guard let enemyBulletNode = contact.bodyB.node else { return }
            enemyBulletNode.removeFromParent()
            self.gameScreen.failed(scene: self)
        default:
            return
        }
    }
}

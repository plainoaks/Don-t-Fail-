import SwiftUI
import SpriteKit

class GameScreen {
    
    func initializeScreen(scene: GameScene) {
        scene.removeAllChildren()
        scene.isPausing = false
        scene.isStarted = true
        scene.isEnded = false
        scene.isReleased = false
        scene.enemies = [:]
        scene.enemyCount = 0
        scene.killCount = 0
        scene.startTime = nil
        scene.currentTime = nil
        scene.lastUpdateTime = nil
        
        scene.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -scene.spaceshipSize.width/2, y: -scene.spaceshipSize.height/2, width: scene.frame.width + scene.spaceshipSize.width, height: scene.frame.height + scene.spaceshipSize.height))
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        scene.physicsWorld.contactDelegate = scene
        scene.physicsBody?.categoryBitMask = scene.screenCategory
        scene.physicsBody?.contactTestBitMask = scene.missileCategory + scene.enemyBulletCategory
        scene.spaceship = SKSpriteNode(color: UIColor.green, size: scene.spaceshipSize)
        scene.spaceship_x = scene.frame.midX
        scene.spaceship_y = scene.frame.midY / 2
        scene.spaceship.position = CGPoint(x: scene.spaceship_x, y: scene.spaceship_y)
        scene.spaceship.physicsBody = SKPhysicsBody(rectangleOf: scene.spaceship.size)
        scene.spaceship.physicsBody?.categoryBitMask = scene.spaceshipCategory
        scene.spaceship.physicsBody?.contactTestBitMask = scene.enemyBulletCategory
        scene.spaceship.physicsBody?.collisionBitMask = scene.screenCategory
        scene.addChild(scene.spaceship)
    }
    
    func touchesBegan(scene: GameScene) {
        if scene.isEnded {
            scene.isReleased = true
            let touchPoint = scene.atPoint(scene.lastTouch)
            if touchPoint.name == "RETRY" {
                scene.retryButton.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            }
            if touchPoint.name == "TOP" {
                scene.toTopButton.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            }
        }
    }
    
    func touchesMoved(scene: GameScene, touching: CGPoint) {
        if scene.isStarted {
            let minX = min(scene.spaceship_x + touching.x - scene.lastTouch.x, scene.frame.width)
            scene.spaceship_x = max(0, minX)
            let minY = min(scene.spaceship_y + touching.y - scene.lastTouch.y, scene.frame.height)
            scene.spaceship_y = max(0, minY)
            scene.spaceship.position = CGPoint(x: scene.spaceship_x, y: scene.spaceship_y)
            
        }
        
        scene.lastTouch = touching
        
        if scene.isEnded {
            if scene.isReleased {
                let firstTouchPoint = scene.atPoint(scene.firstTouch)
                if firstTouchPoint.name == "RETRY" || firstTouchPoint.name == "TOP" {
                    let touchPoint = scene.atPoint(scene.lastTouch)
                    if touchPoint.name == "RETRY" {
                        scene.retryButton.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
                    }
                    if touchPoint.name == "TOP" {
                        scene.toTopButton.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
                    }
                    if touchPoint.name != "RETRY" {
                        scene.retryButton.fillColor = UIColor.clear
                    }
                    if touchPoint.name != "TOP" {
                        scene.toTopButton.fillColor = UIColor.clear
                    }
                }
            }
        }
    }
    
    func touchesEnded(scene: GameScene) {
        if scene.isEnded {
            let firstTouchPoint = scene.atPoint(scene.firstTouch)
            if !scene.isReleased {
                scene.isReleased = true
            } else {
                if firstTouchPoint.name == "RETRY" || firstTouchPoint.name == "TOP" {
                    let touchPoint = scene.atPoint(scene.lastTouch)
                    if touchPoint.name == "RETRY" {
                        scene.retryButton.fillColor = UIColor.clear
                        initializeScreen(scene: scene)
                    }
                    if touchPoint.name == "TOP" {
                        scene.toTopButton.fillColor = UIColor.clear
                        GameTitleScreen().initializeScreen(scene: scene)
                    }
                }
            }
        }
    }
    
    func shootMissile(scene: GameScene, _ dx: CGFloat, _ dy: CGFloat) {
        let missile = SKShapeNode(circleOfRadius: 1.5)
        missile.fillColor = UIColor.white
        missile.position = CGPoint(x: scene.spaceship_x, y: scene.spaceship_y + scene.spaceship.size.height / 2)
        missile.physicsBody = SKPhysicsBody(circleOfRadius: 1.5)
        missile.physicsBody?.categoryBitMask = scene.missileCategory
        missile.physicsBody?.contactTestBitMask = scene.enemyCategory + scene.screenCategory
        missile.physicsBody?.collisionBitMask = 0
        missile.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
        missile.physicsBody?.linearDamping = 0
        scene.addChild(missile)
    }
    
    func addEnemy(scene: GameScene) {
        scene.enemyCount += 1
        let enemy = EnemyNode(max_hp: 200)
        enemy.position = CGPoint(x: scene.frame.width * CGFloat.random(in: 0.1...0.9), y: scene.frame.height)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = scene.enemyCategory
        enemy.physicsBody?.contactTestBitMask = scene.missileCategory
        enemy.physicsBody?.collisionBitMask = 0
        enemy.name = UUID().uuidString
        scene.addChild(enemy)
//        enemy.mainWeapon = OmniDirectionalBarrage(scene: scene, enemy: enemy, division: 32, duration: 0.0, timeInterval: 3.5, color: UIColor.cyan).run
        enemy.mainWeapon = SwirlBarrage(scene: scene, enemy: enemy, division: 8, duration: 0.1, timeInterval: 3.5, frameInterval: 2, color: UIColor.cyan).run
        
        scene.enemies[enemy.name!] = enemy
        
        let appear = SKAction.moveTo(y: scene.frame.height * 0.8, duration: 5.0)
        var firstDirection: CGFloat {
            if abs(enemy.position.x - scene.frame.width) >= enemy.position.x {
                return scene.frame.width * 0.9
            } else {
                return scene.frame.width * 0.1
            }
        }
        let battleStart = SKAction.moveTo(x: firstDirection, duration: TimeInterval(10.0 * abs(enemy.position.x-firstDirection) / (scene.frame.width * 0.9)))
        battleStart.timingMode = SKActionTimingMode.easeInEaseOut
        let toLeft = SKAction.moveTo(x: scene.frame.width * 0.1, duration: 10.0)
        let toRight = SKAction.moveTo(x: scene.frame.width * 0.9, duration: 10.0)
        toLeft.timingMode = SKActionTimingMode.easeInEaseOut
        toRight.timingMode = SKActionTimingMode.easeInEaseOut
        
        enemy.run(appear) {
            enemy.isInvincible = false
            if firstDirection == scene.frame.width * 0.9 {
                enemy.run(SKAction.sequence([battleStart, SKAction.repeatForever(SKAction.sequence([toLeft, toRight]))]))
            } else {
                enemy.run(SKAction.sequence([battleStart, SKAction.repeatForever(SKAction.sequence([toRight, toLeft]))]))
            }
        }
    }
    
    func hitting(scene: GameScene, enemy: SKPhysicsBody) {
        guard let enemyNode = enemy.node as? EnemyNode else { return }
        guard let explosion = SKEmitterNode(fileNamed: "Explosion") else { return }
        if !enemyNode.isInvincible {
            enemyNode.hp -= 1
            enemyNode.updateHealthBar()
            
            if enemyNode.hp <= enemyNode.max_hp * 0.5 {
                if !enemyNode.isCrazy {
                    enemyNode.isCrazy = true
                    enemyNode.mainWeapon = SwirlBarrage(scene: scene, enemy: enemyNode, division: 9, duration: 0.2, timeInterval: 3.0).run
                }
            }
            
            if enemyNode.hp <= 0 {
                if !enemyNode.isDead {
                    enemyNode.isDead = true
                    enemyNode.removeAllActions()
                    enemyNode.removeFromParent()
                    scene.killCount += 1
                    scene.enemies[enemyNode.name!] = nil
                    
                    explosion.position = enemyNode.position
                    scene.addChild(explosion)
                    explosion.run(SKAction.fadeOut(withDuration: 1.0)) {
                        explosion.removeFromParent()
                    }
                    
                    if scene.killCount == scene.maxEnemyNumber {
                        gameClear(scene: scene)
                    }
                }
            }
        }
    }
    
    func failed(scene: GameScene) {
        scene.isEnded = true
        scene.spaceship.removeFromParent()
        
        let loser = SKLabelNode(fontNamed: "Cochin")
        loser.text = "YOU FAILED..."
        loser.position = CGPoint(x: scene.frame.midX, y: scene.frame.height * 0.55)
        loser.fontSize = 48
        scene.addChild(loser)
        
        addRetryButton(scene: scene)
        addToTopButton(scene: scene)
    }
    
    func gameClear(scene: GameScene) {
        scene.isEnded = true
        scene.spaceship.physicsBody?.categoryBitMask = 0
        
        let winner = SKLabelNode(fontNamed: "Cochin")
        winner.text = "You Win!"
        winner.position = CGPoint(x: scene.frame.midX, y: scene.frame.height * 0.55)
        winner.fontSize = 48
        scene.addChild(winner)
        
        addRetryButton(scene: scene)
        addToTopButton(scene: scene)
    }
    
    func addRetryButton(scene: GameScene) {
        scene.retryButton = SKShapeNode(rectOf: CGSize(width: scene.frame.width * 0.4, height: 70), cornerRadius: 10)
        scene.retryButton.position = CGPoint(x: scene.frame.width * 0.25, y: scene.frame.midY - 160)
        scene.retryButton.name = "RETRY"
        scene.addChild(scene.retryButton)
        
        let retryLabel = SKLabelNode(fontNamed: "Cochin")
        retryLabel.text = "RETRY"
        retryLabel.position = scene.retryButton.position
        retryLabel.verticalAlignmentMode = .center
        retryLabel.name = "RETRY"
        scene.addChild(retryLabel)
    }
    
    func addToTopButton(scene: GameScene) {
        scene.toTopButton = SKShapeNode(rectOf: CGSize(width: scene.frame.width * 0.4, height: 70), cornerRadius: 10)
        scene.toTopButton.position = CGPoint(x: scene.frame.width * 0.75, y: scene.frame.midY - 160)
        scene.toTopButton.name = "TOP"
        scene.addChild(scene.toTopButton)
        
        let topLabel = SKLabelNode(fontNamed: "Cochin")
        topLabel.text = "TOP"
        topLabel.position = scene.toTopButton.position
        topLabel.verticalAlignmentMode = .center
        topLabel.name = "TOP"
        scene.addChild(topLabel)
    }
    
}

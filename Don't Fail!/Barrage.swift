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
}

class OmniDirectionalBarrage: Barrage {
    let name: String
    let enemy: EnemyNode
    let division: Int
    let duration: TimeInterval
    let timeInterval: TimeInterval
    let frameInterval: Int
    let color: UIColor

    
    init(scene: GameScene, enemy: EnemyNode, division: Int, duration: TimeInterval, timeInterval: TimeInterval, frameInterval: Int = 2, color: UIColor = UIColor.cyan) {
        self.name = "omniDirectional"
        self.enemy = enemy
        self.division = division
        self.duration = duration
        self.timeInterval = timeInterval
        self.frameInterval = frameInterval
        self.color = color
        super.init(scene: scene)
    }
    
    func run() {
        if self.enemy.lastBarrage <= self.scene.currentTime {
            if self.enemy.lastBarrage + self.timeInterval >= self.scene.currentTime {
                if !self.enemy.attackStarted {
                    self.enemy.lastBullet = self.enemy.lastBarrage
                    self.enemy.frameCount = 0
                    self.enemy.attackStarted = true
                    self.enemy.attackEnded = false
                }
                if self.enemy.lastBarrage + self.duration >= self.enemy.lastBullet {
                    if self.enemy.frameCount % self.frameInterval == 0 {
                        for i in 0..<self.division {
                            let rotation: CGFloat = 2.0 * CGFloat.pi * CGFloat(i) / CGFloat(self.division)
                            let speed:CGFloat = 60.0
                            fire(enemyPosition: self.enemy.position, dx: speed*cos(rotation), dy: speed*sin(rotation), color: self.color)
                        }
                        self.enemy.lastBullet = self.scene.currentTime
                    }
                    self.enemy.frameCount += 1
                } else {
                    self.enemy.attackEnded = true
                }
                
                if self.enemy.attackEnded {
                    self.enemy.lastBarrage += self.timeInterval
                    self.enemy.frameCount = 0
                    self.enemy.attackStarted = false
                }
            }
        }
    }
}

class SwirlBarrage: Barrage {
    let name: String
    
    let enemy: EnemyNode
    let division: Int
    let timeInterval: TimeInterval
    let duration: TimeInterval
    let frameInterval: Int
    let color: UIColor
    
    
    init(scene: GameScene, enemy: EnemyNode, division: Int, duration: TimeInterval, timeInterval: TimeInterval, frameInterval: Int = 2, color: UIColor = UIColor.yellow) {
        self.name = "swirl"
        self.enemy = enemy
        self.division = division
        self.duration = duration
        self.timeInterval = timeInterval
        self.frameInterval = frameInterval
        self.color = color
        super.init(scene: scene)
    }
    
    func run() {
        if self.enemy.lastBarrage <= self.scene.currentTime {
            if self.enemy.lastBarrage + self.timeInterval >= self.scene.currentTime {
                if !self.enemy.attackStarted {
                    self.enemy.lastBullet = self.enemy.lastBarrage
                    self.enemy.frameCount = 0
                    self.enemy.attackStarted = true
                    self.enemy.attackEnded = false
                }
                if self.enemy.lastBarrage + self.duration >= self.enemy.lastBullet {
                    if self.enemy.frameCount % self.frameInterval == 0 {
                        for i in 0..<self.division {
                            let rotation: CGFloat = CGFloat.pi + CGFloat.pi * CGFloat(i) / CGFloat(self.division) + CGFloat(self.enemy.frameCount) / 20.0
                            let speed:CGFloat = 3.0 * CGFloat(self.enemy.frameCount % 30) + 60.0
                            fire(enemyPosition: self.enemy.position, dx: speed*cos(rotation), dy: speed*sin(rotation), color: self.color)
//                            print("\(String(describing: self.enemy.frameCount)) \(rotation) \(speed)")
                        }
                        self.enemy.lastBullet = self.scene.currentTime
                    }
                    self.enemy.frameCount += 1
                } else {
                    self.enemy.attackEnded = true
                }
                
                if self.enemy.attackEnded {
                    self.enemy.lastBarrage += self.timeInterval
                    self.enemy.frameCount = 0
                    self.enemy.attackStarted = false
                }
            }
        }
    }
}

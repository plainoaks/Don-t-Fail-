import SpriteKit
import SwiftUI

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
    
    override func run() {
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

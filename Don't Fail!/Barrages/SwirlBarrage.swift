import SpriteKit
import SwiftUI

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
                            let speed:CGFloat = 3.0 * CGFloat(self.enemy.frameCount % 30) + 70.0
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

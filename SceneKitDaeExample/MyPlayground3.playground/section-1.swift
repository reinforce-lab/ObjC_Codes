import UIKit
import SpriteKit
import XCPlayground

let view:SKView = SKView(frame: CGRectMake(0, 0, 1000, 800))
let scene:SKScene = SKScene(size: CGSizeMake(1000, 800))
scene.scaleMode = SKSceneScaleMode.AspectFit

let blueBox: SKSpriteNode = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(300, 300))
blueBox.position = CGPointMake(512, 384)
scene.addChild(blueBox)

view.presentScene(scene)

XCPShowView("The Scene View", view)

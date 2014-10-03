import SceneKit
import SpriteKit
import XCPlayground

let width:CGFloat = 600
let height:CGFloat = 600

var view = SCNView(frame: CGRect(x: 0, y: 0, width: width, height: height))
XCPShowView("View", view)

var scene = SCNScene()
view.scene = scene
view.backgroundColor = UIColor.blackColor()
view.autoenablesDefaultLighting = true

var camera = SCNCamera()
var cameraNode = SCNNode()
cameraNode.camera = camera
cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
scene.rootNode.addChildNode(cameraNode)

for var i = 0; i < 40; i++ {
    var torus = SCNTorus(
        ringRadius: CGFloat(arc4random_uniform(150)) / 100.0,
        pipeRadius: 0.05)
    var torusNode = SCNNode(geometry: torus)
    scene.rootNode.addChildNode(torusNode)

    torus.firstMaterial?.diffuse.contents = SKColor(
        hue: CGFloat(arc4random_uniform(100)) / 300.0 + 0.3,
        saturation: 0.5,
        brightness: 1.2,
        alpha: 0.9)
    torus.firstMaterial?.specular.contents = UIColor.yellowColor()
    
    var spin = CABasicAnimation(keyPath: "rotation")
    spin.toValue = NSValue(SCNVector4:SCNVector4(
        x: Float(CGFloat(random())),
        y: Float(CGFloat(random())),
        z: Float(CGFloat(random())),
        w: Float(CGFloat(M_PI) * 2.0)))
    spin.duration = NSTimeInterval(arc4random_uniform(10) + 10)
    spin.repeatCount = HUGE
    torusNode.addAnimation(spin, forKey: "spin")
}

//XCPShowView("View", view)

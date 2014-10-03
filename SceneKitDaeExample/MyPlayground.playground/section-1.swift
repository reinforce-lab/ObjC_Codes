import SceneKit
import SpriteKit
import XCPlayground // for the live preview

// create a scene view with an empty scene
var sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
var scene = SCNScene()
sceneView.scene = scene
sceneView.backgroundColor = SKColor.whiteColor()
sceneView.allowsCameraControl = true

// default lighting
sceneView.autoenablesDefaultLighting = true

// a label
/*
var label = UILabel(frame: CGRect(x:20, y:20, width:100, height:30))
label.text = "Label"
sceneView.addSubview(label)
*/

// a camera
var camera = SCNCamera()
var cameraNode = SCNNode()
cameraNode.camera = camera
cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
scene.rootNode.addChildNode(cameraNode)

// a geometry object
var torus = SCNTorus(ringRadius: 1, pipeRadius: 0.35)
var torusNode = SCNNode(geometry: torus)
scene.rootNode.addChildNode(torusNode)

// configure the geometry object
torus.firstMaterial?.diffuse.contents = UIColor.redColor()
//{1, 0,0,1}
//torus.firstMaterial?.diffuse.contents  = SKColor.redColor()
torus.firstMaterial?.specular.contents = SKColor.whiteColor()

//torus.firstMaterial?.diffuse.contents = "miku"

// animate the rotation of the torus
var spin = CABasicAnimation(keyPath: "rotation")
spin.toValue = NSValue(SCNVector4: SCNVector4(x: 1, y: 1, z: 0, w: Float(2.0*M_PI)))
spin.duration = 3
spin.repeatCount = HUGE // for infinity
torusNode.addAnimation(spin, forKey: "spin around")

// load an explore
/*
var explore = SCNScene(named: "art.scnassets/characters/explorer/explorer_skinned.dae", inDirectory: nil, options:
    [SCNSceneSourceConvertToYUpKey : true, SCNSceneSourceAnimationImportPolicyKey:SCNSceneSourceAnimationImportPolicyPlayRepeatedly])
*/

//let ex = SCNScene(named: "art.scnassets/characters/explorer/explorer_skinned.dae")
//scene.rootNode.addChildNode(ex.rootNode)

/*
// Retrieve the root node
SCNNode *node = scene.rootNode;

// Search for the node named "name"
if (name) {
node = [node childNodeWithName:name recursively:YES];
} else {
node = node.childNodes[0];
}
*/
// start a live preview of that view
XCPShowView("The Scene View", sceneView)

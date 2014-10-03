//
//  SceneKitViewController.m
//  iOS8Sampler
//
//  Created by Shuichi Tsutsumi on 2014/09/17.
//  Copyright (c) 2014 Shuichi Tsutsumi. All rights reserved.
//
//  Simplified and refactored the Apple's sample "SceneKit State of the Union demo"
//  https://developer.apple.com/wwdc/resources/sample-code/#//apple_ref/doc/uid/TP40014550


#import "ViewController.h"
@import SceneKit;
@import SpriteKit;


#define LOGO_SIZE 30


@interface ViewController ()
//<SCNSceneRendererDelegate>
@end


@implementation ViewController
{
@private
    
    //scene
    SCNScene *_scene;
    
    //references to nodes for manipulation
    SCNNode *_cameraHandle;
    SCNNode *_cameraOrientation;
    SCNNode *_cameraNode;
    SCNNode *_spotLightParentNode;
    SCNNode *_spotLightNode;
    SCNNode *_floorNode;
    SCNNode *_logoNode;
    SCNNode *_explorerNode;

    SCNNode *_introNodeGroup;

    CAAnimation *_jumpingAnimation;
    dispatch_source_t _timer;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self fadeIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


// =============================================================================
#pragma mark - Private

- (void)setup
{
    SCNView *sceneView = (SCNView *)self.view;
    
    sceneView.backgroundColor = [SKColor blackColor];
    
    //setup the scene
    [self setupScene];
    
    //present it
    sceneView.scene = _scene;
    
    //画面をグリグリ動かせる
    sceneView.allowsCameraControl = YES;
    
    //tweak physics
    sceneView.scene.physicsWorld.speed = 2.0;
    
    sceneView.jitteringEnabled = YES;
    
    //initial point of view
    sceneView.pointOfView = _cameraNode;
}

- (void)setupScene
{
    _scene = [SCNScene scene];
    
    // setup emvironments
    [self setupCamera];
    [self setupSpotLight];
    [self setupFloor];
    
    // configure the lighting for the introduction (dark lighting)
    _spotLightNode.light.color = [SKColor blackColor];
    _spotLightNode.position = SCNVector3Make(50, 90, -50);
    _spotLightNode.eulerAngles = SCNVector3Make(-M_PI_2*0.75, M_PI_4*0.5, 0);
    
    
    [self setupLogo];
    [self setupExplore];
}

- (void) setupCamera
{
    // |_   cameraHandle
    //   |_   cameraOrientation
    //     |_   cameraNode
    
    //create a main camera
    _cameraNode = [SCNNode node];
    _cameraNode.position = SCNVector3Make(0, 0, 120);
    
    //create a node to manipulate the camera orientation
    _cameraHandle = [SCNNode node];
    _cameraHandle.position = SCNVector3Make(0, 60, 0);
    
    _cameraOrientation = [SCNNode node];
    
    [_scene.rootNode addChildNode:_cameraHandle];
    [_cameraHandle addChildNode:_cameraOrientation];
    [_cameraOrientation addChildNode:_cameraNode];
    
    _cameraNode.camera = [SCNCamera camera];
    _cameraNode.camera.zFar = 800;
    _cameraNode.camera.yFov = 55;
}

//add a key light to the scene
- (void)setupSpotLight {
    
    _spotLightParentNode = [SCNNode node];
    _spotLightParentNode.position = SCNVector3Make(0, 90, 20);
    
    _spotLightNode = [SCNNode node];
    _spotLightNode.rotation = SCNVector4Make(1,0,0,-M_PI_4);
    
    _spotLightNode.light = [SCNLight light];
    _spotLightNode.light.type = SCNLightTypeSpot;
    _spotLightNode.light.color = [SKColor colorWithWhite:1.0 alpha:1.0];
    _spotLightNode.light.castsShadow = YES;
    _spotLightNode.light.shadowColor = [SKColor colorWithWhite:0 alpha:0.5];
    _spotLightNode.light.zNear = 30;
    _spotLightNode.light.zFar = 800;
    _spotLightNode.light.shadowRadius = 1.0;
    _spotLightNode.light.spotInnerAngle = 15;
    _spotLightNode.light.spotOuterAngle = 70;
    
    [_cameraNode addChildNode:_spotLightParentNode];
    [_spotLightParentNode addChildNode:_spotLightNode];
    
    
    // もう1つ正面からの照明を追加。
    _spotLightParentNode = [SCNNode node];
    _spotLightParentNode.position = SCNVector3Make(0, 5, 40);
    
    _spotLightNode = [SCNNode node];
    _spotLightNode.rotation = SCNVector4Make(1,0,0,-M_PI_4);
    
    _spotLightNode.light = [SCNLight light];
    _spotLightNode.light.type = SCNLightTypeOmni;
    _spotLightNode.light.color = [SKColor colorWithWhite:1.0 alpha:1.0];
    _spotLightNode.light.castsShadow = YES;
    _spotLightNode.light.shadowColor = [SKColor colorWithWhite:0 alpha:0.5];
    _spotLightNode.light.zNear = 30;
    _spotLightNode.light.zFar = 800;
    _spotLightNode.light.shadowRadius = 1.0;
    _spotLightNode.light.spotInnerAngle = 15;
    _spotLightNode.light.spotOuterAngle = 70;
    
    [_cameraNode addChildNode:_spotLightParentNode];
    [_spotLightParentNode addChildNode:_spotLightNode];
}

- (void)setupFloor {
    
    SCNFloor *floor = [SCNFloor floor];
    floor.reflectionFalloffEnd = 0;
    floor.reflectivity = 0;
    
    _floorNode = [SCNNode node];
    _floorNode.geometry = floor;
    _floorNode.geometry.firstMaterial.diffuse.contents = @"wood.png";
    _floorNode.geometry.firstMaterial.locksAmbientWithDiffuse = YES;
    _floorNode.geometry.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    _floorNode.geometry.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    _floorNode.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    
    _floorNode.physicsBody = [SCNPhysicsBody staticBody];
    _floorNode.physicsBody.restitution = 1.0;
    
    [_scene.rootNode addChildNode:_floorNode];
}

- (void)setupLogo
{
    //put all texts under this node to remove all at once later
    _introNodeGroup = [SCNNode node];
    
    _logoNode = [SCNNode nodeWithGeometry:[SCNPlane planeWithWidth:LOGO_SIZE height:LOGO_SIZE]];
    _logoNode.geometry.firstMaterial.diffuse.contents = @"SamplerIcon.png";
    _logoNode.geometry.firstMaterial.emission.contents = @"SamplerIcon.png";
    _logoNode.geometry.firstMaterial.emission.intensity = 0;
    
    // 両面表示
    SCNMaterial *m = [_logoNode.geometry.materials firstObject];
    m.doubleSided  = true;
    
    [_introNodeGroup addChildNode:_logoNode];
    _logoNode.position = SCNVector3Make(200, LOGO_SIZE/2, 1000);
    
    SCNVector3 position = SCNVector3Make(200, 0, 1000);
    
    _cameraNode.position = SCNVector3Make(200, -20, position.z+150);
    _cameraNode.eulerAngles = SCNVector3Make(-M_PI_2*0.06, 0, 0);
    
    [_scene.rootNode addChildNode:_introNodeGroup];
}

- (void)setupExplore
{
    SCNScene *scene = [SCNScene
                       sceneNamed:@"art.scnassets/characters/explorer/explorer_skinned.dae"
                       inDirectory:nil
                       options:@{SCNSceneSourceConvertToYUpKey : @YES,
                                 SCNSceneSourceAnimationImportPolicyKey : SCNSceneSourceAnimationImportPolicyPlayRepeatedly}];
    _explorerNode = [scene.rootNode.childNodes firstObject];
    _explorerNode.position = SCNVector3Make(200, 0, 1000);
    _explorerNode.scale = SCNVector3Make(0.3, 0.3, 0.3);
    [_scene.rootNode addChildNode:_explorerNode];

    // Load the DAE using SCNSceneSource in order to be able to retrieve the animation by its identifier
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"art.scnassets/characters/explorer/jump_start" withExtension:@"dae"];
    SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:url options:@{SCNSceneSourceConvertToYUpKey: @YES}];
    _jumpingAnimation = [sceneSource entryWithIdentifier:@"jump_start-1" withClass:[CAAnimation class]];
    _jumpingAnimation.fadeInDuration  = 0.1;
    _jumpingAnimation.fadeOutDuration = 0.1;
    _jumpingAnimation.repeatCount = 0;
    
    _jumpingAnimation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.25f block:^(CAAnimation *animation, id animatedObject, BOOL playingBackward){
        NSLog(@" leaving...");
    }]];
    
    // 一定時間ごとにジャンプ
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0,0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), 5.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        [_explorerNode removeAllAnimations];
        [_explorerNode addAnimation:_jumpingAnimation forKey:@"jump_start-1"];
        NSLog(@"jump");
    });
    dispatch_resume(_timer);

    
    /*
    SCNScene *scene = [SCNScene
                       sceneNamed: @"ark-project.scnassets/uju/Models/CH_uju_HI.dae"
                       inDirectory:nil
                       options:@{SCNSceneSourceConvertToYUpKey : @YES,
                                 SCNSceneSourceAnimationImportPolicyKey : SCNSceneSourceAnimationImportPolicyPlayRepeatedly}];
    _explorerNode = scene.rootNode;
    _explorerNode.position = SCNVector3Make(200, 0, 1000);
    _explorerNode.scale = SCNVector3Make(100, 100, 100);
    [_scene.rootNode addChildNode:_explorerNode];
*/
}

//wait, then fade in light
- (void)fadeIn {
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    [SCNTransaction setCompletionBlock:^{
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:2.5];
        
        _spotLightNode.light.color = [SKColor colorWithWhite:1 alpha:1];
        _logoNode.geometry.firstMaterial.emission.intensity = 0.75;
        
        [SCNTransaction commit];
    }];
    
    _spotLightNode.light.color = [SKColor colorWithWhite:0.001 alpha:1];
    
    [SCNTransaction commit];
}

@end

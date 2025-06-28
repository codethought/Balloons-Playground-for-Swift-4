/*:
# Balloons for Swift 6

A SpriteKit playground demonstrating physics, actions, and Swift Concurrency with `@MainActor`.

Adapted from the original [Swift Blog demo](https://developer.apple.com/swift/blog/?id=9) and modernised for Swift 6.

**Requirements**
- Xcode 17 or later
- macOS Sequoia (14.0) or newer
- Swift 6 toolchain
*/

import SpriteKit
import PlaygroundSupport

/*:
## Overview
This playground recreates the WWDC 2014 balloon-cannon demo using today’s best practices. Two cannons randomly fire balloons; when balloons collide, they pop. The project highlights how little code is needed to build an engaging SpriteKit scene and how Swift 6’s structured concurrency helps keep UI-related work on the main thread via `@MainActor`. The scene, derived from what was shown on stage at WWDC 2014, contains two cannons that each fire balloons at random intervals. When the balloons collide, they pop and disappear. In this playground, you’ll learn just how easy it is to create an engaging scene with custom motions and effects.
 

💡 *Live updates:* With the Live View visible (`Editor ▸ Live View`), every code change is re-built automatically so you can experiment freely.
  
 - Note:
 \
 If you don’t see the Balloon scene, open the timeline editor by choosing View > Assistant Editor > Show Assistant Editor (or press Option-Command-Return). Or using Editor | Live View
 
 Let's get started!
### Presenting the Scene in the Timeline
 
 SpriteKit content is presented in an `SKView` object. The view runs simulations and renders the content. All content is represented in an `SKScene` object, which is the root node for all nodes in a tree of `SKNode` objects. In this scene, you’ll add nodes and create your game’s content.
 The scene was loaded from a SpriteKit scene file, which we created in Xcode’s SpriteKit Level Designer. All resources, including scenes and image assets, have been embedded in the playground bundle and are available for us to use. You can add your own images in the bundle, too. Just right-click on the Balloons.playground file in the Finder and choose Show Package Contents.
 
 */

// MARK: - Scene Setup

let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 850, height: 638))
let scene = SKScene(fileNamed: "GameScene")
scene?.scaleMode = .aspectFill
sceneView.presentScene(scene)

//XCPShowView(identifier: "Balloons", view: sceneView) -- no longer used the next line makes the magic happen now
PlaygroundPage.current.liveView=sceneView

/*:
- Experiment:
\
\
Because gravity is defined by the scene’s physics world (its `physicsWorld` property), in the the world of SpriteKit laws of physics can be altered!
\
Turn the gravity upside down by changing the `scene.physicsWorld.gravity` vector. Hint: Invert the sign of the vector's `dy` component.
 
 To actually see the content of a scene in a playground, we use the XCPlayground function `XCPShowView`. This function renders the view live in the timeline editor so that the game is visible. From this point on, every change you make will be rendered live and be visible in the timeline editor.
 
 ### Firing the Cannons
 
 When the cannons fire, let’s add a balloon and move it across the scene. The balloons are sprite nodes, and we'll give each balloon a texture with a random element from our collection of balloon images.
 
 Here, we use the `map` function of Swift arrays to create an array of `SKTexture` objects from an array of image names. With our array of textures, we can simply generate a random index within its range and then create a sprite node with the texture at that index.
 
*/

// MARK: - Balloon Creation

let images = [
    "blue", "heart-blue", "star-blue",
    "green", "star-green", "heart-pink",
    "heart-red", "orange", "red",
    "star-gold", "star-pink", "star-red",
    "yellow"
]
let textures: [SKTexture] = images.map { SKTexture(imageNamed: "balloon-\($0)") }

/// Additional physics configuration injected by the scene after creating each balloon.
var configureBalloonPhysics: ((_ balloon: SKSpriteNode) -> Void)?

/// Creates a random balloon *on the main thread*.
@MainActor func createRandomBalloon() -> SKSpriteNode {
    let choice = Int(arc4random_uniform(UInt32(textures.count)))
    let balloon = SKSpriteNode(texture: textures[choice])
    configureBalloonPhysics?(balloon)
    
    return balloon
}

/*:
 - Experiment:
 \
You can add elements to the timeline by clicking the circle to the right of a line of code. This allows you to inspect the elements further.
 \
 \
Add the array of textures to the timeline. You may need to scroll down in the timeline to see it.
 
 Now that we’ve created the balloon, let’s make sure it can be moved across the screen. We do this by giving it a physics body. When simulating physics, nodes without physics bodies are not considered.
 
 In SpriteKit, a physics body can be assigned up to 32 different categories. You use categories to separate nodes from each other. Note that we assign the balloon category to the contact test bit mask. This causes collisions between two nodes to trigger a notification.
 
*/

/*:
> **Tip:** Click the grey circle in the gutter to pin any variable—`textures`, for example—to the timeline for visual inspection.
*/

// MARK: - Physics Categories
let BalloonCategory: UInt32 = 1 << 1
configureBalloonPhysics = { balloon in
    balloon.physicsBody = SKPhysicsBody(texture: balloon.texture!, size: balloon.size)
    balloon.physicsBody!.linearDamping = 0.5
    balloon.physicsBody!.mass = 0.1
    balloon.physicsBody!.categoryBitMask = BalloonCategory
    balloon.physicsBody!.contactTestBitMask = BalloonCategory
}

/*:
 - Experiment:
 \
Remove the line that assigns the `BalloonCategory` to the `contactTestBitMask`. What happens?

Modifying physics body properties is a great way to experiment, because of the immediate visual feedback that live rendering in playgrounds provides. Plus, you can inspect and debug your scenes on the spot.
 
 - Experiment:
 \
 Try to significantly increase or decrease the `mass` and `linearDamping` properties of the physics body. How does that affect the balloons? Change other physics body properties, too.

We still need to position the balloon and add it to the scene. We want balloons to be fired from the mouth of the cannons.
 
 */

/*:
Try commenting out the `contactTestBitMask` assignment above—balloons will pass through each other silently because no contact delegate message is generated.
*/

// MARK: - Display & Fire

let origin=CGPoint(x: 0, y: 0)

/// Adds the balloon to the scene at the mouth of the cannon.
let displayBalloon: (SKSpriteNode, SKNode) -> Void = { balloon, cannon in
    balloon.position = cannon.childNode(withName: "mouth")!.convert(origin, to: scene!)
    scene?.addChild(balloon)
}

/*:

 Notice that we determined the position of the balloon by asking for at child node named `mouth`. That’s possible because we explicitly added a node named `mouth` as a child of each cannon to define where the balloon should appear. This approach freed us from having to calculate the position, and if we wanted to reposition where the balloons first appear, we could do that directly in Xcode, without changing the code.
 
 To actually fire the balloon, we apply an impulse to its physics body to move it across the scene. An impulse is an instantaneous change to the body’s velocity. By applying an impulse to a body, SpriteKit pushes it in the direction specified (by an impulse vector). We’ve based the direction on the rotation of the firing cannon.
 
 Finally, we wrap creation, displaying, and firing of a balloon in a single function that we can call later.
 
*/

/// Applies an impulse based on the cannon’s rotation.
let fireBalloon: (SKSpriteNode, SKNode) -> Void = { balloon, cannon in
    let impulseMagnitude: CGFloat = 70.0
    
    let xComponent = cos(cannon.zRotation) * impulseMagnitude
    let yComponent = sin(cannon.zRotation) * impulseMagnitude
    let impulseVector = CGVector(dx: xComponent, dy: yComponent)
    
//    print("💥 Balloon fired at \(xComponent.rounded(.down)), \(yComponent.rounded(.down))")
    
    balloon.physicsBody!.applyImpulse(impulseVector)
}

@MainActor func fireCannon(cannon: SKNode) {
    let balloon = createRandomBalloon()
    
    displayBalloon(balloon, cannon)
    fireBalloon(balloon, cannon)
}

/*:
 
To offer easy access to the cannon nodes, we named these nodes explicitly in Xcode’s Level Designer. As a result, we don’t need special knowledge of the tree’s organization or of the cannon nodes’ location. The cannons could even be repositioned without requiring any code changes.
 
*/

// MARK: - Cannon Nodes

let leftBalloonCannon = scene?.childNode(withName: "//left_cannon")!
let rightBalloonCannon = scene?.childNode(withName: "//right_cannon")!

/*:
SpriteKit executes `SKAction` objects on nodes to change their position, rotation, scale—or in our case to wait (that is, do nothing for a specified amount of time). You can execute an action standalone, in a sequence, or in a group, and you can automatically repeat it an arbitrary number of times (or forever). But actions do not necessarily change a node’s properties—an action can simply be a block of code to be executed.
*/

// MARK: - Cannon Firing Schedule

let wait = SKAction.wait(forDuration: 1.0, withRange: 0.05)
let pause = SKAction.wait(forDuration: 0.55, withRange: 0.05)

let left = SKAction.run { fireCannon(cannon: leftBalloonCannon!) }
let right = SKAction.run { fireCannon(cannon: rightBalloonCannon!) }

let leftFire = SKAction.sequence([wait, left, pause, left, pause, left, wait])
let rightFire = SKAction.sequence([pause, right, pause, right, pause, right, wait])

/*:

To fire the cannons, we’ve created a sequence of actions that alternates between waiting and firing. We embed the fire/wait sequence in another action, one that is repeated forever.
 
- Experiment:
\
Increase the cannons’ fire interval, change the power with which the cannons fire, and then make the cannons fire without pauses.
 
To execute an action on a node, we simply call its runAction function and pass it the action of interest. Multiple actions can be executed simultaneously by a node, making it easy to implement complex, custom behavior in SpriteKit.
 
*/

leftBalloonCannon?.run(SKAction.repeatForever(leftFire))
rightBalloonCannon?.run(SKAction.repeatForever(rightFire))

/*:
 - Experiment:
\
The rotateByAngle class function of SKAction gives you an action that rotates the executing node by a number of degrees (in radians).
\
Create and run actions that make the cannons rotate while they are shooting.
 
### Popping Balloons
 
When two balloons collide, we want to make one of them explode. The explosion effect can be created with actions, so this time we’ve used actions to create an animation from textures and to remove the executing node from the scene. These two actions are combined into one sequence action that runs the two actions one after the other.
 
*/

/*:
Increase `impulse` or remove `pause` to create absolute balloon mayhem!
*/

// MARK: - Balloon Pop Animation

let balloonPop = (1...4).map {
    SKTexture(imageNamed: "explode_0\($0)")
}

let removeBalloonAction: SKAction = SKAction.sequence([
    SKAction.animate(with: balloonPop, timePerFrame: 1 / 30.0),
    SKAction.removeFromParent()
    ])

/*:
Even though collisions between physics bodies in a scene are automatically handled by SpriteKit, we must provide any logic that’s specific to our game. This includes defining which collisions should trigger contact notifications (contact testing). Earlier we ensured that all balloons are of the balloon category, but the ground is also a node and the category of a node defaults to all categories (`0xFFFFFFFF`).
*/

// MARK: - Contact Handling

let GroundCategory: UInt32 = 1 << 2
let ground = scene?.childNode(withName: "//ground")!
ground?.physicsBody!.categoryBitMask = GroundCategory

/*:

- Experiment:
\
Don’t assign the ground node a category (do this by commenting out the above three lines of code). What happens when balloons hit the ground now?
 

Contact notifications are handled by the physics world’s contact delegate. This is a class that conforms to the `SKPhysicsContactDelegate` protocol. Whenever collisions occur, the physics world notifies its contact delegate (an instance of a class conforming to the `SKPhysicsContactDelegate` protocol), so that we can react appropriately to the collision.
 
*/

/// Handles balloon-balloon collisions.
class PhysicsContactDelegate: NSObject, @preconcurrency SKPhysicsContactDelegate {

    // Swift 6 signature
    @MainActor
    internal func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask

        // Filter for balloon–balloon contacts only
        guard maskA & BalloonCategory != 0,
              maskB & BalloonCategory != 0 else { return }

        // 🔊 Debug cue — this line goes to Xcode’s console
        print("💥 Balloon popped at \(contact.contactPoint)")

        // Run the pop animation on *one* of the two nodes
        contact.bodyA.node?.run(removeBalloonAction)
    }
}



let contactDelegate = PhysicsContactDelegate()
scene?.physicsWorld.contactDelegate = contactDelegate



/*:
In the contact delegate’s `didBeginContact` function, we make use of the physics bodies’ category bit masks to ensure that only collisions between balloon nodes trigger explosions (that is, nodes of the `BalloonCategory`.). We use the bitwise AND operator to determine whether both bodies are of `BalloonCategory`, and run the action only if they are.


 - Experiment:
 \
Enable collisions between cannons and balloons.
Hint: The cannon nodes don’t have a physics body.
 

### And finally...
 
Playgrounds provide you with a way to experiment with your code that is interactive and fun. Playgrounds are also rewarding, because you learn by doing and by making mistakes in a controlled environment. More important, they challenge your curiosity and encourage you to play with and test your code while writing it.
Have fun! Change the code, experiment, and don’t be afraid to start over.

*/


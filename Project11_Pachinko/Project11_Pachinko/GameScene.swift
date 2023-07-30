//
//  GameScene.swift
//  Project11_Pachinko
//
//  Created by Petro Strynada on 25.07.2023.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    override func didMove(to view: SKView) {
        // Create a sprite node with the "background" image
        let backgroundNode = SKSpriteNode(imageNamed: "background")
        backgroundNode.position = CGPoint(x: 1133, y: 744)

        // Set the size of the background node to match the scene's size
        backgroundNode.size = self.size

        // Display a sprite without any blending effects applied to it
        backgroundNode.blendMode = .replace

        // Set the zPosition to a very low value to make sure it's displayed as the background
        backgroundNode.zPosition = -1

        // Add the background node to the scene
        addChild(backgroundNode)

        // Add physics borders for screen edges
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        physicsWorld.contactDelegate = self

        
        addLineOfBouncersAndSlots(count: 12, bouncerStep: 206, yCoordinate: 0)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let ball = SKSpriteNode(imageNamed: "ballRed")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        ball.position = location
        ball.name = "ball"
        addChild(ball)
    }

    func addBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }

    func makeSlot(at position: CGPoint, isGood: Bool) {

        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode

        if isGood {
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotBase.name = "good"
        } else {
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotBase.name = "bad"
        }

        slotBase.position = position
        slotGlow.position = position

        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false

        addChild(slotBase)
        addChild(slotGlow)

        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }

    func addLineOfBouncersAndSlots(count: Int, bouncerStep: Int, yCoordinate: Int ) {

        var bouncerCount = 0
        var slotCount = 1
        var slotStep = 0

        for _ in 1...count {
            addBouncer(at: CGPoint(x: bouncerStep * bouncerCount, y: yCoordinate))
            bouncerCount += 1
        }

        for _ in 1...count {

            slotStep = ((bouncerStep * slotCount) - (bouncerStep / 2))

            if slotCount % 2 != 0 {
                makeSlot(at: CGPoint(x: slotStep, y: yCoordinate), isGood: true)
            } else {
                makeSlot(at: CGPoint(x: slotStep, y: yCoordinate), isGood: false)
            }
            slotCount += 1
        }
    }

    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
        } else if object.name == "bad" {
            destroy(ball: ball)
        }
    }

    func destroy (ball: SKNode) {
        ball.removeFromParent()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
}

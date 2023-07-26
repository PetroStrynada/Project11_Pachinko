//
//  GameScene.swift
//  Project11_Pachinko
//
//  Created by Petro Strynada on 25.07.2023.
//

import SpriteKit

class GameScene: SKScene {

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

        
        addLineOfBouncersAndSlots(count: 12, bouncerStep: 206, yCoordinate: 0)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let ball = SKSpriteNode(imageNamed: "ballRed")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4
        ball.position = location
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
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
        }

        slotBase.position = position
        slotGlow.position = position

        addChild(slotBase)
        addChild(slotGlow)

        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }

    func addLineOfBouncersAndSlots(count: Int, bouncerStep: Int, yCoordinate: Int ) {

        var bouncerCount = 0
        var slotCount = 1
        var slotStep = bouncerStep / 2

        for _ in 1...count {
            addBouncer(at: CGPoint(x: bouncerStep * bouncerCount, y: yCoordinate))

            if slotCount % 2 != 0 {
                makeSlot(at: CGPoint(x: slotStep, y: yCoordinate), isGood: true)
            } else {
                makeSlot(at: CGPoint(x: slotStep, y: yCoordinate), isGood: false)
            }

            slotStep = ((bouncerStep * slotCount) - (bouncerStep / 2))
            bouncerCount += 1
            slotCount += 1
        }
    }


}

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

        
        addLineOfBouncers(count: 13, stepInPixels: 206, yCoordinateInPixel: 0)

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

    func addLineOfBouncers(count: Int, stepInPixels: Int, yCoordinateInPixel: Int ) {
        var total = 0
        for _ in 0...count {
            addBouncer(at: CGPoint(x: stepInPixels * total, y: yCoordinateInPixel))
            total += 1
        }
    }
}

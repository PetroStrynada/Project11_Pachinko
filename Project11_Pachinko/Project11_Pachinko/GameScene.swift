//
//  GameScene.swift
//  Project11_Pachinko
//
//  Created by Petro Strynada on 25.07.2023.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score \(score)"
        }
    }

    var editLabel: SKLabelNode!

    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }

    override func didMove(to view: SKView) {
        // Create a sprite node with the "background" image
        let backgroundNode = SKSpriteNode(imageNamed: "background")
        backgroundNode.position = CGPoint(x: 1133, y: 744)

        // Set the size of the background node to match the scene's size
        backgroundNode.size = self.size

        // Display a sprite without any blending effects applied to it
        backgroundNode.blendMode = .replace

        // Set the zPosition to a very low value to make sure it's displayed as the background
        backgroundNode.zPosition = -10

        // Add the background node to the scene
        addChild(backgroundNode)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 2222, y: 1420)
        addChild(scoreLabel)

        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: 44, y: 1420)
        addChild(editLabel)

        // Add physics borders for screen edges
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        physicsWorld.contactDelegate = self

        addLineOfBouncersAndSlots(count: 12, bouncerStep: 206, yCoordinate: 0)


    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let object = nodes(at: location)

        if object.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                //create a box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat(Int.random(in: 0...1)), green: CGFloat(Int.random(in: 0...1)), blue: CGFloat(Int.random(in: 0...1)), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location

                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)

            } else {
                let ball = SKSpriteNode(imageNamed: "ballRed")
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = location
                ball.name = "ball"
                addChild(ball)
            }
        }
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

        slotGlow.position = position
        slotGlow.zPosition = -9
        slotBase.position = position
        slotBase.zPosition = -8

        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false

        addChild(slotGlow)
        addChild(slotBase)

        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }


    func addBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.zPosition = -7
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }


    func addLineOfSlots(_ count: Int, _ bouncerStep: Int, _ yCoordinate: Int) {
        var slotCount = 1
        var slotStep = 0

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

    func addLineOfBouncers(_ count: Int, _ bouncerStep: Int, _ yCoordinate: Int) {
        var bouncerCount = 0

        for _ in 1...count {
            addBouncer(at: CGPoint(x: bouncerStep * bouncerCount, y: yCoordinate))
            bouncerCount += 1
        }
    }

    func addLineOfBouncersAndSlots(count: Int, bouncerStep: Int, yCoordinate: Int) {
        addLineOfSlots(count, bouncerStep, yCoordinate)
        addLineOfBouncers(count, bouncerStep, yCoordinate)
    }

    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball, withParticles: "SparkParticles")
            score += 1
        } else if object.name == "bad" {
            destroy(ball, withParticles: "FireParticles")
            score -= 1
        }
    }

    func destroy (_ ball: SKNode, withParticles fileNamed: String) {
        if let fireParticles = SKEmitterNode(fileNamed: fileNamed) {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }

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

//
//  GameScene.swift
//  Project11_Pachinko
//
//  Created by Petro Strynada on 25.07.2023.
//

//TODO: визначитись з тим чи віднимаються болзи коли потрапляємо в гарну лунку. коли болзи закінчилися дати алярт про це. зробити рандомний боксів для генерації рівнів.

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var editLabel: SKLabelNode!
    var startGameLabel: SKLabelNode!
    var generateLevelLabel: SKLabelNode!
    var clearLabel: SKLabelNode!

    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"

                generateLevelLabel.text = "Generate level"
                clearLabel.text = "Clear"
            } else {
                editLabel.text = "Edit"

                //TODO: do with isHidden
                generateLevelLabel.text = ""
                clearLabel.text = ""
            }
        }
    }

    var ballsLimitLabel: SKLabelNode!

    var ballsLimit = 100 {
        didSet {
            ballsLimitLabel.text = "You have \(ballsLimit) balls"
        }
    }

    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score \(score)"
        }
    }

    var ballsColor = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    var boxes = [SKNode]()
    var balls = [SKNode]()

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

        let fount = "Chalkduster"
        let yCoordinate = 1420


        startGameLabel = SKLabelNode(fontNamed: fount)
        startGameLabel.text = "Start game"
        startGameLabel.horizontalAlignmentMode = .left
        startGameLabel.position = CGPoint(x: 44, y: yCoordinate)
        addChild(startGameLabel)

        editLabel = SKLabelNode(fontNamed: fount)
        editLabel.text = "Edit"
        editLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: 344, y: yCoordinate)
        addChild(editLabel)

        generateLevelLabel = SKLabelNode(fontNamed: fount)
        //TODO: do with isHidden
        generateLevelLabel.text = ""
        generateLevelLabel.horizontalAlignmentMode = .left
        generateLevelLabel.position = CGPoint(x: 494, y: yCoordinate)
        addChild(generateLevelLabel)

        clearLabel = SKLabelNode(fontNamed: fount)
        //TODO: do with isHidden
        clearLabel.text = ""
        clearLabel.horizontalAlignmentMode = .left
        clearLabel.position = CGPoint(x: 844, y: yCoordinate)
        addChild(clearLabel)

        ballsLimitLabel = SKLabelNode(fontNamed: fount)
        ballsLimitLabel.text = "You have \(ballsLimit) balls"
        ballsLimitLabel.horizontalAlignmentMode = .right
        ballsLimitLabel.position = CGPoint(x: 2022, y: yCoordinate)
        addChild(ballsLimitLabel)

        scoreLabel = SKLabelNode(fontNamed: fount)
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 2222, y: yCoordinate)
        addChild(scoreLabel)

        // Add physics borders for screen edges
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        physicsWorld.contactDelegate = self

        addLineOfBouncersAndSlots(count: 12, bouncerStep: 206, yCoordinate: 0)


    }

    @objc func newGame() {
        //TODO: field for balls number
        newGameAlert()
        score = 0
        
        generateLevel()
        startGameLabel.text = "Restart game"
    }


    func newGameAlert() {
        guard let viewController = self.view?.window?.rootViewController else { return }
        let ac = UIAlertController(title: "GAME OVER", message: "Your score: \(score)", preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            //guard let ballsNumber = ac?.textFields?[0].text else { return }
            guard let ballsNumberString = ac?.textFields?[0].text, let ballsNumber = Int(ballsNumberString) else { return }
            self?.ballsLimit = ballsNumber
        }

        ac.addAction(submitAction)
        viewController.present(ac, animated: true, completion: nil)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let object = nodes(at: location)

        guard !object.contains(startGameLabel) else { return newGame() }

        guard !object.contains(editLabel) else { return editingMode.toggle() }

        if editingMode {
            guard !object.contains(generateLevelLabel) else { return generateLevel() }
            guard !object.contains(clearLabel) else { return clear(withParticles: "SparkParticles") }
            addBox(at: location)
        } else {
            addBall(at: location)
        }
    }


    func generateLevel() {
        clear(withParticles: "No")
        for _ in 0...100 {
            addBox(at: CGPoint(x: CGFloat.random(in: 0...2266), y: CGFloat.random(in: 200...1288)))
        }
    }


    func clear(withParticles fileNamed: String) {
        for box in boxes {
            if let particles = SKEmitterNode(fileNamed: fileNamed) {
                particles.position = box.position
                addChild(particles)
            }
            box.removeFromParent()
        }
        for ball in balls {
            ball.removeFromParent()
        }
        boxes = []
        balls = []
    }


    func addBox(at location: CGPoint) {
        let size = CGSize(width: Int.random(in: 16...128), height: 16)
        let box = SKSpriteNode(color: UIColor(red: CGFloat(Int.random(in: 0...1)), green: CGFloat(Int.random(in: 0...1)), blue: CGFloat(Int.random(in: 0...1)), alpha: 1), size: size)
        box.zRotation = CGFloat.random(in: 0...3)
        box.position = location
        boxes.append(box)

        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        addChild(box)
    }


    func destroyBox (_ box: SKNode, withParticles fileNamed: String) {
        if let fireParticles = SKEmitterNode(fileNamed: fileNamed) {
            fireParticles.position = box.position
            addChild(fireParticles)
        }

        box.removeFromParent()
    }


    func addBall(at location: CGPoint) {
        guard let randomBall = ballsColor.randomElement() else { return }
        guard ballsLimit != 0 else { return youDoNotHaveBallsAlert() }
        let ball = SKSpriteNode(imageNamed: randomBall)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        ball.position = location
        ball.position.y = 1444
        ball.name = "ball"
        balls.append(ball)

        ballsLimit -= 1
        addChild(ball)
    }


    func youDoNotHaveBallsAlert() {
        guard let viewController = self.view?.window?.rootViewController else { return }
        let ac = UIAlertController(title: "You spend all your balls", message: "restart the game", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Submit", style: .default)
        ac.addAction(submitAction)
        viewController.present(ac, animated: true, completion: nil)
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
            destroyBall(ball, withParticles: "SparkParticles")
            score += 1
        } else if object.name == "bad" {
            destroyBall(ball, withParticles: "FireParticles")
            score -= 1
        }
    }


    func destroyBall (_ ball: SKNode, withParticles fileNamed: String) {
        if let particles = SKEmitterNode(fileNamed: fileNamed) {
            particles.position = ball.position
            addChild(particles)
        }

        ball.removeFromParent()
        //TODO: remove this ball from balls array
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

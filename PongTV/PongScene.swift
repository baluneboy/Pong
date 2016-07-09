//
//  PongScene.swift
//  PongTV
//
//  Created by Jesse Tayler on 12/9/15.
//  Copyright © 2015 OEI. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit

class PongScene: SKScene, SKPhysicsContactDelegate {
    
    let winScore = 5
    
    var magicWidth:CGFloat!

    enum ColliderType: UInt32 {
        case ballCategory = 0
        case cornerCategory = 1
        case paddleCategory = 2
        case newCategory = 4
    }

    var isPlaying: Bool = false

    var ballNode:SKSpriteNode!
    var p1PaddleNode:SKSpriteNode!
    var p2PaddleNode:SKSpriteNode!
    var p1ScoreNode:SKLabelNode!
    var p2ScoreNode:SKLabelNode!
    var gameOverNode:SKLabelNode!
    
    var p1PaddleTouch: UITouch!
    var p2PaddleTouch: UITouch!
    
    var p1Score: Int = 0
    var p2Score: Int = 0

    var timer: Timer!
    
    var wallSound: SKAction!
    var wallSound1: SKAction!
    var wallSound2: SKAction!
    var paddleSound: SKAction!
    var paddleSound1: SKAction!
    var paddleSound2: SKAction!
    var scoreSound: SKAction!
    var gameOverSound: SKAction!
    var serveSound: SKAction!
    
    //Why don't shaders work on TV?
    var tvShader = SKShader(fileNamed: "TVShader.fsh")

    convenience init(size: CGSize, controlStyle:String!) {
        self.init(size: size)

        magicWidth = size.width / 70
        setupPhysics()
        setupSoundsa()
        drawUI()
    }
    
    func marginWidth() -> CGFloat {
        var marginWidth:CGFloat = magicWidth * 2
        if UIDevice.current().userInterfaceIdiom == .tv {
            marginWidth = 88
        }
        return marginWidth
    }
    
    func drawUI() {
        
        //paddles
        let paddleWidth: CGFloat = magicWidth
        let paddleHeight: CGFloat = magicWidth * 8
        
        p1PaddleNode = SKSpriteNode.init(color: SKColor.white(), size: CGSize(width: paddleWidth, height: paddleHeight))
        p2PaddleNode = SKSpriteNode.init(color: SKColor.white(), size: CGSize(width: paddleWidth, height: paddleHeight))
        p1PaddleNode.physicsBody = SKPhysicsBody.init(rectangleOf: p1PaddleNode.size)
        p1PaddleNode.physicsBody!.categoryBitMask = ColliderType.paddleCategory.rawValue
        p2PaddleNode.physicsBody = SKPhysicsBody.init(rectangleOf: p2PaddleNode.size)
        p2PaddleNode.physicsBody!.categoryBitMask = ColliderType.paddleCategory.rawValue
        p1PaddleNode.physicsBody!.isDynamic = false
        p2PaddleNode.physicsBody!.isDynamic = false
        addChild(p1PaddleNode)
        addChild(p2PaddleNode)
        hidePaddles()
        
        //scores
        let fontSize: CGFloat = magicWidth * 6.8
        let font = "Pong Regular"

        p1ScoreNode = SKLabelNode.init(fontNamed: font)
        p2ScoreNode = SKLabelNode.init(fontNamed: font)
        p2ScoreNode.fontColor = SKColor.white()
        p1ScoreNode.fontColor = SKColor.white()
                
        p1ScoreNode.fontSize = fontSize
        p2ScoreNode.fontSize = fontSize
        p1ScoreNode.position = CGPoint(x: size.width * 0.38, y: size.height - fontSize * 1.35)
        p2ScoreNode.position = CGPoint(x: size.width * 0.62, y: size.height - fontSize * 1.35)
        addChild(p1ScoreNode)
        addChild(p2ScoreNode)
        
        //gameover
        gameOverNode = SKLabelNode.init(fontNamed: font)
        gameOverNode.fontColor = SKColor.white()
        gameOverNode.fontSize = fontSize
        gameOverNode.position = CGPoint(x: size.width / 2.0, y: size.height / 2.8)
        gameOverNode.text = "GAME OVER"
        addChild(gameOverNode)
        
        //        shader.magicWidth = 16.0
        
        if UIDevice.current().userInterfaceIdiom != .tv {
            p1PaddleNode.shader = tvShader
            p2PaddleNode.shader = tvShader
        }

//        gameOverNode!.blendMode = SKBlendMode.Multiply
//        gameOverNode!.colorBlendFactor = 1.0
//        
//        let effectNode = SKEffectNode()
//        effectNode.shader = tvShader
//        effectNode.shouldEnableEffects = true
//        effectNode.position = CGPointMake(size.width / 2.0, size.height / 3.0)
//        addChild(effectNode)
//        
//        effectNode.addChild(gameOverNode)
        
        
//        let textureView = SKView()
//        let texture = textureView.textureFromNode(gameOverNode)
//        texture!.filteringMode = .Linear
//
//        let spriteText = SKSpriteNode(texture: texture!)
//        //spriteText.position = put me someplace good;
//        spriteText.position = CGPointMake(size.width / 2.0, size.height / 3.0)
//
//        addChild(spriteText)

        
        
        //net
        let lineHeight: CGFloat = magicWidth
        
        let lines: Int = Int((size.height / (2 * lineHeight)))
        var position: CGPoint = CGPoint(x: size.width / 2.0, y: lineHeight * 1.5)
        for _ in 0...lines {
            let netNode: SKSpriteNode = SKSpriteNode.init(color: SKColor.white(), size: CGSize(width: lineHeight, height: lineHeight))
            netNode.shader = tvShader
            netNode.position = position
            position.y += 2 * lineHeight
            addChild(netNode)
        }
        
        drawScore()
        serveBall()
    }
    
    func setupSounds() {
        serveSound = SKAction.playSoundFileNamed("bedop.caf", waitForCompletion: false)
        gameOverSound = SKAction.playSoundFileNamed("gameover.caf", waitForCompletion: false)
        scoreSound = SKAction.playSoundFileNamed("bonk.caf", waitForCompletion: false)
        
        paddleSound2 = SKAction.playSoundFileNamed("bleep.caf", waitForCompletion: false)
        paddleSound1 = SKAction.playSoundFileNamed("bleep.caf", waitForCompletion: false)
        paddleSound = SKAction.playSoundFileNamed("bleep.caf", waitForCompletion: false)
        
        wallSound = SKAction.playSoundFileNamed("bip.caf", waitForCompletion: false)
        wallSound1 = SKAction.playSoundFileNamed("bip.caf", waitForCompletion: false)
        wallSound2 = SKAction.playSoundFileNamed("bip.caf", waitForCompletion: false)
    }
    
    func setupSoundsa() {
        serveSound = SKAction.playSoundFileNamed("0.caf", waitForCompletion: false)
        gameOverSound = SKAction.playSoundFileNamed("2.caf", waitForCompletion: false)
        scoreSound = SKAction.playSoundFileNamed("bonk.caf", waitForCompletion: false)
        
        paddleSound2 = SKAction.playSoundFileNamed("3.caf", waitForCompletion: false)
        paddleSound1 = SKAction.playSoundFileNamed("5.caf", waitForCompletion: false)
        paddleSound = SKAction.playSoundFileNamed("7.caf", waitForCompletion: false)
        
        wallSound = SKAction.playSoundFileNamed("6.caf", waitForCompletion: false)
        wallSound1 = SKAction.playSoundFileNamed("8.caf", waitForCompletion: false)
        wallSound2 = SKAction.playSoundFileNamed("9.caf", waitForCompletion: false)
    }
    
    func setupPhysics() {
        backgroundColor = SKColor.black()
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        physicsBody = SKPhysicsBody.init(edgeLoopFrom: frame)
        physicsBody!.categoryBitMask = ColliderType.cornerCategory.rawValue
        
        physicsBody!.isDynamic = false
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 1.0
    }
    
    override func didMove(to view: SKView) {
    }
    
    override func willMove(from view: SKView) {
        gameOver()
    }
    
    func serve() {
        run(serveSound)

        isPlaying = true
        gameOverNode.isHidden = true

        invalidateTimer()
        serveBall()
        
        timer = Timer.scheduledTimer(timeInterval: 3.8, target: self, selector: #selector(PongScene.accelerateBall), userInfo: nil, repeats: true)
    }
    
    func serveBall() {
        if ballNode != nil {
            ballNode.removeFromParent()
        }
        
        let ballRadius: CGFloat = magicWidth / 2
        
        ballNode = SKSpriteNode.init()
        ballNode.color = SKColor.white()
        if UIDevice.current().userInterfaceIdiom != .tv {
            ballNode.shader = tvShader
        }

        ballNode.size = CGSize(width: magicWidth, height: magicWidth)
        ballNode.physicsBody = SKPhysicsBody.init(circleOfRadius: ballRadius)
        ballNode.physicsBody!.categoryBitMask = ColliderType.ballCategory.rawValue
        ballNode.physicsBody!.contactTestBitMask = ColliderType.cornerCategory.rawValue | ColliderType.paddleCategory.rawValue
        ballNode.physicsBody!.linearDamping = 0.0
        ballNode.physicsBody!.angularDamping = 0.0
        ballNode.physicsBody!.restitution = 1.0
        ballNode.physicsBody!.isDynamic = true
        ballNode.physicsBody!.friction = 0.0
        ballNode.physicsBody!.allowsRotation = false
        ballNode.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        addChild(ballNode)
        
        let velocity = CGFloat(magicWidth) * CGFloat(20)
        let english = arc4random_uniform(UInt32(velocity * 2))
        var startingVelocityX: CGFloat = velocity
        let startingVelocityY: CGFloat = velocity - CGFloat(english)
        print("serve english \(english)")

        // serve direction
        if p1Score > p2Score {
            startingVelocityX = -startingVelocityX
        }
        ballNode.physicsBody!.velocity = CGVector(dx: startingVelocityX, dy: startingVelocityY)
    }
    
    func resetGame() {
        if ballNode != nil {
            ballNode.removeFromParent()
        }
        
        showPaddles()
        invalidateTimer()
        
        isPlaying = false
        gameOverNode.text = "GAME OVER"
        gameOverNode.isHidden = false

        p1Score = 0
        p2Score = 0
        
        drawScore()
    }
    
    func invalidateTimer() {
        if timer != nil {
            timer.invalidate()
        }
        timer = nil
    }
    
    func drawScore() {
        p1ScoreNode.text = "\(p1Score)"
        p2ScoreNode.text = "\(p2Score)"
    }
    
    func pointForPlayer(_ player: Int) {
        ballNode.physicsBody!.velocity = CGVector(dx: 0,dy: 0)

        switch player {
        case 1:
            p1Score += 1
        case 2:
            p2Score += 1
        default:
            break
        }
        
        if p1Score == winScore || p2Score == winScore {
            gameOver()
        } else {
            perform(#selector(PongScene.serve), with: self, afterDelay: 1.68)
        }
        
        drawScore()
    }
    
    func gameOver() {
        perform(#selector(SCNActionable.run(_:)), with: gameOverSound, afterDelay: 0.38)

        isPlaying = false
        gameOverNode.text = "GAME OVER"
        gameOverNode.isHidden = false
        
        invalidateTimer()
        serveBall()
        
        hidePaddles()
    }
    
    func restartGame() {
        if ballNode != nil {
            resetGame()
        }
        serve()
    }
    
    func accelerateBall() {
        if view?.isPaused == true {
            return
        }
        
        let velocity = 1.18 as CGFloat
        let velocityX: CGFloat = ballNode.physicsBody!.velocity.dx * velocity
        // english
        let english = CGFloat(arc4random_uniform(50))
        print("accelerate english \(english)")
        let velocityY: CGFloat = ballNode.physicsBody!.velocity.dy * velocity  + english
        ballNode.physicsBody!.velocity = CGVector(dx: velocityX, dy: velocityY)
    }
    
    // turn on and off paddles during attract-mode
    func showPaddles() {
        p1PaddleNode.position = CGPoint(x: p1PaddleNode.size.width + marginWidth(), y: frame.midY)
        p2PaddleNode.position = CGPoint(x: frame.maxX - p2PaddleNode.size.width - marginWidth(), y: frame.midY)
        p1PaddleNode.isHidden = false
        p2PaddleNode.isHidden = false
    }
    
    func hidePaddles() {
        p1PaddleNode.isHidden = true
        p2PaddleNode.isHidden = true
    }

    func movePadde(_ paddle:SKSpriteNode, previousLocation:CGPoint, newLocation:CGPoint) {
        let x: CGFloat = paddle.position.x
        var y: CGFloat = paddle.position.y + (newLocation.y - previousLocation.y) * 1.5
        let yMax: CGFloat = size.height - paddle.size.width / 2.0 - paddle.size.height / 2.0
        let yMin: CGFloat = paddle.size.width / 2.0 + paddle.size.height / 2.0
        
        if y > yMax {
            y = yMax
        } else if y < yMin {
            y = yMin
        }
        paddle.position = CGPoint(x: x, y: y)
    }
    
    func movePaddle1() {
        let newLocation: CGPoint = p1PaddleTouch.location(in: self)
        if newLocation.x > size.width / 2.0 {
            if UIDevice.current().userInterfaceIdiom != .tv {
                return
            }
        }
        let previousLocation: CGPoint = p1PaddleTouch.previousLocation(in: self)
        movePadde(p1PaddleNode, previousLocation: previousLocation, newLocation: newLocation)
    }
    
    func movePaddle2() {
        let newLocation: CGPoint = p2PaddleTouch.location(in: self)
        if newLocation.x < (size.width / 2.0) {
            if UIDevice.current().userInterfaceIdiom != .tv {
                return
            }
        }
        let previousLocation: CGPoint = p2PaddleTouch.previousLocation(in: self)
        movePadde(p2PaddleNode, previousLocation: previousLocation, newLocation: newLocation)

    }
    
    

    func didBegin(_ contact: SKPhysicsContact) {
        let english: CGFloat = CGFloat(arc4random_uniform(20))
        let dx: CGFloat = ballNode.physicsBody!.velocity.dx
        let dy: CGFloat = ballNode.physicsBody!.velocity.dy
        if isPlaying {
            var firstBody: SKPhysicsBody = SKPhysicsBody()
            var secondBody: SKPhysicsBody = SKPhysicsBody()
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if firstBody.categoryBitMask == ColliderType.ballCategory.rawValue && secondBody.categoryBitMask == ColliderType.cornerCategory.rawValue {
                if firstBody.node!.position.x <= firstBody.node!.frame.size.width + magicWidth {
                    print("ball scored on left")
                    pointForPlayer(2)
                    run(scoreSound)
                }
                else {
                    if firstBody.node!.position.x >= (size.width - firstBody.node!.frame.size.width - magicWidth) {
                        print("ball scored on right")
                        pointForPlayer(1)
                        run(scoreSound)
                    }
                    else {
                        print("ball bounced off wall")
                        switch Int(arc4random_uniform(3)) {
                        case 0:
                            run(wallSound)
                        case 1:
                            run(wallSound1)
                        case 2:
                            run(wallSound2)
                        default:
                            break
                        }
                    }
                }
            }
            else {
                //ball touched paddle
                //the english seems a bit off from the original 
                //game, can we make that better?
                if firstBody.categoryBitMask == ColliderType.ballCategory.rawValue && secondBody.categoryBitMask == ColliderType.paddleCategory.rawValue {
                    
                    let paddleNode = secondBody.node as! SKSpriteNode
                    
                    let paddleBottom: CGFloat = paddleNode.frame.origin.y
                    let hitPoint = ballNode.frame.origin.y + ballNode.frame.height / 2.0
                    
                    if hitPoint < paddleBottom + paddleNode.size.height / 3.0 {
                        print("ball hit paddle bottom")
                        print("bottom paddle english \(english)")
                        run(paddleSound1)
                        ballNode.physicsBody!.velocity = CGVector(dx: dx, dy: english-dy)
                    }
                    else if hitPoint > paddleBottom + paddleNode.size.height * 2.0 / 3.0 {
                        print("ball hit paddle top")
                        print("top paddle english \(english)")
                        run(paddleSound2)
                        ballNode.physicsBody!.velocity = CGVector(dx: dx, dy: english+dy)
                    }
                    else {
                        print("ball hit paddle center")
                        run(paddleSound)
                    }
                }
            }
        }
    }
    
    func playPause() {
        print("Play Pause")
        if view!.isPaused == true {
            view!.isPaused = false;
            gameOverNode.isHidden = true
            showPaddles()
        } else {
            view!.isPaused = true;
            gameOverNode.text = "PAUSE"
            gameOverNode.isHidden = false
            hidePaddles()
        }
        view!.setNeedsLayout()
    }
    #if os(tvOS)
    func processControllerDirection() {
        let gameVC = view!.window!.rootViewController as! GameViewController
        let direction = GameViewController.controllerDirection(gameVC)
        
        if direction().y > 0.0002 || direction().y < -0.0002 {
            let node = p1PaddleNode
            positionPaddle(node!, y: direction().y)
        }
    }
    #endif

    
    func positionPaddle(_ paddle:SKSpriteNode, y:Float) {
        let reverseDirection = y

        let vector = CGFloat(reverseDirection * 50)
        var calculatedY = paddle.position.y + (vector * -1)
        let max = 1000 as CGFloat
        let min = 100 as CGFloat
        if (calculatedY > max) { calculatedY = max }
        if (calculatedY < min) { calculatedY = min }
        
        let yPosition = CGFloat(calculatedY)
        paddle.position = CGPoint(x: paddle.position.x, y: yPosition)
    }
    func placePaddle(_ paddle:SKSpriteNode, y:Float) {
        let reverseDirection = y * -1
        let yPosition = CGFloat(reverseDirection * 420 + 540)
        paddle.position = CGPoint(x: paddle.position.x, y: yPosition)
    }
    
    override func update(_ currentTime: TimeInterval) {
        #if os(tvOS)
        processControllerDirection()
        #endif
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for item in presses {
            if item.type == .playPause {
                if isPlaying == true {
                    playPause()
                } else {
                    restartGame()
                }
            }
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for item in presses {
            if item.type == UIPressType.select ||
                item.type == UIPressType.playPause {
                if !isPlaying {
                    restartGame()
                }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlaying {
            for touch: UITouch in touches {

                if touch.tapCount == 2 {
                    restartGame()
                    return
                }
            
                let location: CGPoint = touch.location(in: self)
                if UIDevice.current().userInterfaceIdiom == .tv {
                    view!.isPaused = false;
                    p1PaddleTouch = touch
                    p2PaddleTouch = touch
                } else {
                    if p1PaddleTouch == nil && location.x < size.width / 2.0 {
                        p1PaddleTouch = touch
                    }
                    if p2PaddleTouch == nil && location.x > size.width / 2.0 {
                        p2PaddleTouch = touch
                    }
                }
            }
        } else {
            restartGame()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: UITouch in touches {
            if isPlaying {
                if p1PaddleTouch != nil && touch == p1PaddleTouch {
                    movePaddle1()
                }
                if p2PaddleTouch != nil && touch == p2PaddleTouch {
                    movePaddle2()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // end each touch separately
        for touch: UITouch in touches {
            if p1PaddleTouch != nil && touch == p1PaddleTouch {
                p1PaddleTouch = nil
            }
            if p2PaddleTouch != nil && touch == p2PaddleTouch {
                    p2PaddleTouch = nil
            }
        }
    }

}



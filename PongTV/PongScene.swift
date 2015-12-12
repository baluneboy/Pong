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
    
    let winScore = 24
    
    var magicWidth: CGFloat!

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

    var timer: NSTimer!
    
    var wallSound: SKAction!
    var wallSound1: SKAction!
    var wallSound2: SKAction!
    var paddleSound: SKAction!
    var paddleSound1: SKAction!
    var paddleSound2: SKAction!
    var scoreSound: SKAction!
    var gameOverSound: SKAction!
    var serveSound: SKAction!
    
    convenience init(size: CGSize, controlStyle:String!) {
        self.init(size: size)
        
        magicWidth = size.width / 70 // 72? 60 is up close and 80 is small looking
        
        setupPhysics()
        setupSoundsa()
        drawUI()
    }
    
    func drawUI() {
        var marginWidth:CGFloat = magicWidth * 2
        if UIDevice.currentDevice().userInterfaceIdiom == .TV {
            marginWidth = 88
        }
        
        //paddles
        let paddleWidth: CGFloat = magicWidth
        let paddleHeight: CGFloat = magicWidth * 8
        
        p1PaddleNode = SKSpriteNode.init(color: SKColor.whiteColor(), size: CGSizeMake(paddleWidth, paddleHeight))
        p2PaddleNode = SKSpriteNode.init(color: SKColor.whiteColor(), size: CGSizeMake(paddleWidth, paddleHeight))
        p1PaddleNode.position = CGPointMake(p1PaddleNode.size.width + marginWidth, CGRectGetMidY(frame))
        p2PaddleNode.position = CGPointMake(CGRectGetMaxX(frame) - p2PaddleNode.size.width - marginWidth, CGRectGetMidY(frame))
        p1PaddleNode.physicsBody = SKPhysicsBody.init(rectangleOfSize: p1PaddleNode.size)
        p1PaddleNode.physicsBody!.categoryBitMask = ColliderType.paddleCategory.rawValue
        p2PaddleNode.physicsBody = SKPhysicsBody.init(rectangleOfSize: p2PaddleNode.size)
        p2PaddleNode.physicsBody!.categoryBitMask = ColliderType.paddleCategory.rawValue
        p1PaddleNode.physicsBody!.dynamic = false
        p2PaddleNode.physicsBody!.dynamic = false
        addChild(p1PaddleNode)
        addChild(p2PaddleNode)
        
        //scores
        let fontSize: CGFloat = magicWidth * 6.8
        let font = "BitDust Two"

        p1ScoreNode = SKLabelNode.init(fontNamed: font)
        p2ScoreNode = SKLabelNode.init(fontNamed: font)
        p2ScoreNode.fontColor = SKColor.whiteColor()
        p1ScoreNode.fontColor = SKColor.whiteColor()
        p1ScoreNode.fontSize = fontSize
        p2ScoreNode.fontSize = fontSize
        p1ScoreNode.position = CGPointMake(size.width * 0.38, size.height - fontSize)
        p2ScoreNode.position = CGPointMake(size.width * 0.62, size.height - fontSize)
        addChild(p1ScoreNode)
        addChild(p2ScoreNode)
        
        //gameover
        gameOverNode = SKLabelNode.init(fontNamed: font)
        gameOverNode.fontColor = SKColor.whiteColor()
        gameOverNode.fontSize = fontSize
        gameOverNode.position = CGPointMake(size.width / 2.0, size.height / 3.0)
        gameOverNode.text = "GAME OVER"
        addChild(gameOverNode)
        
        //net
        let lineWidth: CGFloat = magicWidth
        let lineHeight: CGFloat = magicWidth
        
        let lines: Int = Int((size.height / (2 * lineHeight)))
        var position: CGPoint = CGPointMake(size.width / 2.0, lineHeight * 1.5)
        for var i = 0; i < lines; i++ {
            let netNode: SKSpriteNode = SKSpriteNode.init(color: SKColor.whiteColor(), size: CGSizeMake(lineWidth, lineHeight))
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
        backgroundColor = SKColor.blackColor()
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        physicsBody = SKPhysicsBody.init(edgeLoopFromRect: frame)
        physicsBody!.categoryBitMask = ColliderType.cornerCategory.rawValue
        
        physicsBody!.dynamic = false
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 1.0
    }
    
    override func willMoveFromView(view: SKView) {
        gameOver()
    }
    
    func serve() {
        runAction(serveSound)

        isPlaying = true
        gameOverNode.hidden = true

        invalidateTimer()
        serveBall()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "accelerateBall", userInfo: nil, repeats: true)
    }
    
    func serveBall() {
        if ballNode != nil {
            ballNode.removeFromParent()
        }
        
        let ballWidth: CGFloat = magicWidth
        let ballHeight: CGFloat = magicWidth
        let ballRadius: CGFloat = magicWidth / 2
        
        ballNode = SKSpriteNode.init()
        ballNode.color = SKColor.whiteColor()
        
        ballNode.size = CGSizeMake(ballWidth, ballHeight)
        ballNode.physicsBody = SKPhysicsBody.init(circleOfRadius: ballRadius)
        ballNode.physicsBody!.categoryBitMask = ColliderType.ballCategory.rawValue
        ballNode.physicsBody!.contactTestBitMask = ColliderType.cornerCategory.rawValue | ColliderType.paddleCategory.rawValue
        ballNode.physicsBody!.linearDamping = 0.0
        ballNode.physicsBody!.angularDamping = 0.0
        ballNode.physicsBody!.restitution = 1.0
        ballNode.physicsBody!.dynamic = true
        ballNode.physicsBody!.friction = 0.0
        ballNode.physicsBody!.allowsRotation = false
        ballNode.position = CGPointMake(size.width / 2.0, size.height / 2.0)
        addChild(ballNode)
        
        let velocity = CGFloat(magicWidth) * CGFloat(20)
        let english = arc4random_uniform(UInt32(velocity * 2))
        var startingVelocityX: CGFloat = velocity
        let startingVelocityY: CGFloat = velocity - CGFloat(english)
        
        // serve direction
        if p1Score > p2Score {
            startingVelocityX = -startingVelocityX
        }
        ballNode.physicsBody!.velocity = CGVectorMake(startingVelocityX, startingVelocityY)
    }
    
    func resetGame() {
        if ballNode != nil {
            ballNode.removeFromParent()
        }
        
        showPaddles()
        invalidateTimer()
        
        isPlaying = false
        gameOverNode.hidden = false

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
    
    func pointForPlayer(player: Int) {
        ballNode.physicsBody!.velocity = CGVectorMake(0,0)

        switch player {
        case 1:
            p1Score++
        case 2:
            p2Score++
        default:
            break
        }
        
        processPoint()
    }
    
    func processPoint() {
        if p1Score == winScore || p2Score == winScore {
            gameOver()
        } else {
            performSelector(Selector("serve"), withObject: self, afterDelay: 1.68)
        }
        
        drawScore()
    }
    
    func gameOver() {
        hidePaddles()
        
        performSelector(Selector("runAction:"), withObject: gameOverSound, afterDelay: 0.38)
        isPlaying = false
        gameOverNode.hidden = false
        invalidateTimer()
        serveBall()
    }
    
    func accelerateBall() {
        // and some random 'english'
        let velocity = 1.18 as CGFloat
        let velocityX: CGFloat = ballNode.physicsBody!.velocity.dx * velocity + CGFloat(arc4random_uniform(50) * UInt32(0.1))
        let velocityY: CGFloat = ballNode.physicsBody!.velocity.dy * velocity + CGFloat(arc4random_uniform(50) * UInt32(0.1))
        ballNode.physicsBody!.velocity = CGVectorMake(velocityX, velocityY)
    }
    
    // turn on and off paddles during attract-mode
    func showPaddles() {}
    func hidePaddles() {}

    func movePadde(paddle:SKSpriteNode, previousLocation:CGPoint, newLocation:CGPoint) {
        let x: CGFloat = paddle.position.x
        var y: CGFloat = paddle.position.y + (newLocation.y - previousLocation.y) * 1.5
        let yMax: CGFloat = size.height - paddle.size.width / 2.0 - paddle.size.height / 2.0
        let yMin: CGFloat = paddle.size.width / 2.0 + paddle.size.height / 2.0
        
        if y > yMax {
            y = yMax
        } else if y < yMin {
            y = yMin
        }
        paddle.position = CGPointMake(x, y)
    }
    
    func moveFirstPaddle() {
        let newLocation: CGPoint = p1PaddleTouch.locationInNode(self)
        if newLocation.x > size.width / 2.0 && UIDevice.currentDevice().userInterfaceIdiom != .TV {
            //finger is on the other player side
            return
        }
        let previousLocation: CGPoint = p1PaddleTouch.previousLocationInNode(self)
        movePadde(p1PaddleNode, previousLocation: previousLocation, newLocation: newLocation)
    }
    
    func moveSecondPaddle() {
        let newLocation: CGPoint = p2PaddleTouch.locationInNode(self)
        if newLocation.x < size.width / 2.0 && UIDevice.currentDevice().userInterfaceIdiom != .TV {
            //finger is on the other player side
            return
        }
        let previousLocation: CGPoint = p2PaddleTouch.previousLocationInNode(self)
        movePadde(p2PaddleNode, previousLocation: previousLocation, newLocation: newLocation)
    }

    func didBeginContact(contact: SKPhysicsContact) {
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
                    runAction(scoreSound)
                }
                else {
                    if firstBody.node!.position.x >= (size.width - firstBody.node!.frame.size.width - magicWidth) {
                        print("ball scored on right")
                        pointForPlayer(1)
                        runAction(scoreSound)
                    }
                    else {
                        print("ball bounced off wall")
                        switch Int(arc4random_uniform(3)) {
                        case 0:
                            runAction(wallSound)
                        case 1:
                            runAction(wallSound1)
                        case 2:
                            runAction(wallSound2)
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
                    
                    let dx: CGFloat = ballNode.physicsBody!.velocity.dx
                    let dy: CGFloat = ballNode.physicsBody!.velocity.dy

                    let paddleBottom: CGFloat = paddleNode.frame.origin.y
                    let hitPoint = ballNode.frame.origin.y + ballNode.frame.height / 2.0
                    let english: CGFloat = CGFloat(arc4random_uniform(20))
                    
                    if hitPoint < paddleBottom + paddleNode.size.height / 3.0 {
                        print("ball hit paddle bottom")
                        runAction(paddleSound1)
                        ballNode.physicsBody!.velocity = CGVectorMake(dx, english-dy)
                    }
                    else if hitPoint > paddleBottom + paddleNode.size.height * 2.0 / 3.0 {
                        print("ball hit paddle top")
                        runAction(paddleSound2)
                        ballNode.physicsBody!.velocity = CGVectorMake(dx, english+dy)
                    }
                    else {
                        print("ball hit paddle center")
                        runAction(paddleSound)
                    }
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isPlaying {
            for touch: UITouch in touches {
                if touch.tapCount == 2 {
                    restartGame()
                    return
                }
            
                let location: CGPoint = touch.locationInNode(self)
                if UIDevice.currentDevice().userInterfaceIdiom == .TV {
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
    
    func restartGame() {
        if ballNode != nil {
            resetGame()
        }
        serve()
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: UITouch in touches {
            if isPlaying {
                if p1PaddleTouch != nil && touch == p1PaddleTouch {
                    moveFirstPaddle()
                }
                if p2PaddleTouch != nil && touch == p2PaddleTouch {
                    moveSecondPaddle()
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
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



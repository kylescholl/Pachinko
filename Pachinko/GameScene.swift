//
//  GameScene.swift
//  Pachinko
//
//  Created by Kyle Scholl on 2/9/16.
//  Copyright (c) 2016 Patronus LLC. All rights reserved.
//

import SpriteKit

enum PhysicsCategory : UInt32 {
	case paddle  = 1
	case ball    = 2
	case brick   = 4
	case wall    = 8
	//case initialBall = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	// var score = Int()
	var scoreLabel: SKLabelNode!
	
	var score: Int = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	
	override func didMoveToView(view: SKView) {
		let xMid : CGFloat = CGRectGetMidX(self.frame)
		let yMid : CGFloat = CGRectGetMidY(self.frame)
		print("x: \(xMid) y: \(yMid)")
		
		let height : CGFloat = CGRectGetHeight(self.frame)
		let width  : CGFloat = CGRectGetWidth (self.frame)
		
		let background = SKSpriteNode(imageNamed: "background.jpg")
		background.position = CGPointMake(xMid, yMid)
		
		
		print("")
		print("background.size: \(background.size)")
		print("")
		
		
		//	let _size = frame.size
		let screenSize = UIScreen.mainScreen().bounds.size
		print("screen size: \(screenSize)")
		
		
		background.blendMode = .Replace
		background.zPosition = -1
		addChild(background)
		
		
		physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
		physicsWorld.contactDelegate = self
		
		
		makeSlotAt(CGPoint(x: xMid / 4.0,              y: 0), isGood: true)
		makeSlotAt(CGPoint(x: xMid - xMid / 4.0,       y: 0), isGood: false)
		makeSlotAt(CGPoint(x: xMid + xMid / 4.0,       y: 0), isGood: true)
		makeSlotAt(CGPoint(x: xMid * 2.0 - xMid / 4.0, y: 0), isGood: false)


		makeBouncerAt(CGPoint(x: 0,          y: 0))
		makeBouncerAt(CGPoint(x: xMid / 2.0, y: 0))
		makeBouncerAt(CGPoint(x: xMid,       y: 0))
		makeBouncerAt(CGPoint(x: xMid * 1.5, y: 0))
		makeBouncerAt(CGPoint(x: xMid * 2.0, y: 0))
		
		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.text = "Score: 0"
		scoreLabel.horizontalAlignmentMode = .Right
		scoreLabel.position = CGPoint(x: width - 50, y: height - 50)
		addChild(scoreLabel)
    }
	
	func makeBouncerAt(position: CGPoint) {
		let bouncer                  = SKSpriteNode(imageNamed: "bouncer")
		bouncer.position             = position
		bouncer.size                 = CGSizeMake(bouncer.size.width / 1.5, bouncer.size.height / 1.5)
		bouncer.physicsBody          = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
		bouncer.physicsBody!.contactTestBitMask = bouncer.physicsBody!.collisionBitMask
		bouncer.physicsBody!.dynamic = false
		addChild(bouncer)
	}
	
	func makeSlotAt(position: CGPoint, isGood: Bool) {
		var slotBase: SKSpriteNode
		var slotGlow: SKSpriteNode
		
		if isGood {
			slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
			slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
			slotBase.name = "good"
		} else {
			slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
			slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
			slotBase.name = "bad"
		}
		
		slotBase.size     = CGSizeMake(slotBase.size.width / 1.5, slotBase.size.height / 1.5)
		slotGlow.size     = CGSizeMake(slotGlow.size.width / 1.5, slotGlow.size.height / 1.5)
		
		slotBase.position = position
		slotGlow.position = position
		
		slotBase.physicsBody = SKPhysicsBody(rectangleOfSize: slotBase.size)
		slotBase.physicsBody!.dynamic = false
		
		addChild(slotBase)
		addChild(slotGlow)
		
		let spin = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 10)
		let spinForever = SKAction.repeatActionForever(spin)
		slotGlow.runAction(spinForever)
	}
	
	func collisionBetweenBall(ball: SKNode, object: SKNode) {
		if object.name == "good" {
			destroyBall(ball)
		} else if object.name == "bad" {
			destroyBall(ball)
		}
	}
	
	func destroyBall(ball: SKNode) {
		ball.removeFromParent()
	}
	
	func didBeginContact(contact: SKPhysicsContact) {
		if contact.bodyA.node!.name == "ball" {
			collisionBetweenBall(contact.bodyA.node!, object: contact.bodyB.node!)
		} else if contact.bodyB.node!.name == "ball" {
			collisionBetweenBall(contact.bodyB.node!, object: contact.bodyA.node!)
		}
	}
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let touch = touches.first {
			let location                   = touch.locationInNode(self)
			let ball                       = SKSpriteNode(imageNamed: "ballRed")
			ball.size                      = CGSizeMake(ball.size.width / 1.5, ball.size.height / 1.5)
			ball.physicsBody               = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
			ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
			ball.physicsBody!.restitution  = 0.4
			ball.position                  = location
			ball.name                      = "ball"
			
			addChild(ball)
		}
    }
	
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}

//
//  GameScene.swift
//  Pachinko
//
//  Created by Kyle Scholl on 2/9/16.
//  Copyright (c) 2016 Patronus LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	var background  : SKSpriteNode!
	var scoreLabel  : SKLabelNode!
	var editLabel   : SKLabelNode!
	var removeLabel : SKLabelNode!
	
	var score: Int = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	
	var editingMode: Bool = false {
		didSet {
			if editingMode {
				editLabel.text   = "Done"
				removeMode       = false
				// true
			} else {
				editLabel.text = "Edit"
			}
		}
	}
	
	var removeMode: Bool = false {
		didSet {
			if removeMode {
				removeLabel.text = "Done"
				editingMode      = false
			} else {
				removeLabel.text = "Remove"
			}
		}
	}
	
	
	override func didMoveToView(view: SKView) {
		let xMid : CGFloat = CGRectGetMidX(self.frame)
		let yMid : CGFloat = CGRectGetMidY(self.frame)
		print("x: \(xMid) y: \(yMid)")
		
		let height : CGFloat = CGRectGetHeight(self.frame)
		let width  : CGFloat = CGRectGetWidth (self.frame)
		
		background = SKSpriteNode(imageNamed: "background.jpg")
		background.position = CGPointMake(xMid, yMid)
		background.blendMode = .Replace
		background.zPosition = -1
		addChild(background)
		
		let screenSize = UIScreen.mainScreen().bounds.size
		print("screen size: \(screenSize)")
		
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
		
		
		scoreLabel          = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.text     = "Score: \(score)"
		scoreLabel.fontSize = 20
		scoreLabel.horizontalAlignmentMode = .Right
		scoreLabel.position = CGPoint(x: width - 50, y: height - 50)
		addChild(scoreLabel)
		
		
		editLabel          = SKLabelNode(fontNamed: "Chalkduster")
		editLabel.text     = "Edit"
		editLabel.horizontalAlignmentMode = .Left
		editLabel.position = CGPoint(x: 50, y: height - 50)
		editLabel.fontSize = 20
		addChild(editLabel)
		
		
		removeLabel          = SKLabelNode(fontNamed: "Chalkduster")
		removeLabel.text     = "Remove"
		removeLabel.horizontalAlignmentMode = .Left
		removeLabel.position = CGPoint(x: editLabel.position.x * 4.0, y: height - 50)
		removeLabel.fontSize = 20
		addChild(removeLabel)
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
			score += 1
		} else if object.name == "bad" {
			destroyBall(ball)
			score -= 1
		}
	}
	
	
	func destroyBall(ball: SKNode) {
		ball.removeFromParent()
	}
	
	
	func didBeginContact(contact: SKPhysicsContact) {
		if contact.bodyA.node?.name == "ball" {
			collisionBetweenBall(contact.bodyA.node!, object: contact.bodyB.node!)
		} else if contact.bodyB.node?.name == "ball" {
			collisionBetweenBall(contact.bodyB.node!, object: contact.bodyA.node!)
		}
	}
	
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let touch = touches.first {
			var box: SKSpriteNode!
			let location = touch.locationInNode(self)
			let nodes    = nodesAtPoint(location) as [SKNode]
			
			if nodes.contains(editLabel) {
				editingMode = !editingMode
				print(editingMode)
			} else if nodes.contains(removeLabel) {
				removeMode = !removeMode
				print(removeMode)
			} else {
				if editingMode {
					if #available(iOS 9.0, *) {
						let randomSize = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
						box = SKSpriteNode(color: RandomColor(), size: randomSize)
						box.zRotation = RandomCGFloat(min: 0, max: 3)
						box.position  = location
						box.physicsBody = SKPhysicsBody(rectangleOfSize: box.size)
						box.physicsBody!.dynamic = false
						box.name = "box"
						addChild(box)
					} else {
						// Fallback on earlier versions
						let randomSize = CGSize(width: RandomInt(min: 16, max: 128), height: 16)
						box = SKSpriteNode(color: RandomColor(), size: randomSize)
						box.zRotation = RandomCGFloat(min: 0, max: 3)
						box.position  = location
						box.physicsBody = SKPhysicsBody(rectangleOfSize: box.size)
						box.physicsBody!.dynamic = false
						box.name = "box"
						addChild(box)
					}
				} else if removeMode {
					let object = nodeAtPoint(location)
					if object.name == "box" {
						object.removeFromParent()
					} else {
						// Do nothing //
					}
				} else {
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
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
	}
}

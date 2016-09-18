//
//  Tony Keiser
//  MGD Term 1609
//  KeiserTony_IAD
//

import SpriteKit
import AVFoundation
import Firebase

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Global Variable(s)
    var player:SKSpriteNode!
    var zombieA:SKSpriteNode!
    var zombieB:SKSpriteNode!
    var box:SKSpriteNode!
    var pauseButton:SKSpriteNode!
    var touchPoint:CGPoint = CGPointZero
    var scoreText:SKLabelNode!
    var score:Int = 0
    var speedA:CGFloat = 0.7
    var speedB:CGFloat = 0.4
    var multi = 1
    var multiTimer = NSTimer()
    var tripleShot = 0
    
    let firebase = FIRDatabase.database().reference()
    var emailString : String = ""
    var passString : String = ""
    
    // Bar Variable(s)
    var healthBar:SKSpriteNode!
    
    // Weapon Varible(s)
    var ammoText:SKLabelNode!
    let emptyClip = 0
    var shotsRemaining = 12 // Bullets Remaining in Clip
    var pistolClip = 12
    var maxAmmoPistol = 96
    
    // Category Mask(s)
    let bulletMask:UInt32 = 0x1 >> 0; // 1
    let zombieMask:UInt32 = 0x1 >> 1; // 2
    let playerMask:UInt32 = 0x1 >> 2; // 4

    override func didMoveToView(view: SKView) {
        // Setup Variables 
        emailString = NSUserDefaults.standardUserDefaults().stringForKey("email")!
        passString = NSUserDefaults.standardUserDefaults().stringForKey("password")!
        player = self.childNodeWithName("player") as! SKSpriteNode
        zombieA = self.childNodeWithName("zombie1") as! SKSpriteNode
        zombieB = self.childNodeWithName("zombie2") as! SKSpriteNode
        pauseButton = self.childNodeWithName("pauseButton") as! SKSpriteNode
        healthBar = self.childNodeWithName("healthBar") as! SKSpriteNode
        scoreText = self.childNodeWithName("ScoreText") as! SKLabelNode
        ammoText = self.childNodeWithName("AmmoText") as! SKLabelNode
        ammoText.text = "\(pistolClip) | \(maxAmmoPistol)"
        self.physicsWorld.contactDelegate = self
        // Player Collision should only be with a Zombie
        player.physicsBody?.collisionBitMask = zombieMask
        // HeathBar Width to fit scene size
        healthBar.size.width = size.width
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Set touchPoint to Touch
        touchPoint = touches.first!.locationInNode(self)
        
        // If Player is touched - Reload
        if player.containsPoint(touchPoint) {
            // Update Ammo Text
            if (maxAmmoPistol != emptyClip) {
                maxAmmoPistol-=pistolClip
                shotsRemaining = pistolClip
                ammoText.text = "\(shotsRemaining) | \(maxAmmoPistol)"
                // Set up Prepared Sounds
                let eject = SKAction.playSoundFileNamed("ejectmag.wav", waitForCompletion: true)
                let load  = SKAction.playSoundFileNamed("loadmag.wav", waitForCompletion: true)
                // Play Prepared Sounds on Touch
                player.runAction(SKAction.sequence([eject, load]))
            }
        }
        
        // If Zombie is touched - Noise
        if zombieA.containsPoint(touchPoint) {
            // Play Prepared Sound on Touch
            zombieA.runAction(SKAction.playSoundFileNamed("zombie1.wav", waitForCompletion: true))
        }
        
        // If Zombie is touched - Noise
        if zombieB.containsPoint(touchPoint) {
            // Play Prepared Sound on Touch
            zombieB.runAction(SKAction.playSoundFileNamed("zombie2.wav", waitForCompletion: true))
        }
        
        // If Box is touched - Get Reward
        if ((scene!.childNodeWithName("box")) != nil) {
            if box!.containsPoint(touchPoint) {
                // Claim Reward
                print("box Touched")
                reward()
                box.removeFromParent()
            }
        }
        
        
        // If NOT Player - Fire Weapon
        if !player.containsPoint(touchPoint) {
            // Update Ammo Text
            if (shotsRemaining != emptyClip) {
                shotsRemaining-=1
                ammoText.text = "\(shotsRemaining) | \(maxAmmoPistol)"
                // Create Bullet
                let bullet:SKSpriteNode = SKScene(fileNamed: "Bullet")!
                    .childNodeWithName("bullet")! as! SKSpriteNode
                bullet.removeFromParent()
                self.addChild(bullet)
                bullet.zPosition = 1
                bullet.position = player.position
                // Get Player Rotation & Set Bullet Speed & Line of Fire
                let playerAngle = Float(player.zRotation)
                let bulletSpeed = CGFloat(3.0)
                let velocityX:CGFloat = CGFloat(cosf(playerAngle)) * bulletSpeed
                let velocityY:CGFloat = CGFloat(sinf(playerAngle)) * bulletSpeed
                bullet.physicsBody?.applyImpulse(CGVectorMake(velocityX, velocityY))
                // Bullet Collision should only be with a Zombie
                bullet.physicsBody?.collisionBitMask = zombieMask
                bullet.physicsBody?.contactTestBitMask = bullet.physicsBody!.collisionBitMask
                
                if (tripleShot == 1) {
                    let bulletA:SKSpriteNode = SKScene(fileNamed: "Bullet")!
                        .childNodeWithName("bullet")! as! SKSpriteNode
                    bulletA.removeFromParent()
                    self.addChild(bulletA)
                    bulletA.zPosition = 1
                    bulletA.position = player.position
                    // Get Player Rotation & Set Bullet Speed & Line of Fire
                    let velocityXa:CGFloat = CGFloat(cosf(playerAngle * 1.15)) * bulletSpeed
                    let velocityYa:CGFloat = CGFloat(sinf(playerAngle * 1.15)) * bulletSpeed
                    bulletA.physicsBody?.applyImpulse(CGVectorMake(velocityXa, velocityYa))
                    // Bullet Collision should only be with a Zombie
                    bulletA.physicsBody?.collisionBitMask = zombieMask
                    bulletA.physicsBody?.contactTestBitMask = bulletA.physicsBody!.collisionBitMask
                
                    let bulletB:SKSpriteNode = SKScene(fileNamed: "Bullet")!
                        .childNodeWithName("bullet")! as! SKSpriteNode
                    bulletB.removeFromParent()
                    self.addChild(bulletB)
                    bulletB.zPosition = 1
                    bulletB.position = player.position
                    // Get Player Rotation & Set Bullet Speed & Line of Fire
                    let velocityXb:CGFloat = CGFloat(cosf(playerAngle * 0.85)) * bulletSpeed
                    let velocityYb:CGFloat = CGFloat(sinf(playerAngle * 0.85)) * bulletSpeed
                    bulletB.physicsBody?.applyImpulse(CGVectorMake(velocityXb, velocityYb))
                    // Bullet Collision should only be with a Zombie
                    bulletB.physicsBody?.collisionBitMask = zombieMask
                    bulletB.physicsBody?.contactTestBitMask = bulletB.physicsBody!.collisionBitMask
                }
                // Play Prepared Sound on Touch
                self.runAction(SKAction.playSoundFileNamed("gunfire.wav", waitForCompletion: false))
            } else {
                // Clip empty turn triple shot off
                tripleShot = 0
            }
        }
        
        // If Pause Button is touched
        if pauseButton.containsPoint(touchPoint) {
            let pauseOverlay:SKSpriteNode = SKScene(fileNamed: "Pause")!
                .childNodeWithName("PauseOverlay")! as! SKSpriteNode
            pauseOverlay.removeFromParent()
            self.addChild(pauseOverlay)
            pauseOverlay.zPosition = 10
            pauseOverlay.position.x = size.width / 2
            pauseOverlay.position.y = size.height / 2
        }
        
        if (scene!.view!.paused == true) {
            scene!.view!.paused = false
            scene!.childNodeWithName("PauseOverlay")?.removeFromParent()
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Set New touchPoint
        touchPoint = touches.first!.locationInNode(self)
    }
   
    override func update(currentTime: CFTimeInterval) {
        // Set Player's Rotation to Angle of touchPoint
        let touchPercent = touchPoint.x / size.width
        let playerAngle = touchPercent * 180 - 180
        player.zRotation = CGFloat(playerAngle) * CGFloat(M_PI) / 180.0
        
        // Set Zombies Destination
        let playerLocation = player.position
        let adx = playerLocation.x - zombieA.position.x
        let ady = playerLocation.y - zombieA.position.y
        let bdx = playerLocation.x - zombieB.position.x
        let bdy = playerLocation.y - zombieB.position.y
        let zAngleA:CGFloat = CGFloat(atan2(ady, adx))
        let zAngleB:CGFloat = CGFloat(atan2(bdy, bdx))
        // Face Zombie towards Player
        zombieA.zRotation = zAngleA
        zombieB.zRotation = zAngleB
        // Zombie Movement
        let ax:CGFloat = CGFloat(cos(zAngleA) * speedA)
        let ay:CGFloat = CGFloat(sin(zAngleA) * speedA)
        let bx:CGFloat = CGFloat(cos(zAngleB) * speedB)
        let by:CGFloat = CGFloat(sin(zAngleB) * speedB)
        // Zombie Apply Movement
        zombieA.position.x += ax
        zombieA.position.y += ay
        zombieB.position.x += bx
        zombieB.position.y += by
        
        for node in self.children {
            // Still updating this action
            if (node.name == "zombie1") {
                node.zRotation = zAngleA
                node.position.x += ax
                node.position.y += ay
            } else if (node.name == "zombie2") {
                node.zRotation = zAngleB
                node.position.x += bx
                node.position.y += by
            }
        }
        
        // If PauseOverlay Exists - Pause the Scene
        if (childNodeWithName("PauseOverlay") != nil) {
            scene!.view!.paused = true
        }
        
        // If WinLossOverlay Exists - Pause the Scene
        if (childNodeWithName("WinLossOverlay") != nil) {
            scene!.view!.paused = true
        }
        
        // If No More Zombies ( Game Victory )
        if (childNodeWithName("zombie1")==nil && childNodeWithName("zombie2")==nil) {
            let winLossOverlay:SKSpriteNode = SKScene(fileNamed: "WinLoss")!
                .childNodeWithName("WinLossOverlay")! as! SKSpriteNode
            winLossOverlay.removeFromParent()
            winLossOverlay.color = SKColor.blueColor()
            self.addChild(winLossOverlay)
            winLossOverlay.zPosition = 10
            winLossOverlay.position.x = size.width / 2
            winLossOverlay.position.y = size.height / 2
            let winLossText:SKLabelNode = SKScene(fileNamed: "WinLoss")!
                .childNodeWithName("WinLossText")! as! SKLabelNode
            winLossText.removeFromParent()
            self.addChild(winLossText)
            winLossText.text = "Victory"
            winLossText.zPosition = 11
            winLossText.position.x = size.width / 2
            winLossText.position.y = size.height / 2
            // Go to MainMenu
            let game:GameScene = GameScene(fileNamed: "MainMenu")!
            game.scaleMode = .AspectFit
            let sceneTransition:SKTransition = SKTransition.doorsCloseVerticalWithDuration(3.0)
            self.view?.presentScene(game, transition: sceneTransition)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
    
        // Bullet Touched Zombie
        if (contact.bodyA.categoryBitMask == bulletMask) {
            // Remove Bullet Node From View
            let bullet = contact.bodyA
            bullet.node?.removeFromParent()
            player.colorBlendFactor = 0.0
            // let zombie = contact.bodyB
            self.runAction(SKAction.playSoundFileNamed("zombie1.wav", waitForCompletion: true))
        } else if (contact.bodyB.categoryBitMask == bulletMask) {
            // Remove Bullet Node From View
            let bullet = contact.bodyB
            bullet.node?.removeFromParent()
            player.colorBlendFactor = 0.0
            // let zombie = contact.bodyA
            self.runAction(SKAction.playSoundFileNamed("zombie2.wav", waitForCompletion: true))
            // Zombie Die Animation
            let zdAtlas = SKTextureAtlas(named: "zombiedeath")
            
            let zd1  = zdAtlas.textureNamed("death01_0000.png")
            let zd2  = zdAtlas.textureNamed("death01_0001.png")
            let zd3  = zdAtlas.textureNamed("death01_0002.png")
            let zd4  = zdAtlas.textureNamed("death01_0003.png")
            let zd5  = zdAtlas.textureNamed("death01_0004.png")
            let zd6  = zdAtlas.textureNamed("death01_0005.png")
            let zd7  = zdAtlas.textureNamed("death01_0006.png")
            let zd8  = zdAtlas.textureNamed("death01_0007.png")
            let zd9  = zdAtlas.textureNamed("death01_0008.png")
            let zd10 = zdAtlas.textureNamed("death01_0009.png")
            let zd11 = zdAtlas.textureNamed("death01_0010.png")
            let zd12 = zdAtlas.textureNamed("death01_0011.png")
            let zd13 = zdAtlas.textureNamed("death01_0012.png")
            let zd14 = zdAtlas.textureNamed("death01_0013.png")
            let zd15 = zdAtlas.textureNamed("death01_0014.png")
            let zd16 = zdAtlas.textureNamed("death01_0015.png")
            let zd17 = zdAtlas.textureNamed("death01_0016.png")
            
            // ZombieA Death
            if (contact.bodyA.node!.name == "zombie1") {
                zombieA.physicsBody!.dynamic = false
                zombieA.runAction(SKAction.animateWithTextures([zd1, zd2, zd3, zd4, zd5, zd6, zd7,
                    zd8, zd9, zd10, zd11, zd12, zd13, zd14, zd15, zd16, zd17],
                    timePerFrame: 0.035, resize: false, restore: false)) {
                        self.zombieA.removeFromParent()
                        // Add point
                        self.score+=self.multi
                        self.scoreText.text = "\(self.score)"
                        self.spawnZombie("zombie1")
                        self.spawnZombie("zombie1")
                        let rollDice = arc4random_uniform(4)+1
                        if (rollDice == 1) {
                            self.spawnBox(self.zombieA.position)
                        }
                }
            }
            
            // ZombieB Death
            if (contact.bodyA.node!.name == "zombie2") {
                zombieB.physicsBody!.dynamic = false
                zombieB.runAction(SKAction.animateWithTextures([zd1, zd2, zd3, zd4, zd5, zd6, zd7,
                    zd8, zd9, zd10, zd11, zd12, zd13, zd14, zd15, zd16, zd17],
                    timePerFrame: 0.035, resize: false, restore: false)) {
                        self.zombieB.removeFromParent()
                        // Add point
                        self.score+=1
                        self.scoreText.text = "\(self.score)"
                        self.spawnZombie("zombie2")
                        self.spawnZombie("zombie2")
                        let rollDice = arc4random_uniform(3)+1
                        if (rollDice == 1) {
                            self.spawnBox(self.zombieB.position)
                        }
                }
            }
        } else if (contact.bodyA.node!.name == "player" || contact.bodyB.node!.name == "player") {
            // Zombie Touched Human
            player.colorBlendFactor = 1.0
            self.runAction(SKAction.playSoundFileNamed("pain.wav", waitForCompletion: true))
            if (healthBar.size.width>0) {
                healthBar.size.width-=(size.width*0.5)
            } else {
                // Player Died ( Game Over )
                let winLossOverlay:SKSpriteNode = SKScene(fileNamed: "WinLoss")!
                    .childNodeWithName("WinLossOverlay")! as! SKSpriteNode
                winLossOverlay.removeFromParent()
                winLossOverlay.color = SKColor.redColor()
                self.addChild(winLossOverlay)
                winLossOverlay.zPosition = 10
                winLossOverlay.position.x = size.width / 2
                winLossOverlay.position.y = size.height / 2
                let winLossText:SKLabelNode = SKScene(fileNamed: "WinLoss")!
                    .childNodeWithName("WinLossText")! as! SKLabelNode
                winLossText.removeFromParent()
                self.addChild(winLossText)
                winLossText.text = "GAME OVER"
                winLossText.zPosition = 11
                winLossText.position.x = size.width / 2
                winLossText.position.y = size.height / 2
                
                // Save Score and Update Highscore if needed
                let scores = NSUserDefaults.standardUserDefaults()
                if (score >= scores.integerForKey("high")) {
                    scores.setValue(score, forKey: "high")
                } else if (scores.integerForKey("high")==0) {
                    scores.setValue(0, forKey: "high")
                }
                scores.setValue(score, forKey: "last")
                scores.synchronize()
                // Save Score to Onlie Database
                updateScore(emailString, password: passString, newScore: score)
                
                // Go to MainMenu
                let game:GameScene = GameScene(fileNamed: "MainMenu")!
                game.scaleMode = .AspectFit
                let sceneTransition:SKTransition = SKTransition.doorsCloseVerticalWithDuration(3.0)
                self.view?.presentScene(game, transition: sceneTransition)

            }
        }
    }
    
    func spawnZombie(zombie: String) {
        // Spawn Zombie After Point
        var sceneName = ""
        if (zombie == "zombie1") {
            sceneName = "NewZombie1"
            speedA*=1.07 // Increase Speed
        } else {
            sceneName = "NewZombie2"
            speedB*=1.04 // Increase Speed
        }
        let zombieSprite:SKSpriteNode = SKScene(fileNamed: sceneName)!
            .childNodeWithName(zombie)! as! SKSpriteNode
        zombieSprite.removeFromParent()
        self.addChild(zombieSprite)
        zombieSprite.zPosition = 1
        zombieSprite.position = CGPoint(x: 500, y: 500)
        self.enumerateChildNodesWithName(zombie) {node,stop in
            self.zombieA = self.childNodeWithName("zombie1") as! SKSpriteNode
            self.zombieB = self.childNodeWithName("zombie2") as! SKSpriteNode
        }
    }
    
    func spawnBox(position: CGPoint) {
        // Spawn Box on zombies last position
        if (scene!.childNodeWithName("box") == nil) {
            // One box at a time
            let boxSprite:SKSpriteNode = SKScene(fileNamed: "Box")!
                .childNodeWithName("box")! as! SKSpriteNode
            boxSprite.removeFromParent()
            self.addChild(boxSprite)
            boxSprite.zPosition = 1
            boxSprite.position = position
            box = self.childNodeWithName("box") as! SKSpriteNode
        } else {
            box.removeFromParent()
        }
    }

    func reward() {
        let randomNumber = arc4random_uniform(15)+1; // +1 to prevent 0
        if (randomNumber == 6) {
            // Give health
            healthBar.size.width = size.width
            print("health given")
        }
        if (randomNumber == 9) {
            // Give ammo
            maxAmmoPistol+=36
            print("ammo given")
        }
        if (randomNumber == 13) {
            // Give triple shot
            tripleShot = 1
            ammoText.text = "\(pistolClip) | \(maxAmmoPistol)"
            print("triple given")
        }
        if (randomNumber == 10) {
            // Give extended clip
            print("extended given")
            shotsRemaining = 30
            ammoText.text = "\(shotsRemaining) | \(maxAmmoPistol)"
        }
        if (randomNumber == 15) {
            // Give Multiplier
            print("multipler given")
            if (multi==1) {
                multi = 2
                multiTimer = NSTimer()
                multiTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(12), target: self, selector: #selector(GameScene.multiply), userInfo: nil, repeats: false)
            }
        }
        // if health or ammo is low. Increase chance.
        if (healthBar.size.width<size.width) {
            if (randomNumber > 5) {
                // Give health
                healthBar.size.width = size.width
                print("health given +")
            }
        } else if (maxAmmoPistol<24) {
            if (randomNumber > 5) {
                // Give ammo
                maxAmmoPistol+=96
                print("ammo given +")
            }
        }
    }
    
    func multiply() {
        // Turn off multiply
        multiTimer.invalidate()
        multi = 1
        print("multiplter off")
    }

    // Update Score
    func updateScore (email: String, password: String, newScore: Int) -> Void {
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            if (error == nil) {
                let date = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
                let month = (date?.component(NSCalendarUnit.Month, fromDate: NSDate()))!
                let day = (date?.component(NSCalendarUnit.Day, fromDate: NSDate()))!
                let year = (date?.component(NSCalendarUnit.Year, fromDate: NSDate()))!
                let todayDate = "\(month)/\(day)/\(year)"
                self.firebase.child("users").child(user!.uid).observeEventType(.Value, withBlock: { (snapshot) in
                    let snapMonth = snapshot.value!.objectForKey("monthDate") as! String
                    let snapScore = snapshot.value!.objectForKey("dayScore") as! Int
                    let snapMonthScore = snapshot.value!.objectForKey("monthScore") as! Int
                    
                    // Check older score and update new score
                    if (snapScore < newScore) {
                        // Update Score && Date
                        self.firebase.child("users").child(user!.uid).setValue(["email": email, "monthScore":snapMonthScore, "dayScore":newScore,
                            "todayDate":todayDate, "monthDate":snapMonth])
                        if (snapMonthScore < newScore) {
                            // Update Score && Date
                            self.firebase.child("users").child(user!.uid).setValue(["email": email, "monthScore":newScore, "dayScore":newScore,
                                "todayDate":todayDate, "monthDate":todayDate])
                        }
                    }
                });
            }
        } // End Update Score
    }
}

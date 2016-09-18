//
//  Tony Keiser
//  MGD Term 1609
//  KeiserTony_IAD
//

import SpriteKit
import Firebase


class MainMenu: SKScene {
    // Global Variable(s)
    var playButton:SKSpriteNode!
    var howButton:SKSpriteNode!
    var creditsButton:SKSpriteNode!
    var loginButton:SKSpriteNode!
    var scoreButton:SKSpriteNode!
    var touchPoint:CGPoint = CGPointZero
    var highscore:SKLabelNode!
    var lastgame:SKLabelNode!
    var helloLable:SKLabelNode!
    var disableLogin:Bool = false
    
    let firebase = FIRDatabase.database().reference()
    
    override func didMoveToView(view: SKView) {
        
        helloLable = self.childNodeWithName("helloLable") as! SKLabelNode
        
        func loadUser() -> Bool {
            if ((NSUserDefaults.standardUserDefaults().valueForKey("email")) != nil) {
                return true
            }
            return false
        }

        // Login Action
        func loginAction (email: String, password: String) -> Void {
            FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
                if (error == nil) {
                    // Save Email & Passowrd
                    if (email != "" && password != "") {
                        NSUserDefaults.standardUserDefaults().setValue(email, forKeyPath: "email")
                        NSUserDefaults.standardUserDefaults().setValue(password, forKeyPath: "password")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    
                    // Get Valid User
                        self.firebase.child("users").child(user!.uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        // Get user value
                        let helloString = snapshot.value?.valueForKey("email") as! String
                        self.helloLable.text = helloString
                        self.loginButton.removeFromParent()
                        self.disableLogin = true
                    
                    })
                    }
                }
            }
        } // End Login Action
        
        // Check if User has a login
        if (loadUser()) {
            // Try Login
            loginAction(NSUserDefaults.standardUserDefaults().stringForKey("email")!,
                        password: NSUserDefaults.standardUserDefaults().stringForKey("password")!)
        }
        
        // Setup Variables
        playButton    = self.childNodeWithName("playButton") as! SKSpriteNode
        howButton     = self.childNodeWithName("howButton") as! SKSpriteNode
        creditsButton = self.childNodeWithName("creditsButton") as! SKSpriteNode
        loginButton = self.childNodeWithName("loginButton") as! SKSpriteNode
        scoreButton = self.childNodeWithName("scoreButton") as! SKSpriteNode
        highscore     = self.childNodeWithName("highscore") as! SKLabelNode
        lastgame     = self.childNodeWithName("lastgame") as! SKLabelNode
        
        let scores = NSUserDefaults.standardUserDefaults()
        highscore.text = "High Score: \(scores.integerForKey("high"))"
        lastgame.text = "Last Game: \(scores.integerForKey("last"))"
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Set touchPoint to Touch
        touchPoint = touches.first!.locationInNode(self)
        
        // If touch playButton -> Go to GameScene
        if playButton.containsPoint(touchPoint) {
            // Go to Scene
            let game:GameScene = GameScene(fileNamed: "GameScene")!
            game.scaleMode = .AspectFit
            let sceneTransition:SKTransition = SKTransition.doorsOpenVerticalWithDuration(3.0)
            self.view?.presentScene(game, transition: sceneTransition)
        }
        
        // If touch creditsButton -> Go to Howto
        if howButton.containsPoint(touchPoint) {
            // Go to Scene
            let game:GameScene = GameScene(fileNamed: "Howto")!
            game.scaleMode = .AspectFit
            let sceneTransition:SKTransition = SKTransition.doorsOpenVerticalWithDuration(3.0)
            self.view?.presentScene(game, transition: sceneTransition)
        }
        
        // If touch creditsButton -> Go to Credits
        if creditsButton.containsPoint(touchPoint) {
            // Go to Scene
            let game:GameScene = GameScene(fileNamed: "Credits")!
            game.scaleMode = .AspectFit
            let sceneTransition:SKTransition = SKTransition.doorsOpenVerticalWithDuration(3.0)
            self.view?.presentScene(game, transition: sceneTransition)
        }
        
        // If touch loginButton -> Go to Login
        if (!disableLogin) {
            if loginButton.containsPoint(touchPoint) {
                // Go to ViewController
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewControllerWithIdentifier("LoginScreen")
                self.view!.window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
            }
        }
        
        // If touch scoresButton -> Go to HighScores
        if scoreButton.containsPoint(touchPoint) {
            // Go to ViewController
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewControllerWithIdentifier("ScoresScreen")
            self.view!.window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
        }
    }
}

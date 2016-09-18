//
//  Tony Keiser
//  MGD Term 1609
//  KeiserTony_IAD
//

import SpriteKit

class Howto: SKScene {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Go to MainMenu
        let game:GameScene = GameScene(fileNamed: "MainMenu")!
        game.scaleMode = .AspectFit
        let sceneTransition:SKTransition = SKTransition.doorsCloseVerticalWithDuration(3.0)
        self.view?.presentScene(game, transition: sceneTransition)
    }
}

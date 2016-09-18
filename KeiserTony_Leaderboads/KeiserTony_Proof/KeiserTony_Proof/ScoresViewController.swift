//
//  Tony Keiser
//  MGD Term 1609
//  KeiserTony_IAD
//
import UIKit
import Foundation
import Firebase
import Social

class ScoresViewController: UIViewController {
    
    // Variables
    @IBOutlet weak var monthday : UISegmentedControl!
    let months : [String] = ["January", "Febuary", "March", "April", "May",
                             "June", "July", "August", "September", "October", "November", "December"]
    var players : [String: String] = [:]
    var daily : Bool = true // Daily Scores -> Default
    var todaysDate : String = ""
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var highScore : UILabel!
    // Top 3
    @IBOutlet weak var top1 : UILabel!
    @IBOutlet weak var top2 : UILabel!
    @IBOutlet weak var top3 : UILabel!
    @IBOutlet weak var score1 : UILabel!
    @IBOutlet weak var score2 : UILabel!
    @IBOutlet weak var score3 : UILabel!
    
    let firebase = FIRDatabase.database().reference()
    
    var emailString : String = ""
    var passString : String = ""
    
    // Actions
    @IBAction func buttonClick (sender : UIButton) {
        // On Click Action by Tag
        switch (sender.tag) {
        case 0:
            // Tag 0 == Cancel
            dismissViewControllerAnimated(true, completion: {});
            break;
        case 1:
            // Tag 1 == Share to Facebook
            let twitter = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
            let twitterString: String = "Can you beat my highscore this month? My Score was \(self.highScore.text!) on 'Dead Zone' get the app today!"
            twitter.setInitialText(twitterString)
            twitter.addImage(UIImage(named: "share.png"))
            self.presentViewController(twitter, animated: true, completion: nil)
            break;
        default:
            break;
        }
    }
    
    @IBAction func indexChanged(sender:UISegmentedControl) {
        switch monthday.selectedSegmentIndex {
        case 0:
            self.daily = false
            dateLabeler()
            players.removeAll()
            getScores(emailString, password: passString)
        case 1:
            self.daily = true
            dateLabeler()
            players.removeAll()
            getScores(emailString, password: passString)
        default:
            break;
        }
    }
    
    func loadUser() -> Bool {
        if ((NSUserDefaults.standardUserDefaults().valueForKey("email")) != nil) {
            return true
        }
        return false
    }

    override func viewDidLoad() {
        dateLabeler()
        // Check if User has a login
        if (loadUser()) {
            emailString = NSUserDefaults.standardUserDefaults().stringForKey("email")!
            passString = NSUserDefaults.standardUserDefaults().stringForKey("password")!
            // Try Login
            getScores(emailString, password: passString)
        }
    }
    
    func dateLabeler () {
        let date = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        let month = (date?.component(NSCalendarUnit.Month, fromDate: NSDate()))!
        let day = (date?.component(NSCalendarUnit.Day, fromDate: NSDate()))!
        let year = (date?.component(NSCalendarUnit.Year, fromDate: NSDate()))!
        
        if (daily) {
            dateLabel.text = "Today's Date: \(month)/\(day)/\(year)"
        } else {
            dateLabel.text = "For Month of \(months[month])"
        }
    }
    
    // Get Scores Action
    func getScores (email: String, password: String) -> Void {
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            if (error == nil) {
                // Save Email & Passowrd
                if (email != "" && password != "") {
                    let users = self.firebase.child("users");
                    users.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    let enumerator = snapshot.children
                    let date = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
                    let month = (date?.component(NSCalendarUnit.Month, fromDate: NSDate()))!
                    let day = (date?.component(NSCalendarUnit.Day, fromDate: NSDate()))!
                    let year = (date?.component(NSCalendarUnit.Year, fromDate: NSDate()))!
                    self.todaysDate = "\(month)/\(day)/\(year)"
                    while let snaps = enumerator.nextObject() as? FIRDataSnapshot {
                        // Add all users to Dictionary and Get top 3
                        if (self.daily) {
                            // Daily Scores
                            if (self.todaysDate == snaps.value!.valueForKey("todayDate") as! String) {
                                let scoreString = String(snaps.value!.valueForKey("dayScore") as! Int)
                                let userString = snaps.value!.valueForKey("email") as! String
                                self.players[scoreString] = userString
                            }
                        } else {
                            // Monthly Scores
                            let usersDate = snaps.value!.valueForKey("monthDate") as! String
                            let userDateArray = usersDate.componentsSeparatedByString("/")
                            let dateArray = self.todaysDate.componentsSeparatedByString("/")
                            
                            // Compare Month && Compare Year
                            if (dateArray[0] == userDateArray[0] && userDateArray[2] == dateArray[2]) {
                                let scoreString = String(snaps.value!.valueForKey("monthScore") as! Int)
                                let userString = snaps.value!.valueForKey("email") as! String
                                self.players[scoreString] = userString
                            }
                        }
                    }
                        // Split Date -> Array
                        let sortedKeys = Array(self.players.keys).sort(>)
                        // Display top 3
                        if (sortedKeys.count > 0) {
                            self.top1.text = self.players[sortedKeys[0]]
                            self.score1.text = sortedKeys[0]
                            self.top2.text = "Not Set"
                            self.score2.text = ""
                            self.top3.text = "Not Set"
                            self.score3.text = ""
                        }
                        if (sortedKeys.count > 1) {
                            self.top2.text = self.players[sortedKeys[1]]
                            self.score2.text = sortedKeys[1]
                            self.top3.text = "Not Set"
                            self.score3.text = ""
                        }
                        if (sortedKeys.count > 2) {
                            self.top3.text = self.players[sortedKeys[2]]
                            self.score3.text = sortedKeys[2]
                        }
                        self.firebase.child("users").child(user!.uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            // Get user value
                            self.highScore.text = String(snapshot.value!.valueForKey("monthScore") as! Int)
                        })
                    })
                }
            }
        }
    } // End Scores Action
}
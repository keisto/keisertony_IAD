//
//  Tony Keiser
//  MGD Term 1609
//  KeiserTony_IAD
//
import UIKit
import Foundation
import Firebase

class LoginViewController: UIViewController {
    
    // Variables
    @IBOutlet weak var email : UITextField!
    @IBOutlet weak var password : UITextField!
    @IBOutlet weak var signup : UIButton!
    @IBOutlet weak var login : UIButton!
    @IBOutlet weak var error: UILabel!
    
    let firebase = FIRDatabase.database().reference()
    
    var emailString : String = ""
    var passString : String = ""
    
    // Actions
    @IBAction func buttonClick (sender : UIButton) {
        // On Click Action by Tag
        switch (sender.tag) {
        case 0:
            // Tag 0 == Sign Up
            if (self.email.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" ||
                self.password.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "") {
                self.error.text! = "Please enter BOTH Email and Password."
            } else if (Int(self.password.text!) >= 6) {
                self.error.text! = "Password must be at LEAST 6 characters."
            } else if (!validEmail(self.email.text!)) {
                self.error.text! = "Invalid email format."
            } else {
                self.error.text! = ""
                signupAction(self.email.text!, password: self.password.text!)
            }
            break;
        case 1:
            // Tag 1 == Login
                if (self.email.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" ||
                    self.password.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "") {
                    self.error.text! = "Please enter BOTH Email and Password."
                } else {
                    self.error.text! = ""
                    loginAction(self.email.text!, password: self.password.text!)
                }
            
            break;
        case 2:
            // Tag 2 == Cancel
            dismissViewControllerAnimated(true, completion: {});
            break;
        default:
            break;
        }
    }
    
    func validEmail(checkEmail: String) -> Bool {
        let emailStyle = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
        return NSPredicate(format:"SELF MATCHES %@", emailStyle).evaluateWithObject(checkEmail)
    }
    
    // Sign Up Action
    func signupAction(email: String, password: String) -> Void {
        FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
            if (error == nil) {
                // User Signin Success
                self.error.text = "Sign Up Successful!"
                self.firebase.child("users").child(user!.uid).setValue(["email": email, "monthScore":0, "dayScore":0,
                    "todayDate":"0", "monthDate":"0"])
                // Save Email & Passowrd
                if (email != "" && password != "") {
                    NSUserDefaults.standardUserDefaults().setValue(email, forKeyPath: "email")
                    NSUserDefaults.standardUserDefaults().setValue(password, forKeyPath: "password")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    // Login
                    self.loginAction(self.email.text!, password: self.password.text!)
                }
            } else {
                // Something Went Wrong
                self.error.text = error?.localizedDescription
            }
        }
    } // End Sign Up Action
    
    override func viewDidLoad() {
        // Check if User has a login
        if (loadUser()) {
            emailString = NSUserDefaults.standardUserDefaults().stringForKey("email")!
            passString = NSUserDefaults.standardUserDefaults().stringForKey("password")!
            // Try Login
            loginAction(emailString, password: passString)
        }
    }
    
    // Login Action
    func loginAction (email: String, password: String) -> Void {
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            if (error == nil) {
                // Login Success
                self.error.text = "Login Successful!"
                // Save Email & Passowrd
                if (email != "" && password != "") {
                    NSUserDefaults.standardUserDefaults().setValue(email, forKeyPath: "email")
                    NSUserDefaults.standardUserDefaults().setValue(password, forKeyPath: "password")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    // Return to Main Menu
                    self.dismissViewControllerAnimated(true, completion: {});
                }
            } else {
                // Something Went Wrong
                self.error.text = error?.localizedDescription
            }
        }
    } // End Login Action
    
    func loadUser() -> Bool {
        if ((NSUserDefaults.standardUserDefaults().valueForKey("email")) != nil) {
            return true
        }
        return false
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return false
    }
    
}
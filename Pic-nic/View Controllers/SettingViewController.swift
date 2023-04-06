//
//  SettingViewController.swift
//  Pic-nic
//
//  Created by Chun-Lung Cheng on 4/3/23.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    
    let signOutSegueID = "signOutSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // To make the profile pic circular
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
    }
    
    // Return back to Home screen
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
    }
    
    // Sign out and return back to Login screen
    @IBAction func signoutButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: signOutSegueID, sender: nil)
        // Comment Out the code below for Beta!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//        do {
//            try Auth.auth().signOut()
//            performSegue(withIdentifier: signOutSegueID, sender: nil)
//        } catch {
//            print("Sign out error")
//        }
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

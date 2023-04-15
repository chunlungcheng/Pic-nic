//
//  LoginViewController.swift
//  Pic-nic
//
//  Created by Arjun Hegde on 3/6/23.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {
    static let identifier = "LoginViewController"
    
    @IBOutlet weak var LogInEmailTextField: UITextField!
    @IBOutlet weak var LogInPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
        LogInPasswordTextField.isSecureTextEntry = true
    }


    @IBAction func LogInButton(_ sender: UIButton) {
        guard let email = LogInEmailTextField.text else {return}
        guard let password = LogInPasswordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password){authResult, error in
            if let err = error {
                let controller = UIAlertController(title:"Error", message: "\(err.localizedDescription)", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(controller, animated: true)
            }
            else{
                print("Success")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                NotificationCenter.default.post(name: Notification.Name.updateTableView, object: "")
            }
        }
    }
}

//
//  HomeViewController.swift
//  Pic-nic
//
//  Created by Isaiah Suarez on 3/4/23.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    // TODO: Fill from Firebase
    let datasource = [("Evan Chan", "Zilker", "boots.jpg", "8:52pm", "2 likes", "Evan.jpg")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: LoginViewController.identifier) as? LoginViewController {
                loginVC.delegate = self
                present(loginVC, animated: true)
            }
           
        }
    }
}

extension HomeViewController: LoginViewControllerDelegate {
    func loginViewControllerLoggedInSuccessfully(loginViewController: UIViewController?) {
        loginViewController?.dismiss(animated: true)
    }
}
extension HomeViewController: UITableViewDelegate {
    
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseIdentifer, for: indexPath) as! PostCell
        let post = datasource[indexPath.row]
        cell.nameLabel.text = post.0
        cell.locationLabel.text = post.1
        cell.postImageView.image = UIImage(named: post.2)
        cell.profileImageView.image = UIImage(named: post.5)
        cell.timeLabel.text = post.3
        cell.likesLabel.text = post.4
        return cell
    }
    
}

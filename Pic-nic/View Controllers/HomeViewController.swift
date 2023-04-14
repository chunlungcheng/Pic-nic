//
//  HomeViewController.swift
//  Pic-nic
//
//  Created by Isaiah Suarez on 3/4/23.
//

import UIKit
import Firebase
import FirebaseFirestore

extension Notification.Name {
    static let updateTableView = Notification.Name("com.example.updateTableView")
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    let refreshControl = UIRefreshControl()
    
    var datasource = [Post]()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableview.delegate = self
        tableview.dataSource = self
        downloadPosts()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: Notification.Name.updateTableView, object: nil)
    }
    
    @objc func refreshData(_ sender: Any) {
        downloadPosts()
    }
    
    @objc func handleNotification(_ notification: Notification) {
        downloadPosts()
    }
    
    func downloadPosts() {
        let postsRef = db.collection("locations").document("Austin").collection("posts") // DO NOT CHANGE
        postsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            var posts = [Post]()
            
            for document in documents {
                let data = document.data()
                let date = data["date"] as? Timestamp
                let imageData = data["imageData"] as? Data
                let location = data["location"] as? String ?? ""
                let userID = data["userID"] as? String ?? ""
                
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    posts.append(Post(date: date, image: image, location: location, userID: userID))
                }
            }
            
            // Do something with the users array
            print(posts)
            self.datasource = posts
            self.datasource = self.datasource.sorted { $0.date?.dateValue() ?? Date.now  > $1.date?.dateValue() ?? Date.now}
            self.refreshControl.endRefreshing()
            self.tableview.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: LoginViewController.identifier) as? LoginViewController {
                loginVC.delegate = self
                present(loginVC, animated: true)
            }
        } else {
            print(Auth.auth().currentUser?.email)
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
        cell.nameLabel.text = "Name"
        cell.locationLabel.text = "Austin"
        cell.postImageView.image = post.image
//        cell.profileImageView.image = UIImage(named: post.5)
        
        // Format date
       
        cell.timeLabel.text = dateString(date: post.date?.dateValue() ?? Date.now)
        
        cell.likesLabel.text = "likes"
        return cell
    }
    
    func dateString(date: Date) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.day, .hour, .minute]
        return (formatter.string(from: date, to: Date.now) ?? "unknown") + " ago"
    }
    
}

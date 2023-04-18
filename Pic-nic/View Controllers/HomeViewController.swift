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
        tableview.allowsSelection = false
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
                let likes = data["likes"] as? Int ?? 0
                let likeBy = data["likeBy"] as? [String] ?? [String]()
                let documentID = document.documentID
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    posts.append(Post(date: date, image: image, location: location, userID: userID, documentID: documentID, likeBy: likeBy))
                }
            }
            self.datasource = posts
            self.datasource = self.datasource.sorted { $0.date?.dateValue() ?? Date.now  > $1.date?.dateValue() ?? Date.now}
            self.refreshControl.endRefreshing()
            self.tableview.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

        cell.locationLabel.text = "Austin"
        cell.postImageView.image = post.image
        
        // Format date
        cell.timeLabel.text = dateString(date: post.date?.dateValue() ?? Date.now)
        
        // set likes
        cell.likesLabel.text = "\(post.likeBy.count) likes"
        
        if self.datasource[indexPath.row].likeBy.contains(Auth.auth().currentUser!.uid){
            cell.likesButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            cell.likesButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        cell.likesButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        
        guard post.userName == nil else {
            // We've previosuly downloaded this
            cell.profileImageView.image = post.profilePicture
            cell.nameLabel.text = post.userName
            return cell
        }
        
        let docRef = db.collection("users").document(post.userID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                // set name
                let firstname = data?["firstName"] as? String ?? ""
                let lastname = data?["lastName"] as? String ?? ""
                let name = firstname + " " + lastname
                self.datasource[indexPath.row].userName = name
                // set profile picture
                if let imageData = data?["profilePicture"] as? Data {
                    if imageData.count != 0 {
                        // Create an image from the data
                        let image = UIImage(data: imageData)
                        let resizedImage = image!.resizeImage(targetSize: CGSize(width: 40, height: 40))
                        // Use the image as needed
                        self.datasource[indexPath.row].profilePicture = resizedImage
                    }
                    self.tableview.reloadRows(at: [indexPath], with: .automatic)
                } else {
                    print("Invalid image")
                }
            } else {
                print("Document does not exist")
            }
        }
      
        return cell
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview?.superview as? PostCell, let indexPath = tableview.indexPath(for: cell) else { return }
        print("like button tapped")
        let post = datasource[indexPath.row]
        let currentUserID = Auth.auth().currentUser?.uid ?? ""
        let docRef = db.collection("locations").document("Austin").collection("posts").document(post.documentID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                // Handle the user data here
                let likeBy = data?["likeBy"] as? [String] ?? [String]()
                let hasLiked = likeBy.contains(currentUserID)
                
                
                if hasLiked {
                    // Post was already liked by user, time to unlike it
                    let updatedLikeBy = post.likeBy.filter { $0 != currentUserID }
                    docRef.updateData(["likeBy": updatedLikeBy]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            self.datasource[indexPath.row].likeBy = updatedLikeBy
                            cell.likesLabel.text = "\(self.datasource[indexPath.row].likeBy.count) likes"
                            sender.setImage(UIImage(systemName: "heart"), for: .normal)
                            
                        }
                    }
                } else {
                    // Post was not already liked by user, time to like it
                    let updatedLikeBy = post.likeBy + [currentUserID]
                    docRef.updateData(["likeBy": updatedLikeBy]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                            
                        } else {
                            self.datasource[indexPath.row].likeBy = updatedLikeBy
                            cell.likesLabel.text = "\(self.datasource[indexPath.row].likeBy.count) likes"
                            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func dateString(date: Date) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.day, .hour, .minute]
        return (formatter.string(from: date, to: Date.now) ?? "unknown") + " ago"
    }
    
}

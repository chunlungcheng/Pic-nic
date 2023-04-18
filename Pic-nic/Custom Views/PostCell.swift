//
//  PostCell.swift
//  Pic-nic
//
//  Created by Isaiah Suarez on 3/4/23.
//

import UIKit

class PostCell: UITableViewCell {
    static let reuseIdentifer = "PostCell"
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
}

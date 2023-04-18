//
//  Post.swift
//  Pic-nic
//
//  Created by Isaiah Suarez on 4/14/23.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Post {
    var date: Timestamp?
    var image: UIImage
    var location: String
    var userID: String
    var documentID: String
    var likeBy: [String]
    var userName: String? = nil
    var profilePicture: UIImage? = nil
}

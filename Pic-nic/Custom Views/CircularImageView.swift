//
//  CircularImageView.swift
//  Pic-nic
//
//  Created by Isaiah Suarez on 3/4/23.
//

import UIKit

/// Image View but clips bounds to make it a circle. Useful for profile pictures.
class CircularImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.width, frame.height) / 2.0
        layer.masksToBounds = true
    }
}

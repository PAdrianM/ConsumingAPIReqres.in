//
//  UserCell.swift
//  practiceConsumeAPI
//
//  Created by Andrea Hernandez on 1/24/24.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var userLanel: UILabel!
    @IBOutlet weak var lasNameLbale: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

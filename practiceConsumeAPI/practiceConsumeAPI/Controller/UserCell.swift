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
        
        // Configurar la imagen del avatar
        avatarImageView.layer.cornerRadius = 8
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Limpiar la imagen cuando la celda se reutiliza
        avatarImageView.image = nil
    }
}

//
//  CustomTableViewCell.swift
//  Imagination
//
//  Created by Star on 16/1/5.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var content: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.content.layer.cornerRadius = 3.0
        self.content.isUserInteractionEnabled = false
    }
}
//
//  PhraseTableViewCell.swift
//  LanguageReviser
//
//  Created by administrator on 24/03/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import UIKit

class PhraseTableViewCell: UITableViewCell {

    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var welshLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

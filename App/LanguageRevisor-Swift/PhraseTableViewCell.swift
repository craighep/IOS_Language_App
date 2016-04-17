/**
 PhraseTableViewCell.swift
 Language-Revisor
 
 Custom cell class for the table view holding all phrases in.
 Allows customisation of english and welsh labels, and the type and tags labels.
 
 Created by Craig Heptinstall on 10/03/2015.
 */

import UIKit

class PhraseTableViewCell: UITableViewCell {

    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var welshLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

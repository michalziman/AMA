//
//  PickerCell.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit

class PickerCell: UITableViewCell, UIPickerViewDataSource {
    static let pickerHeight:CGFloat = 218

    @IBOutlet weak var pickerView: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // all years between minimum movie production year and now, including
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - MovieFilterController.minimumProductionYear + 1
    }
}

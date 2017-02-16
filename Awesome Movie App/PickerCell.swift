//
//  PickerCell.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit

protocol PickerCellDelegate {
    func pickerCell(_ pickerCell:PickerCell, didSelectYear year:Int)
}

class PickerCell: UITableViewCell {
    static let pickerHeight:CGFloat = 218

    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerRangeMin = MovieFilterController.minimumProductionYear
    var pickerRangeMax = Calendar.current.component(.year, from: Date()) // now
    
    var delegate:PickerCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setYear(_ year:Int) {
        // set year
        let yearNormalized = year - pickerRangeMin
        pickerView.selectRow(yearNormalized, inComponent: 0, animated: false)
    }
}

extension PickerCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let rangeSize = pickerRangeMax - pickerRangeMin
        return rangeSize + 1 // to include both ends
    }
}

extension PickerCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return "\(row + pickerRangeMin)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // get year
        let resultYear = pickerRangeMin + row
        
        // notify delegate
        if let delegate = self.delegate {
            delegate.pickerCell(self, didSelectYear: resultYear)
        }
    }
}

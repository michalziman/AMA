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
        // set year and decade
        pickerView.selectRow(year % 10, inComponent: 1, animated: false)
        let yearNormalized = year - pickerRangeMin
        pickerView.selectRow(yearNormalized / 10, inComponent: 0, animated: false)
    }
}

extension PickerCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // picker is separated to components, to allow faster selecetion
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // second component is only for year-by-year selection, first for decade
        if component == 1 {
            return 10
        }
        let rangeNormalized = pickerRangeMax - pickerRangeMin
        return rangeNormalized/10 + 1
    }
}

extension PickerCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            return "\(row)"
        }
        return "\(row + pickerRangeMin/10)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // get year
        var resultYear = pickerRangeMin + pickerView.selectedRow(inComponent: 1) + 10 * pickerView.selectedRow(inComponent: 0)
        
        if resultYear > pickerRangeMax {
            self.setYear(pickerRangeMax)
            resultYear = pickerRangeMax
        }
        if resultYear < pickerRangeMin {
            self.setYear(pickerRangeMin)
            resultYear = pickerRangeMin
        }
        // notify delegate
        if let delegate = self.delegate {
            delegate.pickerCell(self, didSelectYear: resultYear)
        }
    }
}

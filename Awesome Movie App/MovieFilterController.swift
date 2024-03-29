//
//  MovieFilterController.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit

protocol MovieFilterDelegate {
    func movieFilter(_ movieFilter: MovieFilterController, didSelectMinYear minYear:Int, maxYear:Int)
}

class MovieFilterController: UITableViewController {
    static let minimumProductionYear = 1890
    
    var isShowingPickerForMinYear = false
    var isShowingPickerForMaxYear = false
    
    var minYear = MovieFilterController.minimumProductionYear
    var maxYear = Calendar.current.component(.year, from: Date()) // now
    var delegate:MovieFilterDelegate?

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if is showing picker, there is one more cell (picker)
        if isShowingPickerForMaxYear || isShowingPickerForMinYear {
            return 3
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // choose correct cell and customize: year for year cells and delegate + selection for picker
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MinYearCell", for: indexPath) as! YearCell
            cell.yearLabel.text = "\(minYear)"
            cell.yearLabel.textColor = isShowingPickerForMinYear ? UIView.appearance().tintColor : UIColor.darkGray
            return cell
        }
        if (!isShowingPickerForMinYear && indexPath.row == 1) || (isShowingPickerForMinYear && indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MaxYearCell", for: indexPath) as! YearCell
            cell.yearLabel.text = "\(maxYear)"
            cell.yearLabel.textColor = isShowingPickerForMaxYear ? UIView.appearance().tintColor : UIColor.darkGray
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath) as! PickerCell
        cell.delegate = self
        if isShowingPickerForMinYear {
            cell.pickerRangeMin = MovieFilterController.minimumProductionYear
            cell.pickerRangeMax = maxYear
        } else {
            cell.pickerRangeMin = minYear
            cell.pickerRangeMax = Calendar.current.component(.year, from: Date()) // now
        }
        cell.pickerView.reloadAllComponents()
        cell.setYear(isShowingPickerForMinYear ? minYear : maxYear)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // height for picker is different
        if (isShowingPickerForMinYear && indexPath.row == 1) || (isShowingPickerForMaxYear && indexPath.row == 2) {
            return PickerCell.pickerHeight
        }
        return self.tableView.rowHeight
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // difficult logic of showing and hiding pickers
        
        tableView.beginUpdates()
        if indexPath.row == 0 {
            if isShowingPickerForMinYear {
                // clicked min year to hide its picker
                isShowingPickerForMinYear = false
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
                tableView.endUpdates()
                return
            }
            
            if isShowingPickerForMaxYear {
                // clicked min year to hide max year picker and show min year picker
                isShowingPickerForMaxYear = false
                isShowingPickerForMinYear = true
                tableView.reloadRows(at: [indexPath, IndexPath(row: 1, section: 0)], with: .none)
                tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
                tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .middle)
                tableView.endUpdates()
                return
            }
            
            // clicked min year to show its picker (nothing shown before)
            isShowingPickerForMinYear = true
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
            tableView.endUpdates()
            return
        }
        
        if indexPath.row == 1 && !isShowingPickerForMinYear {
            if isShowingPickerForMaxYear {
                // clicked max year to hide its picker
                isShowingPickerForMaxYear = false
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .middle)
                tableView.endUpdates()
                return
            }
            
            // clicked max year to show its picker (nothing shown before)
            isShowingPickerForMaxYear = true
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .middle)
            tableView.endUpdates()
            return
        }
        
        if indexPath.row == 2 && isShowingPickerForMinYear {
            // clicked max year to hide min year picker and show max year picker
            isShowingPickerForMaxYear = true
            isShowingPickerForMinYear = false
            tableView.reloadRows(at: [indexPath, IndexPath(row: 0, section: 0)], with: .none)
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .middle)
            tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
            tableView.endUpdates()
            return
        }
        tableView.endUpdates()
    }
    
    @IBAction func resetFilter(_ sender: Any) {
        minYear = MovieFilterController.minimumProductionYear
        maxYear = Calendar.current.component(.year, from: Date()) // now
        
        // notify delegate
        if let delegate = self.delegate {
            delegate.movieFilter(self, didSelectMinYear: minYear, maxYear: maxYear)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension MovieFilterController: PickerCellDelegate {
    func pickerCell(_ pickerCell: PickerCell, didSelectYear year: Int) {
        // set year
        if isShowingPickerForMinYear {
            minYear = year
        } else if isShowingPickerForMaxYear {
            maxYear = year
        }
        // reload data to show the year set
        self.tableView.reloadData()
        
        // notify delegate
        if let delegate = self.delegate {
            delegate.movieFilter(self, didSelectMinYear: minYear, maxYear: maxYear)
        }
    }
}

//
//  SettingsViewController.swift
//  SampleApp
//
//   Created by Peeyush on 18/02/21.
//  Copyright © 2021 Peeyush. All rights reserved.
//

import UIKit

struct Preferences {
    static var currency = "eur"
    static var country = "FR"
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var currencyView: UIView!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!

    var isFromCurrency = false

    var currencyArray = [String]()
    var countryArray = [String]()

    var currencyStr = ""
    var countryStr = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
    }
    
    // MARK: UIButton action methods
    @IBAction func crossButtonAction(_ sender: UIButton) {
        self.currencyView.isHidden = true
    }
    @IBAction func saveButtonAction(_ sender: UIButton) {

    }
    @IBAction func currencyButtonAction(_ sender: UIButton) {
        self.isFromCurrency = true
        self.currencyView.isHidden = false
        self.settingsTableView.reloadData()
    }
    @IBAction func countryButtonAction(_ sender: UIButton) {
        self.isFromCurrency = false
        self.currencyView.isHidden = false
        self.settingsTableView.reloadData()
    }

}

// MARK: Helper methods
extension SettingsViewController {
    
    func initialMethod() {
        self.currencyView.isHidden = true
        let currencys = Locale.isoCurrencyCodes
        let countryS = Locale.isoRegionCodes
        self.currencyArray = currencys
        self.countryArray = countryS
    }
    
}

// MARK: UITableViewDelegate & UITableViewDataSource methods
extension SettingsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromCurrency {
            return self.currencyArray.count
        }else {
            return self.countryArray.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleLabelTableViewCell") as! SingleLabelTableViewCell
        
        if isFromCurrency {
            let currency = self.currencyArray[indexPath.row]
            cell.nameLabel.text = currency
        }else {
            let country = self.countryArray[indexPath.row]
            cell.nameLabel.text = country
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFromCurrency {
            Preferences.currency = self.currencyArray[indexPath.row]
            self.currencyButton.setTitle(Preferences.currency, for: .normal)
        }else {
            Preferences.country = self.countryArray[indexPath.row]
            self.countryButton.setTitle(Preferences.country, for: .normal)
        }
        self.currencyView.isHidden = true
    }
    
}

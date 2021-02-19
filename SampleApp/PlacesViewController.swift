//
//  PlacesViewController.swift
//  SampleApp
//
//   Created by Peeyush on 18/02/21.
//  Copyright © 2021 Peeyush. All rights reserved.
//

import UIKit

protocol PlaceDelegate {
    func dismissPlaceView(place : Dictionary<String, Any>, type : String)
}

class PlacesViewController: UIViewController {

    var delegate : PlaceDelegate?
    var screenType = ""
    
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var placesTableView: UITableView!

    var placesData = Array<Dictionary<String, Any>>()
    var filterdPlaces = Array<Dictionary<String, Any>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
    }
    
    // MARK: UIButton action methods
    @IBAction func crossButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: Helper methods
extension PlacesViewController {
    
    func initialMethod() {
        self.searchTextfield.becomeFirstResponder()
    }
    
}

// MARK: UITableViewDelegate & UITableViewDataSource methods
extension PlacesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterdPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlacesTableViewCell") as! PlacesTableViewCell
        
        let dict = self.filterdPlaces[indexPath.row]
        
        var placeString = ""
        if let name = dict["Name"] as? String {
            placeString = name
        }
        if let skyscannerCode = dict["SkyscannerCode"] as? String {
            placeString = placeString + " (\(skyscannerCode))"
        }
        cell.nameLabel.text = placeString
        if let countryName = dict["CountryName"] as? String {
            cell.countryNameLabel.text = countryName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.filterdPlaces[indexPath.row]

        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                if (self.delegate != nil) {
                    self.delegate?.dismissPlaceView(place: dict, type: self.screenType)
                }
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate methods
extension PlacesViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Put your key in predicate that is "Name"
        let seachText = textField.text! + string
        let searchPredicate = NSPredicate(format: "Name CONTAINS[C] %@", seachText)
        let arrayData = (self.placesData as NSArray).filtered(using: searchPredicate)
        self.filterdPlaces = (arrayData as? Array<Dictionary<String, Any>>)!
        print ("array = \(self.filterdPlaces)")

        self.placesTableView.reloadData()

        return true
       
    }
        
}

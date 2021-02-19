//
//  ViewController.swift
//  SampleApp
//
//   Created by Peeyush on 18/02/21.
//  Copyright © 2021 Peeyush. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var whereToButton: UIButton!
    @IBOutlet weak var flightTableView: UITableView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    var comp = NSDateComponents()

    var source = ""
    var destination = ""
    var departureDate = ""
    
    var quotes = Array<Dictionary<String,Any>>()
    var carriers = Array<Dictionary<String,Any>>()
    var places = Array<Dictionary<String,Any>>()
    var currencies = Array<Dictionary<String,Any>>()
    var routes = Array<Dictionary<String,Any>>()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
        self.dateView.isHidden = true
    }
    
    // MARK: UIButton action methods
    @IBAction func crossButtonAction(_ sender: UIButton) {
        self.locationView.isHidden = true
    }

    @IBAction func whereToButtonAction(_ sender: UIButton) {
        self.locationView.isHidden = false
    }
    
    @IBAction func fromButtonAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "PlacesViewController") as! PlacesViewController
        vc.delegate = self
        vc.placesData = self.places
        vc.screenType = "From"
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func toButtonAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "PlacesViewController") as! PlacesViewController
        vc.delegate = self
        vc.placesData = self.places
        vc.screenType = "To"
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func dateButtonAction(_ sender: UIButton) {
        self.dateView.isHidden = false
    }

    @IBAction func passengerButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        self.dateView.isHidden = true
        self.dateButton.setTitle(self.departureDate, for: .normal)
    }


    @IBAction func searchButtonAction(_ sender: UIButton) {
        self.locationView.isHidden = true
    }
    
    @IBAction func anyButtonAction(_ sender: UIButton) {
        self.fetchData()
    }
    
}

// MARK: Helper methods
extension ViewController {
    
    func initialMethod() {
        self.locationView.isHidden = true

        self.datePicker.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: UIControl.Event.valueChanged)
        self.datePicker.preferredDatePickerStyle = .automatic

        self.datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        self.datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
    }
    
    func serverToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let localDate = dateFormatter.date(from: date)

        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "HH:mm"
        
        let timeStr = dateFormatter1.string(from: localDate!)
        

        return timeStr
    }
    
    @objc func datePickerChanged(datePicker:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        
        let date = dateFormatter.string(from: datePicker.date)
        self.departureDate = date
    }
    
}

// MARK: Web services methods
extension ViewController {
    
    func fetchData() {
        
        let pCurrency = Preferences.currency
        let pCountry = Preferences.country

//        let url = "http://partners.api.skyscanner.net/apiservices/browseroutes/v1.0/\(pCountry)/\(pCurrency)/en-US/us/anywhere/anytime/anytime?apikey=prtl6749387986743898559646983194"
        let url = "http://partners.api.skyscanner.net/apiservices/browseroutes/v1.0/IN/INR/en-US/us/anywhere/anytime/anytime?apikey=prtl6749387986743898559646983194"

        let progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHud.mode = MBProgressHUDMode.indeterminate
        progressHud.label.text = "Loading..."
        
        Alamofire.request(url).responseJSON { (response) in
            progressHud.hide(animated: true)
            if response.result.isSuccess {
                
                guard let data = response.result.value as? Dictionary<String, Any> else {
                    print("Something went wrong.")
                    return
                }
                guard let quotesData = data["Quotes"] as? Array<Dictionary<String, Any>> else {
                    print("Quotes not found")
                    return
                }
                guard let carriersData = data["Carriers"] as? Array<Dictionary<String, Any>> else {
                    print("Carriers not found")
                    return
                }
                guard let placesData = data["Places"] as? Array<Dictionary<String, Any>> else {
                    print("Places not found")
                    return
                }
                guard let currenciesData = data["Currencies"] as? Array<Dictionary<String, Any>> else {
                    print("Currencies not found")
                    return
                }
                guard let routesData = data["Routes"] as? Array<Dictionary<String, Any>> else {
                    print("Routes not found")
                    return
                }
                self.quotes = quotesData
                self.carriers = carriersData
                self.places = placesData
                self.currencies = currenciesData
                self.routes = routesData

                let quotesArray = self.quotes.filter { $0["Direct"] as! Bool == true }

                self.quotes = quotesArray

                print(self.quotes)
                print(self.carriers)
                print(self.places)
                print(self.currencies)
                print(self.routes)
                
                self.flightTableView.reloadData()
            }else {
                print("there was an error")
            }
        }
                        
    }
    
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlightTableViewCell") as! FlightTableViewCell
        let quotesDict = self.quotes[indexPath.row]
        if let minPrice = quotesDict["MinPrice"] as? String {
            cell.priceLabel.text = "₹" + minPrice
        }else if let minPrice = quotesDict["MinPrice"] as? Int {
            cell.priceLabel.text = "₹\(minPrice)"
        }
        
        var timeString = ""
        
        if let outboundLegDict = quotesDict["OutboundLeg"] as? Dictionary<String, Any> {
            if let carrierIds = outboundLegDict["CarrierIds"] as? [Int] {
                let carrierId = carrierIds.first
                let carriersArray = self.carriers.filter { $0["CarrierId"] as? Int == carrierId }
                let carrier = carriersArray.first
                if let name = carrier?["Name"] as? String {
                    cell.flightLabel.text = name
                }

            }
            var placeStr = ""

            if let originId = outboundLegDict["OriginId"] as? Int {
                let placeArray = self.places.filter { $0["PlaceId"] as? Int == originId }
                let place = placeArray.first
                if let cityId = place?["CityId"] as? String {
                    placeStr = cityId
                }
            }
            if let destinationId = outboundLegDict["DestinationId"] as? Int {
                let placeArray = self.places.filter { $0["PlaceId"] as? Int == destinationId }
                let place = placeArray.first
                if let cityId = place?["CityId"] as? String {
                    placeStr = placeStr + "-" + cityId
                }
            }
            
            cell.placeLabel.text = placeStr

//            if let departureDate = outboundLegDict["DepartureDate"] as? String {
//
//                let departureTime = self.serverToLocal(date: departureDate)
//                timeString = departureTime
//            }

        }
        
        if let departureDate = quotesDict["QuoteDateTime"] as? String {
            
            let departureTime = self.serverToLocal(date: departureDate)
            timeString = departureTime
        }

        if let outboundLegDict = quotesDict["InboundLeg"] as? Dictionary<String, Any> {

            if let departureDate = outboundLegDict["DepartureDate"] as? String {
                
                let departureTime = self.serverToLocal(date: departureDate)
                timeString = timeString + " - " + departureTime
            }

        }
        cell.timeLabel.text = timeString

        return cell
    }
    
}

extension ViewController : PlaceDelegate {
    
    func dismissPlaceView(place: Dictionary<String, Any>, type: String) {
        print(place)

        var placeString = ""
        if let name = place["Name"] as? String {
            placeString = name
        }
        if let skyscannerCode = place["SkyscannerCode"] as? String {
            placeString = placeString + " (\(skyscannerCode))"
        }
        if type == "From" {
            self.fromButton.setTitle(placeString, for: .normal)
        }else if type == "To" {
            self.toButton.setTitle(placeString, for: .normal)
        }
        
    }
    
}

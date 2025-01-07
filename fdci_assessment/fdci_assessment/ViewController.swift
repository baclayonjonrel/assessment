//
//  ViewController.swift
//  fdci_assessment
//
//  Created by Jonrel Baclayon on 1/7/25.
//

import UIKit
import Combine

class ViewController: UIViewController, UITextFieldDelegate {
    
    var submitViewModel = SubmitViewModel()
    var countryViewModel = CountryViewModel()
    var cancellables = Set<AnyCancellable>()
    
    var activeTextField: UITextField?
    var selectedRegion: String?
    var dataForTable: [String] = []

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
    @IBOutlet weak var nameErrorLbl: UILabel!
    @IBOutlet weak var stateErrorLbl: UILabel!
    @IBOutlet weak var countryErrorLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryViewModel.fetchCountries()
        setupCountryPublishers()
        
        nameTextField.backgroundColor = UIColor.systemGray6
        stateTextField.backgroundColor = UIColor.systemGray6
        countryTextField.backgroundColor = UIColor.systemGray6
        setupPublishers()
        countryTextField.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        countryTextField.delegate = self
        stateTextField.delegate = self
        
        tableView.isHidden = true
        
        nameErrorLbl.isHidden = true
        stateErrorLbl.isHidden = true
        countryErrorLbl.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == stateTextField {
            activeTextField = stateTextField
            dataForTable = countryViewModel.region ?? []
            tableView.isHidden = false
        } else if textField == countryTextField {
            if stateTextField.text == "" {
                countryErrorLbl.text = "Please select a state first"
                countryErrorLbl.isHidden = false
                tableView.isHidden = true
            } else {
                activeTextField = countryTextField
                updateCountryData(searchText: "")
                countryErrorLbl.isHidden = true
                tableView.isHidden = false
            }
        }
        
        
        let tableViewY = textField.frame.origin.y + textField.frame.size.height + 10
        tableView.frame.origin.y = tableViewY
        tableView.reloadData()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == countryTextField else { return false }
        
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        updateCountryData(searchText: updatedText)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tableView.isHidden = true
        activeTextField = nil
    }
    
    func setupCountryPublishers() {
        countryViewModel.$state.sink { state in
            DispatchQueue.main.async {
                print("tableView state: \(state)")
                // handle state for tableview
                // add loading or placeholder
            }
        }.store(in: &cancellables)
        
        countryViewModel.$countries.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }.store(in: &cancellables)
    }

    func setupPublishers() {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: nameTextField)
            .map { ($0.object as! UITextField).text ?? "" }
            .assign(to: \.name, on: submitViewModel)
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: stateTextField)
            .map { ($0.object as! UITextField).text ?? "" }
            .assign(to: \.regionState, on: submitViewModel)
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: countryTextField)
            .map { ($0.object as! UITextField).text ?? "" }
            .assign(to: \.country, on: submitViewModel)
            .store(in: &cancellables)
        
        submitViewModel.isValidNamePublisher
            .sink { [weak self] isValid in
                if ((self?.submitViewModel.name.isEmpty) == false) {
                    self?.nameTextField.layer.cornerRadius = 5
                    self?.nameTextField.layer.borderWidth = 2.0
                    self?.nameTextField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.red.cgColor
                }
            }
            .store(in: &cancellables)
        
        submitViewModel.isValidStatePublisher
            .sink { [weak self] isValid in
                if ((self?.submitViewModel.regionState.isEmpty) == false) {
                    self?.stateTextField.layer.cornerRadius = 5
                    self?.stateTextField.layer.borderWidth = 2.0
                    self?.stateTextField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.red.cgColor
                }
            }
            .store(in: &cancellables)
        
        submitViewModel.isValidCountryPublisher
            .sink { [weak self] isValid in
                if ((self?.submitViewModel.country.isEmpty) == false) {
                    self?.countryTextField.layer.cornerRadius = 5
                    self?.countryTextField.layer.borderWidth = 2.0
                    self?.countryTextField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.red.cgColor
                }
                if ((self?.submitViewModel.regionState.isEmpty) == false) {
                    self?.stateTextField.layer.cornerRadius = 5
                    self?.stateTextField.layer.borderWidth = 2.0
                    self?.stateTextField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.red.cgColor
                }
            }
            .store(in: &cancellables)
        
        submitViewModel.$nameTextState
             .sink { [weak self] state in
                 self?.updateTextFieldAppearance(self?.nameTextField, for: state)
             }
             .store(in: &cancellables)
             
        submitViewModel.$countryTextState
             .sink { [weak self] state in
                 self?.updateTextFieldAppearance(self?.countryTextField, for: state)
             }
             .store(in: &cancellables)
             
        submitViewModel.$regionStateTextState
             .sink { [weak self] state in
                 self?.updateTextFieldAppearance(self?.stateTextField, for: state)
             }
             .store(in: &cancellables)
     }
         
     private func updateTextFieldAppearance(_ textField: UITextField?, for state: SubmitViewModel.ViewState) {
         guard let textField = textField else { return }
         if state == .invalid {
             textField.layer.borderColor = UIColor.red.cgColor
             textField.layer.borderWidth = 2.0
             if textField == stateTextField {
                 stateErrorLbl.isHidden = false
                 countryErrorLbl.isHidden = true
             } else {
                 stateErrorLbl.isHidden = true
                 countryErrorLbl.isHidden = false
             }
         } else {
             textField.layer.borderColor = UIColor.clear.cgColor
             stateErrorLbl.isHidden = true
             countryErrorLbl.isHidden = true
         }
     }
    
    private func updateCountryData(searchText: String) {
        if let region = selectedRegion {
            dataForTable = countryViewModel.searchCountries(by: searchText, in: region)
        } else {
            dataForTable = []
        }
        tableView.reloadData()
    }
    
    @IBAction func submitButtonPress(_ sender: Any) {
        if nameTextField.text == "" {
            nameErrorLbl.text = "Please enter your name"
            nameErrorLbl.isHidden = false
            nameTextField.layer.cornerRadius = 5
            nameTextField.layer.borderWidth = 2.0
            nameTextField.layer.borderColor = UIColor.red.cgColor
        } else {
            nameErrorLbl.isHidden = true
            nameTextField.layer.borderColor = UIColor.clear.cgColor
        }
        
        if stateTextField.text == "" {
            stateErrorLbl.text = "Please enter your name"
            stateErrorLbl.isHidden = false
            stateTextField.layer.cornerRadius = 5
            stateTextField.layer.borderWidth = 2.0
            stateTextField.layer.borderColor = UIColor.red.cgColor
        } else {
            stateErrorLbl.isHidden = true
            stateTextField.layer.borderColor = UIColor.clear.cgColor
        }
        
        if countryTextField.text == "" {
            countryErrorLbl.text = "Please enter your name"
            countryErrorLbl.isHidden = false
            countryTextField.layer.cornerRadius = 5
            countryTextField.layer.borderWidth = 2.0
            countryTextField.layer.borderColor = UIColor.red.cgColor
        } else {
            countryErrorLbl.isHidden = true
            countryTextField.layer.borderColor = UIColor.clear.cgColor
        }
        
    }
    
    @IBAction func clearButtonPress(_ sender: Any) {
        nameTextField.text = ""
        countryTextField.text = ""
        stateTextField.text = ""
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if activeTextField == stateTextField {
            let region = dataForTable[indexPath.row]
            stateTextField.text = region
            selectedRegion = region
        } else if activeTextField == countryTextField {
            let country = dataForTable[indexPath.row]
            countryTextField.text = country
        }
        countryTextField.resignFirstResponder()
        stateTextField.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataForTable.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = dataForTable[indexPath.row]
        return cell
    }
}

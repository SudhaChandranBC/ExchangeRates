//
//  ExchangeRateViewController.swift
//  ExchangeRates
//
//  Created by Chandran, Sudha on 18/03/21.
//

import UIKit

class ExchangeRateViewController: UIViewController  {
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let errorAlert = UIAlertController()
    var spinner = UIActivityIndicatorView(style: .large)
    var model: CurrencyModel = CurrencyModel()
    var searchedAmount: String = ""
    var selectedCurrency: Currency? {
        self.model.currencyList?[self.model.selectedCurrencyIndex]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActivityIndicator()
        spinner.startAnimating()
        errorAlert.title = "Error!"
        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in })
        errorAlert.addAction(ok)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        
        if self.model.currencyList == nil {
            if let currencies = defaults.object(forKey: "currencyList") as? Data, let loadedCurrencies = try? PropertyListDecoder().decode(Array<Currency>.self, from: currencies) as [Currency] {
                self.model.currencyList = loadedCurrencies
            } else {
                self.loadCurrencies()
            }
        }
        
        if self.model.convertedRates == nil {
            if let rates = defaults.object(forKey: "exchangeRates") as? Data, let loadedRates = try? PropertyListDecoder().decode(Array<ExchangeRate>.self, from: rates) as [ExchangeRate] {
                self.model.exchangeRates = loadedRates
                reloadData()
            } else {
                self.loadLiveExchangeRates()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "currencyList" {
            guard let controller = segue.destination as? CurrencyListTableViewController else { return }
            controller.parentVC = self
        }
        if segue.identifier == "currencyListFromIcon" {
            guard let controller = segue.destination as? CurrencyListTableViewController else { return }
            controller.parentVC = self
        }
    }
    
    func prepareActivityIndicator() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    func loadCurrencies() {
        self.model.loadCurrencyList(
            success: { [weak self] response in
                if let weakSelf = self {
                    if let currencies = weakSelf.model.currencyList {
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(currencies), forKey: "currencyList")
                    }
                    weakSelf.reloadData()
                }
            },
            failure: { [weak self] error in
                if let weakSelf = self {
                    if let error = error {
                        weakSelf.errorAlert.message = error.info
                        DispatchQueue.main.async(execute: {
                            weakSelf.present(weakSelf.errorAlert, animated: true)
                            weakSelf.spinner.stopAnimating()
                        })
                    }
                }
            }
        )
    }
    
    func loadLiveExchangeRates() {
        self.model.loadLiveExchangeRates(
            success: { [weak self] response in
                if let weakSelf = self {
                    if response != nil {
                        if let rates = weakSelf.model.exchangeRates {
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(rates), forKey: "exchangeRates")
                        }
                        weakSelf.spinner.stopAnimating()
                        weakSelf.reloadData()
                    }
                }
            },
            failure: { [weak self] error in
                if let weakSelf = self {
                    if let error = error {
                        weakSelf.errorAlert.message = error.info
                        DispatchQueue.main.async(execute: {
                            weakSelf.present(weakSelf.errorAlert, animated: true)
                            weakSelf.spinner.stopAnimating()
                        })
                    }
                }
            })
    }
    
    func reloadData() {
        spinner.stopAnimating()
        if let text = textField.text {
            self.searchedAmount = text
        }
        self.model.convertAmount(
            for:self.model.currencyList?[self.model.selectedCurrencyIndex].code,
            amount: Double(self.searchedAmount) ?? 1)
        collectionView.reloadData()
        if let currency = selectedCurrency {
            currencyButton.setTitle(currency.code, for: .normal)
        }
    }
    
    func updateLabels() {
        if let currency = selectedCurrency {
            currencyButton.setTitle(currency.code, for: .normal)
        } else {
            currencyButton.setTitle(selectedCurrency?.code, for: .normal)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        lastUpdatedLabel.text = "Prices last updated at : \(dateFormatter.string(from: Date(timeIntervalSince1970: updatedTime)))"
        reloadData()
    }
    
    @IBAction func convertBtnClicked(_ sender: Any) {
        reloadData()
    }
    
}

extension ExchangeRateViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        let conversionItem = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        guard let conversionCell = conversionItem as? ExchangeRateCollectionViewCell else {
            return conversionItem
        }
        
        if model.convertedRates != nil {
            guard let test = self.model.convertedRates?[indexPath.row] else { return conversionCell }
            conversionCell.configureCell(for: test)
        }
        
        return conversionCell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.model.convertedRates?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
}

extension ExchangeRateViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        reloadData()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")
        
        if let doubleValue = Double(newText), doubleValue < Double.greatestFiniteMagnitude {
            return (true && (string == filtered))
        }
        
        return false
    }
}



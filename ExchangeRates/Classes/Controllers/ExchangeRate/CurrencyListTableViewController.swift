//
//  CurrencyListTableViewController.swift
//  ExchangeRates
//
//  Created by Chandran, Sudha on 18/03/21.
//

import UIKit

class CurrencyListTableViewController: UITableViewController {
    var parentVC = ExchangeRateViewController()
    var spinner = UIActivityIndicatorView(style: .large)
    var currencyList  = [Currency]()
    let errorAlert = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActivityIndicator()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        errorAlert.title = "Error!"
        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
                })
        errorAlert.addAction(ok)
        spinner.startAnimating()
        loadCurrencies()
    }
    
    func prepareActivityIndicator() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    func loadCurrencies() {
        if let currencyList = self.parentVC.model.currencyList {
            if (currencyList.count > 0) {
                self.currencyList = currencyList
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
}

extension CurrencyListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currencyList.count > 1 {
            return currencyList.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        let currency = self.currencyList[indexPath.row]
        cell.textLabel?.text = currency.code
        cell.detailTextLabel?.text = currency.name
        cell.selectionStyle = .none
        
        if (indexPath.row == self.parentVC.model.selectedCurrencyIndex ) {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        dismiss(animated: true) { [self] in
            self.parentVC.model.selectedCurrencyIndex = indexPath.row
            parentVC.updateLabels()
        }
        
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}

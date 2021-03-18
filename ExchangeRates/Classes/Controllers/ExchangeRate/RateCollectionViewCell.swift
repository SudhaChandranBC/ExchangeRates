//
//  ViewController.swift
//  ExchangeRates
//
//  Created by Chandran, Sudha on 18/03/21.
//

import UIKit

class ExchangeRateCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true

    }

    func configureCell(for exhangeRate:ExchangeRate) {
        currencyLabel.text = exhangeRate.code
        priceLabel.text = "\(String(format: "%0.3f",exhangeRate.rate))"
    }
    
}

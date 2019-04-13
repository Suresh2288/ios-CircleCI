//
//  CountryCell.swift
//  Plano
//
//  Created by Paing Pyi on 31/3/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class CountryCityCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    
    func configCountry(data:CountryData){
        lblTitle.text = data.name
    }
    func configCity(data:CityData){
        lblTitle.text = data.name
    }
}

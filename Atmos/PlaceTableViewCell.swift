//
//  PlaceTableViewCell.swift
//  Atmos
//
//  Created by Evangelos on 02/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
//MARK: Properties
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeCountryNameLabel: UILabel!
    @IBOutlet weak var placeTemperatureLabel: UILabel!
    @IBOutlet weak var placeCrowdLabel: UILabel!
    @IBOutlet weak var placeWeatherIconImageView: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

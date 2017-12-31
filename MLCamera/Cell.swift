//
//  Cell.swift
//  MLCamera
//
//  Created by Valeriy Van on 12/2/17.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var confidence: UILabel!

	override func prepareForReuse() {
		label.text = nil
		confidence.text = nil
	}
}

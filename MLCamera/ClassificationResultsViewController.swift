//
//  ClassificationResultsViewController.swift
//  MLCamera
//
//  Created by Michael Inger on 13/06/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit
import Vision

private let reuseID = "classificationResultCellReuseID"

/// Displays VNClassificationObservation in table view
class ClassificationResultsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var observations = [VNClassificationObservation]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }
    
    // MARK: UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return observations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        let observation = observations[indexPath.row]
        cell.textLabel?.text = observation.identifier
        cell.detailTextLabel?.text = numberFormatter.string(for: observation.confidence)
        return cell
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
}

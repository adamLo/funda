//
//  MainViewController.swift
//  Funda
//
//  Created by Adam Lovastyik on 15/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import UIKit

/// Main View controller that performs search and listing
class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// Displayes results
    @IBOutlet weak var propertiesTableView: UITableView!
    
    // Header
    @IBOutlet weak var locationTextField: UITextField!
    /// Filters to properties with garden
    @IBOutlet weak var gardenSwitch: UISwitch!
    @IBOutlet weak var gardenLabel: UILabel!
    /// Starts search
    @IBOutlet weak var searchButton: UIButton!
    
    // Visual feedback when searching
    @IBOutlet weak var searchActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchProgressView: UIProgressView!
    
    /// Cache to fetch and store results
    private var cache: AanbodCache?
    
    /// Cell reuse identifier
    private let cellReuseId = "aanbodCell"
    
    // MARK: - Controller lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        setupViewIdentifiers()
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        title = "Funda"
        
        setupHeader()
        setupTableView()
        toggleSearch(inProgress: false)
    }
    
    private func setupHeader() {
        
        toggleSearch(inProgress: false)
        
        searchActivityIndicator.tintColor = UIColor.black
        
        locationTextField.text = nil
        locationTextField.placeholder = NSLocalizedString("Location", comment: "Location placeholder")
        
        gardenLabel.text = NSLocalizedString("with garden", comment: "Garden filter switch title")
        
        gardenSwitch.isOn = false
    }
    
    private func setupTableView() {
        
        propertiesTableView.tableFooterView = UIView()
    }
    
    /// Togles UI when searching: filter elements disabled, button title is stop otherwise search
    private func toggleSearch(inProgress: Bool) {
        
        searchActivityIndicator.isHidden = !inProgress
        
        if inProgress {
            if !searchActivityIndicator.isAnimating {
                searchActivityIndicator.startAnimating()
            }
            searchProgressView.isHidden = false
            locationTextField.isEnabled = false
            gardenSwitch.isEnabled = false
            searchButton.setTitle(NSLocalizedString("Stop", comment: "Stop button title"), for: .normal)
        }
        else {
            if !inProgress && searchActivityIndicator.isAnimating {
                searchActivityIndicator.stopAnimating()
            }
            searchProgressView.isHidden = true
            locationTextField.isEnabled = true
            gardenSwitch.isEnabled = true
            searchButton.setTitle(NSLocalizedString("Search", comment: "Search button title"), for: .normal)
        }
    }
    
    // MARK: - UITableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let `cache` = cache else {return 0}
        return cache.top10Agencies.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let `cache` = cache, cache.top10Agencies.count > section else {return 0}
        
        let summary = cache.top10Agencies[section]
        return summary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let `cache` = cache, cache.top10Agencies.count > indexPath.section else {return UITableViewCell()}
        let summary = cache.top10Agencies[indexPath.section]
        let aanbods = cache.aanbods(of: summary.makelaar)
        guard indexPath.row < aanbods.count else {return UITableViewCell()}
        let aanbod = aanbods[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellReuseId)
        
        cell.textLabel?.text = aanbod.adres
        cell.detailTextLabel?.text = aanbod.id
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let `cache` = cache, cache.top10Agencies.count > section else {return nil}
        let summary = cache.top10Agencies[section]
        
        return "\(summary.makelaar.name) [\(summary.count)]"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let `cache` = cache, cache.top10Agencies.count > indexPath.section else {return}
        let summary = cache.top10Agencies[indexPath.section]
        let aanbods = cache.aanbods(of: summary.makelaar)
        guard indexPath.row < aanbods.count else {return}
        let aanbod = aanbods[indexPath.row]
    
        /// Open link in browser
        guard let url = URL(string: aanbod.url), UIApplication.shared.canOpenURL(url) else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonTouched(_ sender: Any) {
        
        // Dismiss keyboard
        _ = locationTextField.resignFirstResponder()
        
        if !(cache?.isFetching ?? false) || (cache?.isStopped ?? false) {
            // Not seatching or stopped, restart search
            startSearch()
        }
        else {
            // Stop current search
            cache?.stop()
        }
    }
    
    // MARK: - Data integrations
    
    private func startSearch() {
        
        guard let _query = locationTextField.text?.nilIfEmpty else {
            // Must provide a location
            let alert = UIAlertController.alertWithOKButton(message: NSLocalizedString("Please provide a location", comment: "Error message when location not provided"))
            present(alert, animated: true, completion: nil)
            return
        }
        
        cache = nil
        propertiesTableView.reloadData()
        
        searchProgressView.progress = 0
        toggleSearch(inProgress: true)
        
        let query = _query + (gardenSwitch.isOn ? "/tuin" : "")
        
        cache = AanbodCache(query: query)
        cache?.start(reset: true, finished: {[weak self] in
            self?.toggleSearch(inProgress: false)
        })
        cache?.dataUpdated = {[weak self] (progress) in
            self?.propertiesTableView.reloadData()
            self?.searchProgressView.progress = progress ?? 0
        }
    }
    
    // MARK: - UI Testing
       
    private func setupViewIdentifiers() {

        propertiesTableView.accessibilityIdentifier = "main.tableview.properties"
        
        locationTextField.accessibilityIdentifier = "main.textfield.location"
        gardenSwitch.accessibilityIdentifier = "main.switch.garden"
        gardenLabel.accessibilityIdentifier = "main.label.garden"
        searchButton.accessibilityIdentifier = "main.button.search"
        
        searchActivityIndicator.accessibilityIdentifier = "main.activity.search"
        searchProgressView.accessibilityIdentifier = "main.progress.search"
                
        navigationController?.navigationBar.accessibilityIdentifier = "main.navbar"
    }
}

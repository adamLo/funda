//
//  MainViewController.swift
//  Funda
//
//  Created by Adam Lovastyik on 15/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var propertiesTableView: UITableView!
    private var cache: AanbodCache!

    override func viewDidLoad() {
        
        super.viewDidLoad()

        cache = AanbodCache(query: "/amsterdam")
        cache.start {
            print("Finished")
        }
        
        cache.dataUpdated = {[weak self] () in
            self?.propertiesTableView.reloadData()
        }
    }
    

    // MARK: - UITableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard cache != nil else {return 0}
        return cache.top10Agencies.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard cache != nil, cache.top10Agencies.count > section else {return 0}
        
        let summary = cache.top10Agencies[section]
        return summary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard cache != nil, cache.top10Agencies.count > indexPath.section else {return UITableViewCell()}
        let summary = cache.top10Agencies[indexPath.section]
        let aanbods = cache.aanbods(of: summary.makelaar)
        guard indexPath.row < aanbods.count else {return UITableViewCell()}
        let aanbod = aanbods[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "aanbodCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "aanbodCell")
        
        cell.textLabel?.text = aanbod.adres
        cell.detailTextLabel?.text = aanbod.id
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard cache != nil, cache.top10Agencies.count > section else {return nil}
        let summary = cache.top10Agencies[section]
        
        return "\(summary.makelaar.name) [\(summary.count)]"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

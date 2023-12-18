//
//  GoOutViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/05/24.
//

import UIKit

class EventViewController: UIBaseViewController {

    @IBOutlet var eventTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eventTableView.delegate = self
        eventTableView.dataSource = self
        eventTableView.tableHeaderView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hideNavigationBarBorderAndShowTabBarBorder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension EventViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class EventCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var goodButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        goodButton.rounded()
        goodButton.setShadow(opacity: 0.1)
        iconImageView.layer.cornerRadius = 15
    }
}

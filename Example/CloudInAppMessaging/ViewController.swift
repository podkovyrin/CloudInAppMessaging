//
//  ViewController.swift
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 11/1/19.
//  Copyright © 2019 Andrew Podkovyrin. All rights reserved.
//

import CloudInAppMessaging
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction private func addButtonAction(_ sender: Any) {
        let controller = AddAlertCampaignViewController()
        controller.delegate = self
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: true)
    }
}

extension ViewController: AddAlertCampaignViewControllerDelegate {
    func addAlertCampaignViewController(_ controller: AddAlertCampaignViewController,
                                        didFinishWith alertCampaign: CLMAlertCampaign) {
        dismiss(animated: true)
    }
}

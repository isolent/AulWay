//
//  BaseViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 04.04.2025.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        enableReturnKeyDismissal()
    }

    func enableReturnKeyDismissal() {
        func findTextFields(in view: UIView) {
            for subview in view.subviews {
                if let textField = subview as? UITextField {
                    textField.addTarget(self, action: #selector(dismissKeyboard), for: .editingDidEndOnExit)
                } else {
                    findTextFields(in: subview)
                }
            }
        }
        findTextFields(in: view)
    }
}

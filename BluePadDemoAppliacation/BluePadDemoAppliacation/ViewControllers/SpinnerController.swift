//
//  SpinnerController.swift
//  
//
//  Created by Вова Ващеня on 07.05.2021.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .gray)
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

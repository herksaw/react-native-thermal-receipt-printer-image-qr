//
//  ErrorCodeViewController.swift
//  WIFI_Sample_Code
//
//  Created on 2023/1/9.
//

import UIKit

final class ErrorCodeViewController: UIViewController {

    @IBOutlet weak var errorCodeTextView: UITextView!

    var errorCodeString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorCodeTextView.text = errorCodeString
    }
}

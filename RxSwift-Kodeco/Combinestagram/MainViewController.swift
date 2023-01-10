//
//  ViewController.swift
//  RxSwift-Kodeco
//
//  Created by Ohjun-Wizardlab on 2023/01/06.
//

import UIKit

class MainViewController: UIViewController {

	@IBOutlet weak var imagePreview: UIImageView!
	@IBOutlet weak var buttonClear: UIButton!
	@IBOutlet weak var buttonSave: UIButton!
	@IBOutlet weak var itemAdd: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()

	}
	
	@IBAction func actionClear() {

	}

	@IBAction func actionSave() {

	}

	@IBAction func actionAdd() {

	}

	func showMessage(_ title: String, description: String? = nil) {
		let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
		present(alert, animated: true, completion: nil)
	}


}


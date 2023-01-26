//
//  WunderViewController.swift
//  RxSwift-Kodeco
//
//  Created by Ohjun-Wizardlab on 2023/01/25.
//

import UIKit
import RxSwift
import RxCocoa

class WunderViewController: UIViewController {
	@IBOutlet private var searchCityName: UITextField!
	@IBOutlet private var tempLabel: UILabel!
	@IBOutlet private var humidityLabel: UILabel!
	@IBOutlet private var iconLabel: UILabel!
	@IBOutlet private var cityNameLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		style()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		Appearance.applyBottomLine(to: searchCityName)
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Style

	private func style() {
		view.backgroundColor = UIColor.aztec
		searchCityName.attributedPlaceholder = NSAttributedString(string: "City's Name",
																															attributes: [.foregroundColor: UIColor.textGrey])
		searchCityName.textColor = UIColor.ufoGreen
		tempLabel.textColor = UIColor.cream
		humidityLabel.textColor = UIColor.cream
		iconLabel.textColor = UIColor.cream
		cityNameLabel.textColor = UIColor.cream
	}
}

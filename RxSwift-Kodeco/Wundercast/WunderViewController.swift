//
//  WunderViewController.swift
//  RxSwift-Kodeco
//
//  Created by Ohjun-Wizardlab on 2023/01/25.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class WunderViewController: UIViewController {
	@IBOutlet private var mapView: MKMapView!
	@IBOutlet private var mapButton: UIButton!
	@IBOutlet private var geoLocationButton: UIButton!
	@IBOutlet private var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private var searchCityName: UITextField!
	@IBOutlet private var tempLabel: UILabel!
	@IBOutlet private var humidityLabel: UILabel!
	@IBOutlet private var iconLabel: UILabel!
	@IBOutlet private var cityNameLabel: UILabel!
	
	private let bag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		style()
		
//		searchCityName.rx.text.orEmpty
//			.filter { !$0.isEmpty }
//			.flatMap { text in
//				ApiController.shared
//					.currentWeather(for: text)
//					.catchAndReturn(.empty)
//			}
//			.observe(on: MainScheduler.instance)
//			.subscribe(onNext: { data in
//				self.tempLabel.text = "\(data.temperature)° C"
//				self.iconLabel.text = data.icon
//				self.humidityLabel.text = "\(data.humidity)%"
//				self.cityNameLabel.text = data.cityName
//			})
//			.disposed(by: bag)
		
		let search = searchCityName.rx
//			.text.orEmpty
			.controlEvent(.editingDidEndOnExit)
			.map { self.searchCityName.text ?? "" }
			.filter { !$0.isEmpty }
			.flatMapLatest { text in
				ApiController.shared
					.currentWeather(for: text)
					.catchAndReturn(.empty)
			}
//			.share(replay: 1)
//			.observe(on: MainScheduler.instance)
			.asDriver(onErrorJustReturn: .empty)
		
		search.map { "\($0.temperature)℃" }
//			.bind(to: tempLabel.rx.text)
			.drive(tempLabel.rx.text)
			.disposed(by: bag)
		
		search.map(\.icon)
			.drive(iconLabel.rx.text)
			.disposed(by: bag)
		
		search.map { "\($0.humidity)%" }
			.drive(humidityLabel.rx.text)
			.disposed(by: bag)
		
		search.map(\.cityName)
			.drive(cityNameLabel.rx.text)
			.disposed(by: bag)

		
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

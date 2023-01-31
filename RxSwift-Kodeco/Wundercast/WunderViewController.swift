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
import CoreLocation

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
	
	private let locationManager = CLLocationManager()
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
		
		let searchInput = searchCityName.rx
			.controlEvent(.editingDidEndOnExit)
			.map { self.searchCityName.text ?? "" }
			.filter { !$0.isEmpty }
		
//		let search = searchInput
//			.flatMapLatest { text in
//				ApiController.shared
//					.currentWeather(for: text)
//					.catchAndReturn(.empty)
//			}
////			.share(replay: 1)
////			.observe(on: MainScheduler.instance)
//			.asDriver(onErrorJustReturn: .empty)
		
		let mapInput = mapView.rx.regionDidChangeAnimated
			.skip(1)
			.map { _ in
				CLLocation(latitude: self.mapView.centerCoordinate.latitude,
									 longitude: self.mapView.centerCoordinate.longitude)
			}
		
		let geoInput = geoLocationButton.rx.tap
			.flatMapLatest { _ in
				self.locationManager.rx.getCurrentLocation()
			}
		
		let geoSearch = Observable.merge(mapInput, geoInput)
			.flatMapLatest { location in
				ApiController.shared
					.currentWeather(at: location.coordinate)
					.catchAndReturn(.empty)
			}
		
		let textSearch = searchInput.flatMap { city in
			ApiController.shared
				.currentWeather(for: city)
				.catchAndReturn(.empty)
		}
		
		let search = Observable
			.merge(geoSearch, textSearch)
			.asDriver(onErrorJustReturn: .empty)
		
		let running = Observable.merge(
			searchInput.map { _ in true },
			mapInput.map { _ in true },
			geoInput.map { _ in true },
			search.map { _ in false }.asObservable()
		)
			.startWith(true)
			.asDriver(onErrorJustReturn: false)
		
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

		running
			.skip(1)
			.drive(activityIndicator.rx.isAnimating)
			.disposed(by: bag)
		
		mapButton.rx.tap
			.subscribe(onNext: { self.mapView.isHidden.toggle() })
			.disposed(by: bag)
		
		mapView.rx
			.setDelegate(self)
			.disposed(by: bag)
		
		search
			.map { $0.overlay() }
			.drive(mapView.rx.overlay)
			.disposed(by: bag)
		
//		geoLocationButton.rx.tap
//			.subscribe(onNext: { [weak self] _ in
//				guard let self = self else { return }
//				self.locationManager.requestWhenInUseAuthorization()
//				self.locationManager.startUpdatingLocation()
//			})
//			.disposed(by: bag)
//
//		locationManager.rx.didUpdateLocations
//			.subscribe(onNext: { locations in
//				print(locations)
//			})
//			.disposed(by: bag)
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

extension WunderViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let overlay = overlay as? ApiController.Weather.Overlay else {
			return MKOverlayRenderer()
		}
		
		return ApiController.Weather.OverlayView(overlay: overlay, overlayIcon: overlay.icon)
	}
}

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

typealias Weather = ApiController.Weather

class WunderViewController: UIViewController {
	@IBOutlet private var mapView: MKMapView!
	@IBOutlet private var mapButton: UIButton!
	@IBOutlet weak var keyButton: UIButton!
	@IBOutlet private var geoLocationButton: UIButton!
	@IBOutlet private var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private var searchCityName: UITextField!
	@IBOutlet private var tempLabel: UILabel!
	@IBOutlet private var humidityLabel: UILabel!
	@IBOutlet private var iconLabel: UILabel!
	@IBOutlet private var cityNameLabel: UILabel!
	
	private let locationManager = CLLocationManager()
	private let bag = DisposeBag()
	
	var keyTextField: UITextField?
	
	private var cache = [String: Weather]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		style()
		
		keyButton.rx.tap
			.subscribe(onNext: { [weak self] _ in
				self?.requestKey()
			})
			.disposed(by:bag)

		let currentLocation = locationManager.rx.didUpdateLocations
			.map { locations in locations[0] }
			.filter { location in
				return location.horizontalAccuracy == kCLLocationAccuracyNearestTenMeters
			}
		
		let searchInput = searchCityName.rx
			.controlEvent(.editingDidEndOnExit)
			.map { self.searchCityName.text ?? "" }
			.filter { !$0.isEmpty }
		
		let mapInput = mapView.rx.regionDidChangeAnimated
			.skip(1)
			.map { _ in
				CLLocation(latitude: self.mapView.centerCoordinate.latitude,
									 longitude: self.mapView.centerCoordinate.longitude)
			}
		
		let geoInput = geoLocationButton.rx.tap
			.do(onNext: { [weak self] _ in
				self?.locationManager.requestWhenInUseAuthorization()
				self?.locationManager.startUpdatingLocation()

				self?.searchCityName.text = "Current Location"
			})
		
		let geoLocation = geoInput.flatMap {
			return currentLocation.take(1)
		}
		
		let geoSearch = geoLocation.flatMap { location in
			return ApiController.shared.currentWeather(at: location.coordinate)
				.catchAndReturn(.empty)
		}
		
		let maxAttempts: Int = 2
		
		let retryHandler: (Observable<Error>) -> Observable<Int> = { e in
			return e.enumerated().flatMap { attempt, error -> Observable<Int> in
				return e.enumerated().flatMap { attempt, error -> Observable<Int> in
					if attempt >= maxAttempts - 1 {
						return Observable.error(error)
					}
					print("== retrying after \(attempt + 1) seconds ==")
					
					return Observable<Int>.timer(.seconds(attempt + 1), scheduler: MainScheduler.instance)
						.take(1)
				}
			}
		}
		
		let textSearch = searchInput.flatMap { city in
			ApiController.shared
				.currentWeather(for: city)
				.do(
					onNext: { [weak self] data in
					self?.cache[city] = data
				},
					onError: { error in
						DispatchQueue.main.async { [weak self] in
							guard let self = self else { return }
							self.showError(error: error)
						}
				})
				.retry(when: retryHandler)
				.catch({ [weak self] error in
					Observable.just(self?.cache[city] ?? .empty)
				})
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
		
		_ = RxReachability.shared.startMonitor("openweathermap.org")
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
	
	func requestKey() {
		func configurationTextField(textField: UITextField!) {
			self.keyTextField = textField
		}

		let alert = UIAlertController(title: "Api Key",
																	message: "Add the api key:",
																	preferredStyle: UIAlertController.Style.alert)

		alert.addTextField(configurationHandler: configurationTextField)

		alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
			ApiController.shared.apiKey.onNext(self?.keyTextField?.text ?? "")
		})

		alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive))

		self.present(alert, animated: true)
	}
	
	private func showError(error e: Error) {
		guard let e = e as? ApiController.ApiError else {
			InfoView.showIn(viewController: self, message: "An error occurred")
			return
		}
		
		switch e {
		case .cityNotFound:
			InfoView.showIn(viewController: self, message: "City Name is invalid")
		case .serverFailure:
			InfoView.showIn(viewController: self, message: "Server error")
		case .invalidKey:
			InfoView.showIn(viewController: self, message: "Key is invalid")
		}
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

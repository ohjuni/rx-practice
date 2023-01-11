//
//  ViewController.swift
//  RxSwift-Kodeco
//
//  Created by Ohjun-Wizardlab on 2023/01/06.
//

import UIKit
import RxSwift
import RxRelay

class MainViewController: UIViewController {

	@IBOutlet weak var imagePreview: UIImageView!
	@IBOutlet weak var buttonClear: UIButton!
	@IBOutlet weak var buttonSave: UIButton!
	@IBOutlet weak var itemAdd: UIBarButtonItem!
	
	private let bag = DisposeBag()
	private let images = BehaviorRelay<[UIImage]>(value: [])
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// images 구독
		images
			.subscribe(onNext: { [weak imagePreview] photos in
				guard let preview = imagePreview else { return }
				preview.image = photos.collage(size: preview.frame.size)
			})
			.disposed(by: bag)
		
		images
			.subscribe(onNext: { [weak self] photos in
				self?.updateUI(photos: photos)
			})
			.disposed(by: bag)
	}
	
	@IBAction func actionClear() {
		images.accept([])
	}

	@IBAction func actionSave() {
		guard let image = imagePreview.image else { return }
		
		PhotoWriter.save(image)
//			.asSingle()
			.subscribe { [weak self] id in
				self?.showMessage("saved with id: \(id)")
			} onFailure: { [weak self] error in
				self?.showMessage("Error", description: error.localizedDescription)
			}
			.disposed(by: bag)

	}

	@IBAction func actionAdd() {
//		let newImages = images.value + [UIImage(named: "IMG_1907.jpg")!]
//		images.accept(newImages)
		let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
		
		photosViewController.selectedPhotos
			.subscribe { [weak self] newImage in
				guard let images = self?.images else { return }
				images.accept(images.value + [newImage])
			} onDisposed: {
				print("Completed photo selection")
			}
			.disposed(by: bag)

		
		navigationController!.pushViewController(photosViewController, animated: true)
		
	}

	func showMessage(_ title: String, description: String? = nil) {
//		let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
//		alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
//		present(alert, animated: true, completion: nil)
		alert(title: title, text: description)
			.subscribe()
			.disposed(by: bag)
	}
	
	private func updateUI(photos: [UIImage]) {
		buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
		buttonClear.isEnabled = photos.count > 0
		itemAdd.isEnabled = photos.count < 6
		title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
	}

}


//
//  MainViewController.swift
//  RxSwift-Kodeco
//
//  Created by Ohjun-Wizardlab on 2023/01/13.
//

import UIKit

class MainViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func combinestagram() {
		let sb = UIStoryboard(name: "Combinestagram", bundle: nil)
		let combinestagramViewController = sb.instantiateViewController(withIdentifier: "CombinestagramViewController") as! CombinestagramViewController
		DispatchQueue.main.async {
			self.navigationController!.pushViewController(combinestagramViewController, animated: true)
		}
		
	}
	
	@IBAction func gitFeed() {
		let sb = UIStoryboard(name: "GitFeed", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "ActivityController") as! ActivityController
		DispatchQueue.main.async {
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func ourPlanet() {
		let sb = UIStoryboard(name: "OurPlanet", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
		DispatchQueue.main.async {
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func wundercast() {
		let sb = UIStoryboard(name: "Wundercast", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "WunderViewController") as! WunderViewController
		DispatchQueue.main.async {
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}

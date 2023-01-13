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
}

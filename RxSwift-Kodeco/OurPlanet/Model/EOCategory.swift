//
//  EOCategory.swift
//  RxSwift-Kodeco
//
//  Created by Ohjun-Wizardlab on 2023/01/17.
//

import Foundation

struct EOCategory: Decodable {
	let id: String
	let name: String
	let description: String

	var events = [EOEvent]()
	var endpoint: String {
		return "\(EONET.categoriesEndpoint)/\(self.id)"
	}

	private enum CodingKeys: String, CodingKey {
		case id, name = "title", description
	}
}

extension EOCategory: Equatable {
	static func ==(lhs: EOCategory, rhs: EOCategory) -> Bool {
		return lhs.id == rhs.id
	}
}

//
//  EONET.swift
//  RxSwift-Kodeco
//
//  Created by Ohjun-Wizardlab on 2023/01/17.
//

import Foundation
import RxSwift
import RxCocoa

class EONET {
	static let API = "https://eonet.sci.gsfc.nasa.gov/api/v2.1"
	static let categoriesEndpoint = "/categories"
	static let eventsEndpoint = "/events"

	static func jsonDecoder(contentIdentifier: String) -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.userInfo[.contentIdentifier] = contentIdentifier
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}

	static func filteredEvents(events: [EOEvent], forCategory category: EOCategory) -> [EOEvent] {
		return events.filter { event in
			return event.categories.contains(where: { $0.id == category.id }) && !category.events.contains {
				$0.id == event.id
			}
			}
			.sorted(by: EOEvent.compareDates)
	}

}

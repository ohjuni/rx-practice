//
//  Event.swift
//  RxSwift-Kodeco
//
//  Created by Ohjun-Wizardlab on 2023/01/13.
//

import Foundation

struct Event: Codable {
	let action: String
	let repo: Repo
	let actor: Actor

	enum CodingKeys: String, CodingKey {
		case action = "type"
		case repo
		case actor
	}
}

struct Repo: Codable {
	let name: String
}

struct Actor: Codable {
	let name: String
	let avatar: URL

	enum CodingKeys: String, CodingKey {
		case name = "display_login"
		case avatar = "avatar_url"
	}
}

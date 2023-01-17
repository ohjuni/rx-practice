//
//  EOError.swift
//  RxSwift-Kodeco
//
//  Created by Ohjun-Wizardlab on 2023/01/17.
//

import Foundation

enum EOError: Error {
	case invalidURL(String)
	case invalidParameter(String, Any)
	case invalidJSON(String)
	case invalidDecoderConfiguration
}


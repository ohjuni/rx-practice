//
//  PhotoWriter.swift
//  RxSwift-Kodeco
//
//  Created by Ohjun-Wizardlab on 2023/01/06.
//

import Foundation
import UIKit
import Photos
import RxSwift

class PhotoWriter {
  enum Errors: Error {
    case couldNotSavePhoto
  }
	
	static func save(_ image: UIImage) -> Observable<String> { // Future
		return Observable.create { observer in
			var saveAssetId: String?
			PHPhotoLibrary.shared().performChanges {
				let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
				saveAssetId = request.placeholderForCreatedAsset?.localIdentifier
			} completionHandler: { success, error in
				DispatchQueue.main.async {
					if success, let id = saveAssetId {
						observer.onNext(id)
						observer.onCompleted()
					} else {
						observer.onError(error ?? Errors.couldNotSavePhoto)
					}
				}
			}
			return Disposables.create()
		}
	}


}

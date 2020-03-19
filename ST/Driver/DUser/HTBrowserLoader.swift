//
//  HTBrowserLoader.swift
//  ST
//
//  Created by taotao on 2019/10/30.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation
import Kingfisher


class HTBrowserLoader: JXPhotoLoader {
	func hasCached(with url: URL?) -> Bool {
		guard let url = url else {
			return false
		}
		return KingfisherManager.shared.cache.imageCachedType(forKey: url.cacheKey).cached
	}
	
	
	func setImage(on imageView: UIImageView, url: URL?, placeholder: UIImage?, progressBlock: @escaping (Int64, Int64) -> Void, completionHandler: @escaping () -> Void) {
		imageView.kf.setImage(with: url, placeholder: placeholder, progressBlock: { receivedSize, totalSize in
			progressBlock(receivedSize, totalSize)
		}, completionHandler: { _, _, _, _ in
			completionHandler()
		})
	}
	
	
}

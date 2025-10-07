//
//  Global.swift
//  NavigationBackport
//
//  Created by Sekny Yim on 07-10-2025.
//

import Foundation

func print(_ objects: Any...) {
	#if DEBUG
	for item in objects {
		Swift.print(item)
	}
	#endif
}

func print(_ object: Any) {
	#if DEBUG
	Swift.print(object)
	#endif
}

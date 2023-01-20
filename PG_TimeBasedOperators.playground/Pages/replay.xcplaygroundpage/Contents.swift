import UIKit
import RxSwift
import RxCocoa


// Start coding here


// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
	static func make() -> TimelineView<E> {
		return TimelineView(width: 400, height: 100)
	}
	public func on(_ event: Event<E>) {
		switch event {
		case .next(let value):
			add(.next(String(describing: value)))
		case .completed:
			add(.completed())
		case .error(_):
			add(.error())
		}
	}
}
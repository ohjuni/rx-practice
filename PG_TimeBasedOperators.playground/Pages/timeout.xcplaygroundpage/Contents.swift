import UIKit
import RxSwift
import RxCocoa


// Start coding here
let button = UIButton(type: .system)
button.setTitle("Press me now!", for: .normal)
button.sizeToFit()

let tapsTimeline = TimelineView<String>.make()

let stack = UIStackView.makeVertical([
	button,
	UILabel.make("Taps on button above"),
	tapsTimeline
])

let _ = button
	.rx.tap
	.map { _ in "·" }
//	.timeout(.seconds(5), scheduler: MainScheduler.instance)
	.timeout(.seconds(5), other: Observable.just("X"), scheduler: MainScheduler.instance)
	.subscribe(tapsTimeline)

let hostView = setupHostView()
hostView.addSubview(stack)
hostView

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

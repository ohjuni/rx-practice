import UIKit
import RxSwift
import RxCocoa

// Start coding here
let bufferTimeSpan: RxTimeInterval = .seconds(4)
let bufferMaxCount = 2

let sourceObservable = PublishSubject<String>()

let sourceTimeline = TimelineView<String>.make()
let bufferedTimeline = TimelineView<Int>.make()

_ = sourceObservable.subscribe(sourceTimeline)

sourceObservable
	.buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
	.map(\.count)
	.subscribe(bufferedTimeline)

//DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//	sourceObservable.onNext("🐱")
//	sourceObservable.onNext("🐱")
//	sourceObservable.onNext("🐱")
//}

let elementsPerSecond: Double = 0.4
let timer = DispatchSource.timer(interval: 1.0 / elementsPerSecond, queue: .main) {
	sourceObservable.onNext("🐱")
}

let stack = UIStackView.makeVertical([
	UILabel.makeTitle("buffer"),
	UILabel.make("Emitted elements:"),
	sourceTimeline,
	UILabel.make("Buffered elements (at most \(bufferMaxCount) every \(bufferTimeSpan) seconds):"),
	bufferedTimeline
])

let hostView = setupHostView()
hostView.addSubview(stack)
hostView





// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
	static func make() -> TimelineView<E> {
		let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
		view.setup()
		return view
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

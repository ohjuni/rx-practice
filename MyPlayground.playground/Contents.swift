import UIKit
import RxSwift
import RxRelay

//var greeting = "Hello, playground"

// MARK: - 1-2: Observables
example(of: "just, of, from") {
	let one = 1
	let two = 2
	let three = 3
	
	// observable 생성
	let observable = Observable<Int>.just(one)
	let observable2 = Observable.of(one, two, three)
	let observable3 = Observable.of([one, two, three])
	let observable4 = Observable.from([one, two, three])
}

example(of: "subscribe") {
	let one = 1
	let two = 2
	let three = 3
	
	let observable = Observable.of(one, two, three)
	
//	observable.subscribe { event in
//		print(event)
//	}
	
//	observable.subscribe { event in
//		if let element = event.element {
//			print(element)
//		}
//	}
	
	observable.subscribe(onNext: { element in
		print(element)
	})
}

example(of: "empty") {
	let observable = Observable<Void>.empty()
	
	observable.subscribe(
		onNext: { element in
			print(element)
		},
		
		onCompleted: {
			print("Completed")
		}
	)
}

example(of: "never") {
	let observable = Observable<Void>.never()
	
	observable.subscribe(
		onNext: { element in
			print(element)
		},
		onCompleted: {
			print("Completed")
		}
	)
}

example(of: "range") {
	let observable = Observable<Int>.range(start: 1, count: 10)
	
	observable
		.subscribe(
			onNext: { i in
				let n = Double(i)
				
				let fibonacci = Int(
					((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded()
				)
				
				print(fibonacci)
			},
			onCompleted: {
				print("Completed")
			})
}

example(of: "dispose") {
	let observable = Observable.of("A", "B", "C")
	
	let subscription = observable.subscribe { event in
		print(event)
	}
	
	subscription.dispose()
}

example(of: "DisposeBag") {
	let disposeBag = DisposeBag() // Combine의 AnyCancellable
	
	Observable.of("A", "B", "C")
		.subscribe {
			print($0)
		}
		.disposed(by: disposeBag)
}

example(of: "create") {
	enum MyError: Error {
		case anError
	}
	
	let disposeBag = DisposeBag()
	
	Observable<String>.create { observer in
		observer.onNext("1")
		
//		observer.onError(MyError.anError)
		
//		observer.onCompleted()
		
		observer.onNext("?")
		
		return Disposables.create()
	}
	.subscribe(
		onNext: { print($0) },
		onError: { print($0) },
		onCompleted: { print("Completed") },
		onDisposed: { print("Disposed") }
	)
	.disposed(by: disposeBag)
}

example(of: "deferred") {
	let disposeBag = DisposeBag()
	
	var flip = false
	
	let factory: Observable<Int> = Observable.deferred {
		flip.toggle()
		
		if flip {
			return Observable.of(1, 2, 3)
		} else {
			return Observable.of(4, 5, 6)
		}
	}
	
	for _ in 0...3 {
		factory.subscribe(onNext: {
			print($0, terminator: "")
		})
		.disposed(by: disposeBag)
		
		print()
	}
}

example(of: "Single") {
	let disposeBag = DisposeBag()
	
	enum FileReadError: Error {
		case fileNotFound, unreadable, encodingFailed
	}
	
	func loadText(from name: String) -> Single<String> {
		return Single.create { single in
			let disposable = Disposables.create()
			
			guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
				single(.failure(FileReadError.fileNotFound))
				return disposable
			}
			
			guard let data = FileManager.default.contents(atPath: path) else {
				single(.failure(FileReadError.unreadable))
				return disposable
			}
			
			guard let contents = String(data: data, encoding: .utf8) else {
				single(.failure(FileReadError.encodingFailed))
				return disposable
			}
			
			single(.success(contents))
			return disposable
		}
	}
	
	loadText(from: "Copyright")
		.subscribe {
			switch $0 {
			case .success(let string):
				print(string)
			case .failure(let error):
				print(error)
			}
		}
		.disposed(by: disposeBag)

}

// MARK: - 1-3: Subjects
example(of: "PublishSubject") { // Combine의 Subject
	let subject = PublishSubject<String>() // ~= PassthroughSubject
	
	subject.on(.next("Is anyone listening?")) // Combine의 send(?)
	
	let subscriptionOne = subject
		.subscribe(onNext: { string in // sink(?)
			print(string)
		})
	
	subject.on(.next("1"))
	
	subject.onNext("2")
	
	let subscriptionTwo = subject
		.subscribe { event in
			print("2)", event.element ?? event)
		}
	
	subject.onNext("3")
	
	subscriptionOne.dispose()

	subject.onNext("4")
	
	subject.onCompleted()
	
	subject.onNext("5")
	
	subscriptionTwo.dispose()
	
	let disposeBag = DisposeBag()
	
	subject
		.subscribe {
			print("3)", $0.element ?? $0)
		}
		.disposed(by: disposeBag)
	
	subject.onNext("?")
}

enum MyError: Error {
	case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
	print(label, (event.element ?? event.error) ?? event)
}

example(of: "BehaviorSubject") {
	let subject = BehaviorSubject(value: "Initial value") // ~= CurrentValueSubject
	let disposeBag = DisposeBag()
	
	subject
		.subscribe {
			print(label: "1)", event: $0)
		}
		.disposed(by: disposeBag)
	
	subject.onNext("X")
	
	subject.onError(MyError.anError)
	
	subject
		.subscribe {
			print(label: "2)", event: $0)
		}
		.disposed(by: disposeBag)
}

example(of: "ReplaySubject") {
	let subject = ReplaySubject<String>.create(bufferSize: 2)
	let disposeBag = DisposeBag()
	
	subject.onNext("1")
	subject.onNext("2")
	subject.onNext("3")
	
	subject
		.subscribe {
			print(label: "1)", event: $0)
		}
		.disposed(by: disposeBag)

	subject
		.subscribe {
			print(label: "2)", event: $0)
		}
		.disposed(by: disposeBag)
	
	subject.onNext("4")
	
	subject.onError(MyError.anError)
	
	subject.dispose()
	
	subject
		.subscribe {
			print(label: "3)", event: $0)
		}
		.disposed(by: disposeBag)
}

example(of: "PublishRelay") {
	let relay = PublishRelay<String>()
	let disposeBag = DisposeBag()
	
	relay.accept("Knock knock, anyone home?")
	
	relay.subscribe(onNext: {
		print($0)
	}).disposed(by: disposeBag)
	
	relay.accept("1")
}

example(of: "BehaviorRelay") {
	let relay = BehaviorRelay(value: "Initial value")
	let disposeBag = DisposeBag()
	
	relay.accept("New initial value")
	
	relay.subscribe {
		print(label: "1)", event: $0)
	}.disposed(by: disposeBag)
	
	relay.accept("1")
	
	relay.subscribe {
		print(label: "2)", event: $0)
	}.disposed(by: disposeBag)
	
	relay.accept("2")
	
	print(relay.value)
}


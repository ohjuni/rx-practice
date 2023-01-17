import UIKit
import RxSwift
import RxRelay

//var greeting = "Hello, playground"
let disposeBag = DisposeBag()

example(of: "toArray") {
	Observable.of("A", "B", "C")
		.toArray()
		.subscribe(onSuccess: {
			print($0)
		})
		.disposed(by: disposeBag)
}


example(of: "map") {
	let formatter = NumberFormatter()
	formatter.numberStyle = .spellOut
	
	Observable<Int>.of(123, 4, 56)
		.map {
			return formatter.string(for: $0) ?? ""
		}
		.subscribe(onNext: {
			print($0)
		})
		.disposed(by: disposeBag)
	
}

example(of: "enumerated and map") {
	Observable.of(1, 2, 3, 4, 5, 6)
		.enumerated()
		.map { index, element in
			return index > 2 ? element * 2 : element
		}
		.subscribe(onNext: {
			print($0)
		})
		.disposed(by: disposeBag)
}

example(of: "compactMap") {
	Observable.of("To", "be", nil, "or", "not", "to", "be", nil)
		.compactMap { $0 }
		.toArray()
		.map { $0.joined(separator: " ")}
		.subscribe(onSuccess: {
			print($0)
		})
		.disposed(by: disposeBag)
}

struct Student {
	let score: BehaviorSubject<Int>
}

enum MyError: Error {
	case anError
}

example(of: "flatMap") {
	let laura = Student(score: BehaviorSubject(value: 80))
	let charlotte = Student(score: BehaviorSubject(value: 90))
	
	let student = PublishSubject<Student>()
	
	student
		.flatMap { $0.score }
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
	
	student.onNext(laura)
	laura.score.onNext(85)
	
	student.onNext(charlotte)
	laura.score.onNext(95)
	
	charlotte.score.onNext(100)
}
	
example(of: "flatMapLatest") {
	let laura = Student(score: BehaviorSubject(value: 80))
	let charlotte = Student(score: BehaviorSubject(value: 90))
	
	let student = PublishSubject<Student>()
	
	student
		.flatMapLatest { $0.score }
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
	
	student.onNext(laura)
	laura.score.onNext(85)
	
	student.onNext(charlotte)
	laura.score.onNext(95)
	
	charlotte.score.onNext(100)
}
	
example(of: "materialize and dematerialize") {
	let laura = Student(score: BehaviorSubject(value: 80))
	let charlotte = Student(score: BehaviorSubject(value: 100))
	
	let student = BehaviorSubject(value: laura)
	
	let studentScore = student
		.flatMapLatest { $0.score.materialize() }
	
	studentScore
		.filter {
			guard $0.error == nil else {
				print($0.error!)
				return false
			}
			return true
		}
		.dematerialize()
		.subscribe(onNext: { print($0) })
		.disposed(by: disposeBag)
	
	laura.score.onNext(85)
	laura.score.onError(MyError.anError)
	laura.score.onNext(90)
	
	student.onNext(charlotte)
}

example(of: "startWith") {
	let numbers = Observable.of(2, 3, 4)
	
	let observable = numbers.startWith(1)
	_ = observable.subscribe(onNext: { value in
		print(value)
	})
}

example(of: "Observable.concat") {
	let first = Observable.of(1, 2, 3)
	let second = Observable.of(4, 5, 6)
	
	let observable = Observable.concat([first, second])
	
	observable.subscribe(onNext: { value in
		print(value)
	})
	
	
}

example(of: "concat") {
	let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
	let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
	
	let observable = germanCities.concat(spanishCities)
	_ = observable.subscribe(onNext: { value in
		print(value)
	})
}

example(of: "concatMap") {
	let sequences = [
		"German cities": Observable.of("Berlin", "Münich", "Frankfurt"),
		"Spanish cities": Observable.of("Madrid", "Barcelona", "Valencia")
	]
	
	let observable = Observable.of("German cities", "Spanish cities")
		.concatMap { country in
			sequences[country] ?? .empty()
		}
	
	_ = observable.subscribe(onNext: { string in
		print(string)
	})
}

example(of: "merge") {
	let left = PublishSubject<String>()
	let right = PublishSubject<String>()
	
	let source = Observable.of(left.asObservable(), right.asObservable())
	
	let observable = source.merge()
	_ = observable.subscribe(onNext: { value in
		print(value)
	}, onCompleted: {
		print("Completed")
	})
	
	var leftValues = ["Berlin", "Münich", "Frankfurt"]
	var rightValues = ["Madrid", "Barcelona", "Valencia"]
	repeat {
		switch Bool.random() {
		case true where !leftValues.isEmpty:
			left.onNext("Left: " + leftValues.removeFirst())
		case false where !rightValues.isEmpty:
			right.onNext("Right: " + rightValues.removeFirst())
		default: break
		}
	} while (!leftValues.isEmpty || !rightValues.isEmpty)
						left.onCompleted()
						right.onCompleted()
}

example(of: "combineLstest") {
	let left = PublishSubject<String>()
	let right = PublishSubject<String>()
	
	let observable = Observable.combineLatest(left, right) { lastLeft, lastRight in
		"\(lastLeft) \(lastRight)"
	}
	
	_ = observable.subscribe(onNext: { value in
		print(value)
	})
	
	// 2
	print("> Sending a value to Left")
	left.onNext("Hello,")
	print("> Sending a value to Right")
	right.onNext("world")
	print("> Sending another value to Right")
	right.onNext("RxSwift")
	print("> Sending another value to Left")
	left.onNext("Have a good day,")

	left.onCompleted()
	right.onCompleted()
}

example(of: "combine user choice and value") {
	let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
	let dates = Observable.of(Date())
	
	let observable = Observable.combineLatest(choice, dates) { format, when -> String in
		let formatter = DateFormatter()
		formatter.dateStyle = format
		return formatter.string(from: when)
	}
	
	_ = observable.subscribe(onNext: { value in
		print(value)
	})
}

example(of: "zip") {
	enum Weather {
		case cloudy
		case sunny
	}
	
	let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
	let right = Observable.of("Lisbon", "Copenhagen", "london", "Madrid", "Vienna")
	
	let observable = Observable.zip(left, right) { weather, city in
		return "It's \(weather) in \(city)"
	}
	
	_ = observable.subscribe(onNext: { value in
		print(value)
	})
}

example(of: "withLatestFrom") {
	let button = PublishSubject<Void>()
	let textField = PublishSubject<String>()
	
//	let observable = button.withLatestFrom(textField)
	let observable = textField.sample(button)
	_ = observable.subscribe(onNext: { value in
		print(value)
	})
	
	textField.onNext("par")
	textField.onNext("pari")
	textField.onNext("paris")
	
	button.onNext(())
	button.onNext(())
}

example(of: "amb") {
	let left = PublishSubject<String>()
	let right = PublishSubject<String>()
	
	let observable = left.amb(right)
	_ = observable.subscribe(onNext: { value in
		print(value)
	})
	
	left.onNext("Lisbon")
	right.onNext("Copenhagen")
	left.onNext("London")
	left.onNext("Madrid")
	right.onNext("Vienna")
	
	
	left.onCompleted()
	right.onCompleted()
}

example(of: "switchLatest") {
	let one = PublishSubject<String>()
	let two = PublishSubject<String>()
	let three = PublishSubject<String>()
	
	let source = PublishSubject<Observable<String>>()
	
	let observable = source.switchLatest()
	
	let disposable = observable.subscribe(onNext: { value in
		print(value)
	})
	
	source.onNext(one)
	one.onNext("Some texxt from sequence one")
	two.onNext("Some texxt from sequence two")
	
	source.onNext(two)
	one.onNext("Some texxt from sequence one")
	two.onNext("Some texxt from sequence two")
	
	source.onNext(three)
	two.onNext("Why don't you see me?")
	one.onNext("I'm alone, help me")
	three.onNext("Hey it's three. I win.")
	
	source.onNext(one)
	one.onNext("Nope. It's me, one!")
	
	disposable.dispose()
}

example(of: "reduce") {
	let source = Observable.of(1, 3, 5, 7, 9)
	
//	let observable = source.reduce(0, accumulator: +)
	let observable = source.reduce(0) { summary, newValue in
		return summary + newValue
	}
	
	_ = observable.subscribe(onNext: { value in
		print(value)
	})
}

example(of: "scan") {
	let source = Observable.of(1, 3, 5, 7, 9)
	
	let observable = source.scan(0, accumulator: +)
	
	_ = observable.subscribe(onNext: { value in
		print(value)
	})
}

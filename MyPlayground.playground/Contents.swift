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

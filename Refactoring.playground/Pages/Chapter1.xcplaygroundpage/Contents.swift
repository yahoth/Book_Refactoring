import Foundation
import XCTest



// Sources 폴더 참조
let plays: Plays = [
    "hamlet" : Play(name: "Hamlet", type: "tragedy"),
    "as-like" : Play(name: "As You Like It", type: "comedy"),
    "othello" : Play(name: "Othello", type: "tragedy")
]

let invoice = Invoice(customer: "BigCo",
                      performances: [
                        Performance(playID: "hamlet", audience: 55),
                        Performance(playID: "as-like", audience: 35),
                        Performance(playID: "othello", audience: 40),
                      ])

struct StatementData {
    public let customer: String
    public let performances: [Performance]
    public let totalAmount: Int
    public let totalVolumeCredits: Int

    public init(customer: String, performances: [Performance], totalAmount: Int, totalVolumeCredits: Int) {
        self.customer = customer
        self.performances = performances
        self.totalAmount = totalAmount
        self.totalVolumeCredits = totalVolumeCredits
    }
}


// statement 메소드
func statement(invoice: Invoice, plays: Plays) throws -> String {
    let statementData = StatementData(customer: invoice.customer,
                                      performances: try invoice.performances.map( enrichPerformance(_:)),
                                      totalAmount: try totalAmount(),
                                      totalVolumeCredits: try totalVolumeCredits())
    return try renderPlainText(statementData, plays)

    func enrichPerformance(_ aPerformance: Performance) throws -> Performance {
        var result = aPerformance
        result.play = try playFor(aPerformance)
        result.amount = try amountFor(aPerformance)
        result.volumeCredits = try volumeCreditsFor(aPerformance)

        return result
    }

    func renderPlainText(_ data: StatementData, _ plays: Plays) throws -> String {
        var result = "청구내역(고객명:\(data.customer))\n"

        for perf in data.performances {
            // 청구 내역을 출력한다.
            result += "\((try playFor(perf)).name): \(usd(try amountFor(perf))) (\(perf.audience))석\n"
        }

        result += "총액: \(usd(data.totalAmount))\n"
        result += "적립 포인트: \(data.totalVolumeCredits)점\n"
        return result
    }

    func totalAmount() throws -> Int {
        var result = 0
        for perf in invoice.performances {
            result += try amountFor(perf)
        }
        return result
    }

    func totalVolumeCredits() throws -> Int {
        var result = 0
        for perf in invoice.performances {
            result += try volumeCreditsFor(perf)
        }
        return result
    }

    func usd(_ aNumber: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 2

        if let formattedNumber = formatter.string(from: NSNumber(value: aNumber / 100)) {
            return formattedNumber
        } else {
            return "format error"
        }
    }

    func volumeCreditsFor(_ aPerformance: Performance) throws -> Int {
        var result = 0
        result += max(aPerformance.audience - 30, 0)

        if "comedy" == (try playFor(aPerformance)).type {
            result += aPerformance.audience / 5
        }

        return result
    }

    func playFor(_ aPerformance: Performance) throws -> Play {
        guard let play = plays[aPerformance.playID] else { throw StatementError.playIDError("연극명과 playID가 일치하지 않습니다.")
        }
        return play
    }

    func amountFor(_ aPerformance: Performance) throws -> Int {
        var result = 0
        switch (try playFor(aPerformance)).type {
        case "tragedy":
            result = 40000
            if aPerformance.audience > 30 {
                result += 1000 * (aPerformance.audience - 30)
            }
            break
        case "comedy":
            result = 30000
            if aPerformance.audience > 20 {
                result += 10000 + (500 * (aPerformance.audience - 20))
            }
            result += 300 * aPerformance.audience
        default:
            throw StatementError.typeError("알 수 없는 장르: \(String(describing: (try playFor(aPerformance)).type))")
        }
        return result
    }
}



test(result: try statement(invoice: invoice, plays: plays))


/// 함수 추출하기
/// 작은 단위로 추출하고, 바로 테스트한다, 커밋하기 -> 테스트를 바로 함으로써 후에 올 큰일을 대비한다.
/// 의미 있는 단위로 뭉치면 푸시
///
/// 추출 후 명확하게 표현할 수 있는 방법 찾아보기
/// 1. 변수의 이름을 더 명확하게 바꾸기
/// thisAmount ->  result (함수의 반환값은 항상 result, 역할을 쉽게 볼수있다.)
/// perf -> aPerformance (메소드는 한 공연마다 값을 매긴다. 역할이 뚜렷하지않을때 관사를 붙인다. 매개변수에 접두어를 붙여보자)
/// plays[perf.playID] -> perf에 따라 자동으로 바뀌기 때문에 굳이 변수를 만들 것 없이 playFor(aPerformance) 메소드를 통해 사용가능하다. 하지만 swift에선 에러 핸들링을 위해 throws-try를 사용하기 때문에 오히려 가독성이 떨어지는 위험이 있다. 일단 이것은 연습이기 때문에 지저분해지겠지만 따라서 하겠다.
/// play(공연)은 리팩토링 전엔 루프당 한번만 조회했는데, 리팩토링 이후엔 3번씩 조회를 한다. 성능엔 지장이 없어보이고, 행여 지장이 생기더라도 제대로된 리팩코드는 성능 개선에 훨씬 수월하다,
/// -> 무슨뜻이냐? play 변수 자체를 줄인 결과 로컬 유효범위의 변수가 줄어서 이후 부분을 추출(리팩)하기가 더 쉬워졌다.
///
/// 중첩함수를 만들면 원래 함수안에서 쓰면 매개변수로 넣을 필요가 없다. 하지만 지금같은 경우는 for in 문 안의 상수를 매개변수로 받기 때문에 어차피 매개변수로 바꿔야한다.
/// 그렇게 된이상 매개변수 명을 더 명확하게 바꾼다.

/// 네이밍이 항상 어려운데, 더 명확하고 규칙성 있는 네이밍을 배우니까 한단계 성장한 것 같다.

/// 자세히 들여다 본다.
/// -추출할 함수가 있는가?
/// -변수 이름을 명확하게 할 게 있는가?
/// -없애도 되는 변수가 있는가? -> 질의함수로 변경 playFor(aPerformance) -> 변수 인라인
/// -
/// -
/// JS vs Swift
/// 1. safety하지 않다
///  - JS에선 array[name] 같은 경우 값의 유무에 따른 처리를 하지 않는다.
///  - 반면 swift에선 optional을 이용한다.
///  - 또 JSON 파일을 디코딩할 때 Swift에선 타입 안전성을 위해 디코딩하는게 일반적이나, JS에선 디코딩 없이 바로 JSON파일에 접근한다.
/// 2. 변수, 상수의 활용 차이가 있다.
///  - JS에선 let을 선언해도 값이 바뀐다.
///  - Swift에서 값이 바뀌는 것은 var 뿐이다.
///
///  Refactoring 시 규칙
///  1. 작은 변수명을 하나를 바꿔도 컴파일 - 테스트 - 커밋을 한다.
///  2. 리팩토링하여 성능 저하가 의심되는 상황이 있더라도, 리팩토링을 잘해두면 성능개선에 유리하다.
///  - 지역변수를 제거하면 이후의 코드에서 영향력이 줄어서 코드를 추출하기에도 훨씬 편해진다.
///  3. 함수 내의 리턴 값의 이름을 result로 한다. 코드의 쓰임이 명확해진다

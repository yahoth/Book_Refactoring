import Foundation
import XCTest



// Sources 폴더 참조
let plays: Play = [
    "hamlet" : Theater(name: "Hamlet", type: "tragedy"),
    "as-like" : Theater(name: "As You Like It", type: "comedy"),
    "othello" : Theater(name: "Othello", type: "tragedy")
]

let invoice = Invoice(customer: "BigCo",
                      performances: [
                        Performance(playID: "hamlet", audience: 55),
                        Performance(playID: "as-like", audience: 35),
                        Performance(playID: "othello", audience: 40),
                      ])

// statement 메소드
func statement(invoice: Invoice, plays: Play) throws -> String {
    var totalAmount = 0
    var volumeCredits = 0
    var result = "청구내역(고객명:\(invoice.customer))\n"

    func format(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 2

        if let formattedNumber = formatter.string(from: NSNumber(value: amount)) {
            return formattedNumber
        } else {
            return "format error"
        }
    }

    for perf in invoice.performances {

        // 포인트를 적립한다.
        volumeCredits += max(perf.audience - 30, 0)

        // 희극 관객 5명마다 추가 포인트를 제공한다.
        if "comedy" == (try playFor(perf)).type {
            volumeCredits += perf.audience / 5
        }

        // 청구 내역을 출력한다.
        result += "\((try playFor(perf)).name): \(format(try amountFor(perf) / 100)) (\(perf.audience))석\n"
        totalAmount += try amountFor(perf)
    }

    result += "총액: \(format(totalAmount / 100))\n"
    result += "적립 포인트: \(volumeCredits)점\n"
    return result

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

    func playFor(_ aPerformance: Performance) throws -> Theater {
        guard let play = plays[aPerformance.playID] else { throw StatementError.playIDError("연극명과 playID가 일치하지 않습니다.")
        }
        return play
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

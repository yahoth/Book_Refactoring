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
func statement(invoice: Invoice, plays: Play) throws -> String{
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
        guard let play = plays[perf.playID] else { throw StatementError.playIDError("연극명과 playID가 일치하지 않습니다.")
        }

        var thisAmount = 0

        switch play.type {
        case "tragedy":
            thisAmount = 40000
            if perf.audience > 30 {
                thisAmount += 1000 * (perf.audience - 30)
            }
            break
        case "comedy":
            thisAmount = 30000
            if perf.audience > 20 {
                thisAmount += 10000 + (500 * (perf.audience - 20))
            }
            thisAmount += 300 * perf.audience
        default:
            throw StatementError.typeError("알 수 없는 장르: \(String(describing: play.type))")
        }

        // 포인트를 적립한다.
        volumeCredits += max(perf.audience - 30, 0)

        // 희극 관객 5명마다 추가 포인트를 제공한다.
        if "comedy" == play.type {
            volumeCredits += perf.audience / 5
        }

        // 청구 내역을 출력한다.
        result += "\(play.name): \(format(thisAmount / 100)) (\(perf.audience))석\n"
        totalAmount += thisAmount
    }

    result += "총액: \(format(totalAmount / 100))\n"
    result += "적립 포인트: \(volumeCredits)점\n"
    return result
}

test(result: try statement(invoice: invoice, plays: plays))

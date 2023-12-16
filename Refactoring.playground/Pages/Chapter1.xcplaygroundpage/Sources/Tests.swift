import Foundation

// Test
public let expected = "청구내역(고객명:BigCo)\n" + "Hamlet: $650.00 (55)석\n" + "As You Like It: $580.00 (35)석\n" + "Othello: $500.00 (40)석\n" + "총액: $1,730.00\n"+"적립 포인트: 47점\n"

public func test(result: String) {
    print(result == expected ? "Test Passed" : "Test Failed")
}

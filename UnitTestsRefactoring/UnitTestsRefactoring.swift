//
//  UnitTestsRefactoring.swift
//  UnitTestsRefactoring
//
//  Created by TAEHYOUNG KIM on 12/28/23.
//

import XCTest

final class UnitTestsRefactoring: XCTestCase {


    let refactoring = Refactoring()
    let expected = "청구내역(고객명:BigCo)\n" + "Hamlet: $650.00 (55)석\n" + "As You Like It: $580.00 (35)석\n" + "Othello: $500.00 (40)석\n" + "총액: $1,730.00\n"+"적립 포인트: 47점\n"

    func test_statement() {
        XCTAssertEqual(expected, try refactoring.statement(invoice: refactoring.invoice, plays: refactoring.plays))
    }


}

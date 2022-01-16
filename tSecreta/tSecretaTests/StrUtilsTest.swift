//
//  StrUtilsTest.swift
//  tSecretaTests
//
//  Created by Manabu Tonosaki on 2021/12/01.
//

import XCTest
import tSecreta

class StrUtilsTest: XCTestCase {

    func testMid() throws {
        let str = "ABCDEFGHIJKLMN"
        XCTAssertEqual(str.Mid(start:0, len:3), "ABC")
        XCTAssertEqual(str.Mid(start:1, len:3), "BCD")
        XCTAssertEqual(str.Mid(start:1, len:2), "BC")
        XCTAssertEqual(str.Mid(start:1, len:1), "B")
        XCTAssertEqual(str.Mid(start:1, len:0), "")
        XCTAssertEqual(str.Mid(start:11, len:3), "LMN")
        XCTAssertEqual(str.Mid(start:12, len:3), "MN")
        XCTAssertEqual(str.Mid(start:13, len:3), "N")
        XCTAssertEqual(str.Mid(start:14, len:3), "")
        XCTAssertEqual(str.Mid(start:15, len:3), "")
        XCTAssertEqual(str.Mid(start:-1, len:3), "AB")
        XCTAssertEqual(str.Mid(start:-2, len:3), "A")
        XCTAssertEqual(str.Mid(start:-3, len:3), "")
        XCTAssertEqual(str.Mid(start:-4, len:3), "")
        XCTAssertEqual(str.Mid(start:5), "FGHIJKLMN")
    }
    
    func testBoolStr() throws {
        XCTAssertTrue(Bool.parseFuzzy("true", false))
        XCTAssertTrue(Bool.parseFuzzy("ok", false))
        XCTAssertTrue(Bool.parseFuzzy("yes", false))

        XCTAssertFalse(Bool.parseFuzzy("hoge"))
        XCTAssertFalse(Bool.parseFuzzy("hoge", false))
        XCTAssertTrue(Bool.parseFuzzy("hoge", true))
    }
}

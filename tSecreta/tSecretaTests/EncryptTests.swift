//
//  EncryptTests.swift
//  tSecretaTests
//
//  Created by Manabu Tonosaki on 2021/12/01.
//

import XCTest
import tSecreta

class EncryptTests: XCTestCase {

    let TEXTSET64 = "UpcBITonNE7fhaR+AixY0re6CvGDjMXZQz5mFqJ9l42VWg8kstHSO3/1uLyKwPdb"
    let filterstr = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

    func testFusionString_1() throws {
        let instr = "TonosakiManabu"
        let outstr = fusionString(base64str: instr, filter: filterstr, textset64: TEXTSET64)
        XCTAssertEqual(outstr, "ax6GN4+3TLSw1S")
        XCTAssertEqual(outstr.count, instr.count)
    }

    func testFusionString_2() throws {
        let instr = ""
        let outstr = fusionString(base64str: instr, filter: filterstr, textset64: TEXTSET64)
        XCTAssertEqual(outstr, "")
        XCTAssertEqual(outstr.count, instr.count)
    }

    func testFusionString_3() throws {
        let instr = "A"
        let outstr = fusionString(base64str: instr, filter: filterstr, textset64: TEXTSET64)
        XCTAssertEqual(outstr, "5")
        XCTAssertEqual(outstr.count, instr.count)

        let outstr2 = fusionString(base64str: instr, filter: filterstr, textset64: TEXTSET64)
        XCTAssertEqual(outstr2, "5")    // constant result is expected.
    }

    func testFusionStringNega() throws {
        let ret = fusionString(base64str: "tonosakiManabu", filter: filterstr, textset64: TEXTSET64)
        XCTAssertNotEqual(ret, "ax6GN4+3TLSw1S")
    }
}

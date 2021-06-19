//
//  LogLevelSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class LogLevelSpec: QuickSpec {
    override func spec() {
        let encoder = LogLevelEncoder()
        describe("encoder") {
            let fileData = TestUtil.loadFile("log_level")
            let jsonList = TestUtil.parseJsonList(fileData).map { $0 as! String }
            
            it("verify data") {
                expect(jsonList.count).to(equal(6))
            }
            
            it("decode") {
                expect(try encoder.decode(jsonList[0])).to(equal(LogLevel.none))
                expect(try encoder.decode(jsonList[1])).to(equal(LogLevel.error))
                expect(try encoder.decode(jsonList[2])).to(equal(LogLevel.warning))
                do {
                    _ = try encoder.decode(jsonList[3])
                    fail("Should throw error")
                } catch {
                    expect(error.localizedDescription).to(equal("INFO log level is not available for iOS platform."))
                }
                do {
                    _ = try encoder.decode(jsonList[4])
                    fail("Should throw error")
                } catch {
                    expect(error.localizedDescription).to(equal("DEBUG log level is not available for iOS platform."))
                }
                expect(try encoder.decode(jsonList[5])).to(equal(LogLevel.verbose))
            }
            
            it("encode") {
                expect(encoder.encode(.none)).to(equal(jsonList[0]))
                expect(encoder.encode(.error)).to(equal(jsonList[1]))
                expect(encoder.encode(.warning)).to(equal(jsonList[2]))
                expect(encoder.encode(.verbose)).to(equal(jsonList[5]))
            }
        }
    }
}

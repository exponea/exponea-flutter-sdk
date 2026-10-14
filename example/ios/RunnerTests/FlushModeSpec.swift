//
//  FlushModeSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class FlushModeSpec: QuickSpec {
    override func spec() {
        let encoder = FlushModeEncoder()
        describe("encoder") {
            let fileData = TestUtil.loadFile("flush_mode")
            let jsonList = TestUtil.parseJsonList(fileData).map { $0 as! String }
            
            it("verify data") {
                expect(jsonList.count).to(equal(4))
            }
            
            it("decode") {
                switch try encoder.decode(jsonList[0]) {
                case FlushingMode.periodic(_):
                    break
                default:
                    fail("Incorrect type")
                }
                switch try encoder.decode(jsonList[1]) {
                case FlushingMode.automatic:
                    break
                default:
                    fail("Incorrect type")
                }
                switch try encoder.decode(jsonList[2]) {
                case FlushingMode.manual:
                    break
                default:
                    fail("Incorrect type")
                }
                switch try encoder.decode(jsonList[3]) {
                case FlushingMode.immediate:
                    break
                default:
                    fail("Incorrect type")
                }
            }
            
            it("encode") {
                expect(encoder.encode(.periodic(encoder.defaultPeriod))).to(equal(jsonList[0]))
                expect(encoder.encode(.automatic)).to(equal(jsonList[1]))
                expect(encoder.encode(.manual)).to(equal(jsonList[2]))
                expect(encoder.encode(.immediate)).to(equal(jsonList[3]))
            }
        }
    }
}

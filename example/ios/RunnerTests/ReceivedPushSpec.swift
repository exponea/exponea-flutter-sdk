//
//  ReceivedPushSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class ReceivedPushSpec: QuickSpec {
    override func spec() {
        describe("encode") {
            let fileData = TestUtil.loadFile("push_received")
            let jsonList = TestUtil.parseJsonList(fileData).map { $0 as! [String:Any?] }
            
            it("verify data") {
                expect(jsonList.count).to(equal(4))
            }
            
            it("empty data") {
                let data = jsonList[2]
                let push = ReceivedPush(data: [:])
                let pushMap = push.toMap()
                
                expect(try TestUtil.dictToJsonString(pushMap)).to(equal(try TestUtil.dictToJsonString(data)))
            }
            
            it("with data") {
                let data = jsonList[3]
                let push = ReceivedPush(data: ["test": true, "num": 1.23])
                let pushMap = push.toMap()
                
                expect(try TestUtil.dictToJsonString(pushMap)).to(equal(try TestUtil.dictToJsonString(data)))
            }
        }
    }
}

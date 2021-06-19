//
//  OpenedPushSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class OpenedPushSpec: QuickSpec {
    override func spec() {
        describe("encode") {
            let fileData = TestUtil.loadFile("push_opened")
            let jsonList = TestUtil.parseJsonList(fileData).map { $0 as! [String:Any?] }
            
            it("verify data") {
                expect(jsonList.count).to(equal(4))
            }
            
            it("app action") {
                let data = jsonList[1]
                let push = OpenedPush(action: .app)
                let pushMap = push.toMap()
                
                expect(try TestUtil.dictToJsonString(pushMap)).to(equal(try TestUtil.dictToJsonString(data)))
            }
            
            it("deeplink action") {
                let data = jsonList[2]
                let push = OpenedPush(action: .deeplink, data: ["test": true, "num": 1.23])
                let pushMap = push.toMap()
                
                expect(try TestUtil.dictToJsonString(pushMap)).to(equal(try TestUtil.dictToJsonString(data)))
            }
            
            it("web action") {
                let data = jsonList[3]
                let push = OpenedPush(action: .web, url: "https://a.b.c")
                let pushMap = push.toMap()
                
                expect(try TestUtil.dictToJsonString(pushMap)).to(equal(try TestUtil.dictToJsonString(data)))
            }
        }
    }
}

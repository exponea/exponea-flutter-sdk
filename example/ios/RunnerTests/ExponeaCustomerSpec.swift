//
//  ExponeaCustomerSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class ExponeaCustomerSpec: QuickSpec {
    override func spec() {
        describe("parse") {
            let fileData = TestUtil.loadFile("customer")
            let jsonList = TestUtil.parseJsonList(fileData).map { $0 as! [String:Any?] }
            
            it("verify data") {
                expect(jsonList.count).to(equal(4))
            }
            
            it("emoty map") {
                let data = jsonList[0]
                let customer = try ExponeaCustomer(data)
                
                expect(customer.ids.isEmpty).to(equal(true))
                expect(customer.properties.isEmpty).to(equal(true))
            }
            
            it("empty customer") {
                let data = jsonList[1]
                let customer = try ExponeaCustomer(data)
                
                expect(customer.ids.isEmpty).to(equal(true))
                expect(customer.properties.isEmpty).to(equal(true))
            }
            
            it("customer with registered email") {
                let data = jsonList[2]
                let customer = try ExponeaCustomer(data)

                expect(customer.ids.count).to(equal(1))
                expect(customer.ids["registered"]).to(equal("test@mail.com"))
                expect(customer.properties.isEmpty).to(equal(true))
            }
            
            it("customer with everything") {
                let data = jsonList[3]
                let customer = try ExponeaCustomer(data)
                
                expect(customer.ids.count).to(equal(1))
                expect(customer.ids["registered"]).to(equal("test@mail.com"))
                expect(customer.properties.count).to(equal(4))
                expect(customer.properties["str_test"]?.jsonValue).to(equal(.string("abc-123")))
                expect(customer.properties["double_test"]?.jsonValue).to(equal(.double(123.987)))
                expect(customer.properties["bool_test"]?.jsonValue).to(equal(.bool(true)))
                expect(customer.properties["int_test"]?.jsonValue).to(equal(.double(109.0)))
            }
        }
    }
}

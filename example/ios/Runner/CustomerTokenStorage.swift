//
//  CustomerTokenStorage.swift
//  Runner
//
//  Created by Adam Mihalik on 02/03/2023.
//

import Foundation
import ExponeaSDK

class CustomerTokenStorage {

    public static var shared = CustomerTokenStorage()

    private let semaphore: DispatchQueue = DispatchQueue(
        label: "CustomerTokenStorageLockingQueue",
        attributes: .concurrent
    )
    
    private var currentConf: Config?

    private var tokenCache: String?

    private var lastTokenRequestTime: Double = 0

    func retrieveJwtToken() -> String? {
        validateChangedConf()
        let now = Date().timeIntervalSince1970
        let timeDiffMinutes = abs(now - lastTokenRequestTime) / 60.0
        if timeDiffMinutes < 5 {
            // allows request for token once per 5 minutes, doesn't care if cache is NULL
            return tokenCache
        }
        lastTokenRequestTime = now
        if tokenCache != nil {
            // return cached value
            return tokenCache
        }
        semaphore.sync(flags: .barrier) {
            // recheck nullity just in case
            if tokenCache == nil {
                tokenCache = loadJwtToken()
            }
        }
        return tokenCache
    }
    
    private func validateChangedConf() {
        let storedConf = loadConfiguration()
        if currentConf != storedConf {
            // reset token
            tokenCache = nil
            lastTokenRequestTime = 0
        }
        currentConf = storedConf
    }

    private func loadJwtToken() -> String? {
        currentConf = loadConfiguration()
        guard let host = currentConf?.host,
              let projectToken = currentConf?.projectToken,
              let publicKey = currentConf?.publicKey,
              let customerIds = currentConf?.customerIds,
              customerIds.count > 0 else {
            Exponea.logger.log(.verbose, message: "CustomerTokenStorage not configured yet")
            return nil
        }
        guard let url = URL(string: "\(host)/webxp/exampleapp/customertokens") else {
            Exponea.logger.log(.error, message: "Invalid URL host \(host) for CustomerTokenStorage")
            return nil
        }
        var requestBody: [String: Codable] = [
            "project_id": projectToken,
            "kid": publicKey,
            "sub": customerIds
        ]
        do {
            let postData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = postData
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            let httpSemaphore = DispatchSemaphore(value: 0)
            var httpResponseData: Data?
            var httpResponse: URLResponse?
            let httpTask = URLSession.shared.dataTask(with: request) {
                httpResponseData = $0
                httpResponse = $1
                _ = $2
                httpSemaphore.signal()
            }
            httpTask.resume()
            _ = httpSemaphore.wait(timeout: .distantFuture)
            if let httpResponse = httpResponse as? HTTPURLResponse {
                // this is optional check - we looking for 404 posibility
                switch httpResponse.statusCode {
                case 404:
                    // that is fine, only some BE has this endpoint
                    return nil
                case 300..<599:
                    Exponea.logger.log(
                        .error,
                        message: "Example token receiver returns \(httpResponse.statusCode)"
                    )
                    return nil
                default:
                    break
                }
            }
            guard let httpResponseData = httpResponseData else {
                Exponea.logger.log(.error, message: "Example token response is empty")
                return nil
            }
            let responseData = try JSONDecoder().decode(TokenResponse.self, from: httpResponseData)
            if responseData.token == nil {
                Exponea.logger.log(.error, message: "Example token received NULL")
            }
            return responseData.token
        } catch let error {
            Exponea.logger.log(.error, message: "Example token cannot be parsed due error \(error.localizedDescription)")
            return nil
        }
    }
    
    private func loadConfiguration() -> Config {
        let prefs = UserDefaults.standard
        var customerIds: [String: String]?
        if let customerIdsString = prefs.string(forKey: "flutter.customer_ids"),
           let customerIdsData = customerIdsString.data(using: .utf8),
           let loadedIds = try? JSONDecoder().decode([String: String].self, from: customerIdsData) {
            customerIds = loadedIds
        }
        return Config(
            // See config.dart how are stored fields
            host: prefs.string(forKey: "flutter.base_url"),
            projectToken: prefs.string(forKey: "flutter.project_token"),
            publicKey: prefs.string(forKey: "flutter.advanced_auth_token"),
            // See home.dart how are stored customerIds in _identifyCustomer method
            customerIds: customerIds
        )
    }
}

struct TokenResponse: Codable {
    var token: String?
    var expiration: Int?

    enum CodingKeys: String, CodingKey {
        case token = "customer_token"
        case expiration = "expire_time"
    }
}

struct Config: Equatable {
    var host: String?
    var projectToken: String?
    var publicKey: String?
    var customerIds: [String: String]?
}

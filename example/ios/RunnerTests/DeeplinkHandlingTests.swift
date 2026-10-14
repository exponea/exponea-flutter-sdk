import XCTest

@testable import Runner

/// Inbound link handling in the example host: custom-scheme campaign tracking and
/// single delivery of each link to Dart.
final class DeeplinkHandlingTests: XCTestCase {
  private var tracked: [URL] = []
  private var sent: [String] = []
  private var bridge: DeeplinkBridge!
  private var originalTracker: ((URL) -> Void)!

  override func setUp() {
    super.setUp()
    tracked = []
    sent = []
    bridge = DeeplinkBridge()
    bridge.send = { [unowned self] in self.sent.append($0) }
    originalTracker = ExampleDeeplinkHostPlugin.trackCampaignClick
    ExampleDeeplinkHostPlugin.trackCampaignClick = { [unowned self] in self.tracked.append($0) }
  }

  override func tearDown() {
    ExampleDeeplinkHostPlugin.trackCampaignClick = originalTracker
    super.tearDown()
  }

  func testCustomSchemeLinkIsTrackedAndForwarded() {
    let url = URL(string: "exponea://track?xnpe_cmp=abc")!
    _ = bridge.takeInitialLink()

    ExampleDeeplinkHostPlugin.handleIncomingURL(url, isUniversalLink: false, bridge: bridge)

    XCTAssertEqual(tracked, [url])
    XCTAssertEqual(sent, [url.absoluteString])
  }

  func testUniversalLinkIsForwardedButNotTrackedAgain() {
    let url = URL(string: "https://mobile-sdk-example-apps.web.app/exponea/flush")!
    _ = bridge.takeInitialLink()

    ExampleDeeplinkHostPlugin.handleIncomingURL(url, isUniversalLink: true, bridge: bridge)

    XCTAssertTrue(tracked.isEmpty)
    XCTAssertEqual(sent, [url.absoluteString])
  }

  func testColdStartLinkIsDeliveredOnlyThroughInitialLink() {
    bridge.ingestLink("exponea://flush")

    XCTAssertTrue(sent.isEmpty)
    XCTAssertEqual(bridge.takeInitialLink(), "exponea://flush")
    XCTAssertTrue(sent.isEmpty)
  }

  func testLinkAfterInitialFetchIsSentOnce() {
    XCTAssertNil(bridge.takeInitialLink())

    bridge.ingestLink("exponea://track")

    XCTAssertEqual(sent, ["exponea://track"])
  }
}

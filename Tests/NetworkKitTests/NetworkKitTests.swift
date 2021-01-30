import XCTest
import UniformTypeIdentifiers
@testable import NetworkKit

enum APIType: String, APIRepresentable {
    case v1 = "5da1e9ae76c28f0014bbe25f"
    
    var subURL: String {
        rawValue
    }
    
    var endPoint: String {
        switch self {
        case .v1: return ""
        }
    }
}

enum Host: String, HostRepresentable {
    
    case server = "mockapi.io"
    
    var host: String { rawValue }
    
    var defaultHeaders: HTTPHeaderParameters { [:] }
    
    var defaultAPIType: APIRepresentable? { APIType.v1 }
    
    var defaultURLQuery: URLQuery? { nil }
}

//extension Environment {
//    static let production = Environment(value: "")
//}

enum MockPoint: ConnectionRepresentable {
    
    case allUsers
    
    var path: String { "/users" }
    
    var name: String? { "Users" }
    
    var method: HTTPMethod { .get }
    
    var httpHeaders: HTTPHeaderParameters { [:] }
    
    var host: HostRepresentable { Host.server }
    
    var defaultQuery: URLQuery? { nil }
    
}

enum MockPointError: ConnectionRepresentable {
    
    case allUsers
    
    var path: String { "/users1" }
    
    var name: String? { "Users" }
    
    var method: HTTPMethod { .get }
    
    var httpHeaders: HTTPHeaderParameters { [:] }

    var host: HostRepresentable { Host.server }
    
    var defaultQuery: URLQuery? { nil }
    
}

struct User: Codable, Equatable {
    let id, createdAt, name: String?
    let avatar: String?
}

typealias Users = [User]

final class NetworkKitTests: XCTestCase {
    
    
//    var cancel: AnyCancellable?
//
//    @available(OSX 10.15, *)
//    func testURLSession() {
//        cancel = URLSession.shared.dataTaskPublisher(for: URL(string: "")!)
//            .catch { (error) -> URLSession.DataTaskPublisher in
//                print(error == URLError.network)
//                return URLSession.shared.dataTaskPublisher(for: URL(string: "11")!)
//            }
//            .map(\.data)
//            .decode(type: Users.self, decoder: JSONDecoder())
//            .sink(receiveCompletion: { (error) in
//
//            }, receiveValue: { (users) in
//                print(users)
//            })
//    }
//
//    var cancellable: NetworkCancellable?
//
//    func testExampleOld() {
//        URLSession.shared.dataTask(with: URL(string: "high quality")!) { (data, response, error) in
//            if let error = error {
//                URLSession.shared.dataTask(with: URL(string: "low quality")!) { (data, response, error) in
//                    if let error = error {
//                        // fail
//                    } else if let data = data {
//                        // completion(UIImage(data: data)
//                    }
//                }
//
//            } else if let data = data {
//                // completion(UIImage(data: data)
//            }
//        }
//        .resume()
//    }
    
    
    var users: Users = [] {
        willSet {
            print("Setting value: \(newValue)")
            expecatation.fulfill()
        }
    }
    
    var cancellable: AnyCancellable?

    let expecatation = XCTestExpectation()
    
    @available(iOS 14.0, *)
    func testMime() {
        print(UTType.html.preferredMIMEType)
    }
    
    func testExample() {
        cancellable = NKSession.shared.dataTask {
            NKRequest(to: MockPoint.allUsers)
        }
        .map(\.data)
        .decode(type: Users.self, decoder: JSONDecoder())
        .replaceError(with: [User(id: "12", createdAt: "Today", name: "Guest User", avatar: nil)])
        .assign(to: \.users, on: self)
        
        cancellable?.cancel()
        
        wait(for: [expecatation], timeout: 60)
    }
    
    func testPerformanceExample() {
        measure {
            testExample()
        }
    }
    
    static var allTests = [
        ("testExample", testExample, "testPerformanceExample", testPerformanceExample),
    ]
}

import XCTest
@testable import ToDo

class URLSessionDataTaskTests: XCTestCase {
    func testSuccessfulRequest() async throws {
        // Given
        let url = URL(string: "https://catfact.ninja/fact")!
        let urlRequest = URLRequest(url: url)
        
        // When
        let (data, response) = try await URLSession.shared.dataTask(for: urlRequest)
        
        // Then
        XCTAssertNotNil(data)
        XCTAssertNotNil(response)
    }
    
    func testCancelledRequest() async {
        // Given
        let url = URL(string: "https://catfact.ninja/fact")!
        let urlRequest = URLRequest(url: url)
        
        // When
        let task = Task {
            do {
                let (_, _) = try await URLSession.shared.dataTask(for: urlRequest)
                
                // Then
                XCTFail("Request should have been cancelled.")
            } catch is CancellationError {
                // Then
                XCTAssert(true)
            } catch {
                // Then
                XCTFail("Request should have been cancelled.")
            }
        }
        
        task.cancel()
        
        // Then
        XCTAssertTrue(task.isCancelled)
    }
}

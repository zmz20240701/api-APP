import Foundation

// 任何从 API 抓取数据的情况都可以使用这一套代码


// 定义枚举的意义是直接书写易出错,枚举可以降低这种风险; 可读性更好, 单纯的字符串易让人摸不着头脑
enum HTTPError: Error {
    case badURL, invalidURL, badResponse, errorDecodingData
}

enum HttpMethod: String {
    case PUT, GET, POST, DELETE // rawValue就是自己
}

enum MIMEType: String {
    case JSON = "application/json"
}

enum HttpHeader: String {
    case contentType = "Content-Type"
}

// 这个类和数据模型一起传递给 viewModel, 由 viewModel 跟视图进行交互
class HttpClient: NSObject, URLSessionDelegate {
    private override init() {} // 禁止实例化
    static let shared = HttpClient()
    
    // 从 url 中抓取数据
    func fetch<T: Codable>(url: URL) async throws -> [T] {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil) // 使用 delegate 进行证书处理
        
        let (data, response) = try await session.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw HTTPError.badResponse
        }
        
        guard let object = try? JSONDecoder().decode([T].self, from: data) else {
            throw HTTPError.errorDecodingData
        }
        return object
    }
    
    // 向 url 送走数据, 送走数据需要的参数有点多. fetch 的操作对象是 url, send 操作的是 Request
    func send<T: Codable>(to url: URL, object: T, httpMethod: String) async throws {
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        // HTTP 请求的的对象
        var request = URLRequest(url: url) // 使用url来初始化一个Request实例
        
        request.httpMethod = httpMethod
        // 添加头部字段 Content-Type: "application/json"
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HttpHeader.contentType.rawValue)
        request.httpBody = try? JSONEncoder().encode(object)
        
        // 创建请求, 配置请求, 发送请求
        let (_, response) = try await session.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw HTTPError.badResponse
        }
        
    }
   // 删除操作我们需要一个 ID
    func delete(at id: UUID, url: URL) async throws {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.DELETE.rawValue
        
        let (_, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw HTTPError.badResponse
        }
    }
    
    // 跳过证书验证
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential) // 自动接受自签名证书
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

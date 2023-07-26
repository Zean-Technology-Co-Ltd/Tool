//
//  LoggingPlugin.swift
//  NiuNiuRent
//
//  Created by 张泉 on 2023/4/19.
//

import Moya
import Result

extension LoggingPlugin {
    static let shared = LoggingPlugin(verbose: true, responseDataFormatter: prettyPrintFormatter)
}

public final class LoggingPlugin: PluginType {
    fileprivate let loggerId = "Moya_Logger"
    fileprivate let dateFormatString = "dd/MM/yyyy HH:mm:ss"
    fileprivate let dateFormatter = DateFormatter()
    fileprivate let separator = ", "
    fileprivate let terminator = "\n"
    fileprivate let cURLTerminator = "\\\n"
    fileprivate let output: (_ separator: String, _ terminator: String, _ items: Any...) -> Void
    fileprivate let requestDataFormatter: ((Data) -> (String))?
    fileprivate let responseDataFormatter: ((Data) -> (Data))?
    
    /// If true, also logs response body data.
    public let isVerbose: Bool
    public let cURL: Bool
    
    public init(verbose: Bool = false, cURL: Bool = false, output: ((_ separator: String, _ terminator: String, _ items: Any...) -> Void)? = nil, requestDataFormatter: ((Data) -> (String))? = nil, responseDataFormatter: ((Data) -> (Data))? = nil) {
        self.cURL = cURL
        self.isVerbose = verbose
        self.output = output ?? LoggingPlugin.reversedPrint
        self.requestDataFormatter = requestDataFormatter
        self.responseDataFormatter = responseDataFormatter
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        if let request = request as? CustomDebugStringConvertible, cURL {
            output(separator, terminator, request.debugDescription)
            return
        }
        outputItems(logNetworkRequest(request.request as URLRequest?))
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            outputItems(logNetworkResponse(response, data: response.data, target: target))
        } else {
            outputItems(logNetworkResponse(nil, data: nil, target: target))
        }
    }
    
    fileprivate func outputItems(_ items: [String]) {
        if isVerbose {
            items.forEach { output(separator, terminator, $0) }
        } else {
            output(separator, terminator, items)
        }
    }
}

private extension LoggingPlugin {
    
    var date: String {
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: Date())
    }
    
    func format(_ loggerId: String, date: String, identifier: String, message: String) -> String {
        return "\(loggerId): [\(date)] \(identifier): \(message)"
    }
    
    func logNetworkRequest(_ request: URLRequest?) -> [String] {
        
        var flag = String(repeatElement("*", count: 25))
        flag = "\n\(flag) [ Request ] \(flag)\n"
        var output = [flag]
        
        output += [format(loggerId, date: date, identifier: "Request", message: request?.description ?? "(invalid request)")]
        
        let spacing = String(repeatElement(" ", count: 35 + 16))
        if let headers = request?.allHTTPHeaderFields {
            output += [format(loggerId, date: date, identifier: "Request Headers", message: "")]
            headers.map { spacing + $0.key + ":  " + $0.value }
                .forEach { output += [$0] }
        }
        
        if let bodyStream = request?.httpBodyStream {
            output += [format(loggerId, date: date, identifier: "Request Body Stream", message: bodyStream.description)]
        }
        
        if let httpMethod = request?.httpMethod {
            output += [format(loggerId, date: date, identifier: "HTTP Request Method", message: httpMethod)]
        }
        
        if let body = request?.httpBody, let stringOutput = requestDataFormatter?(body) ?? String(data: body, encoding: .utf8), isVerbose {
            output += [format(loggerId, date: date, identifier: "Request Body", message: stringOutput)]
        }
        
        output += ["\n"]
        
        return output
    }
    
    func logNetworkResponse(_ response: Response?, data: Data?, target: TargetType) -> [String] {
        guard let response = response else {
            return [format(loggerId, date: date, identifier: "Response", message: "Received empty network response for \(target).")]
        }
        
        var flag = String(repeatElement("*", count: 25))
        flag = "\n\(flag) [ Response ] \(flag)\n"
        var output = [flag]
        
        output += [format(loggerId, date: date, identifier: "Response", message: response.loggingDescription)]
        
        output += ["\n"]
        
        return output
    }
}

fileprivate extension LoggingPlugin {
    static func reversedPrint(_ separator: String, terminator: String, items: Any...) {
        for item in items {
            print(item, separator: separator, terminator: terminator)
        }
    }
}

private func prettyPrintFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data
    }
}

private extension Response {
    var loggingDescription: String {
        
        guard let request = request else {
            return "Status Code: \(statusCode)\n"
        }
        
        guard let url = request.url else {
            return "Status Code: \(statusCode)\n"
        }
        
        return "\(url) \n Status Code: \(statusCode)\n"
    }
}

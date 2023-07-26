//
//  Logging.swift
//  NiuNiuRent
//
//  Created by 张泉 on 2023/4/19.
//

import SwiftyBeaver

let log = Logger()

class Logger: NSObject {
    
    let log = SwiftyBeaver.self
    
    override init() {
        super.init()
        
        let console = ConsoleDestination()
        self.log.addDestination(console)
    }
    
    func error(_ msg: Any,
               _ file: String = #file,
               _ function: String = #function,
               _ line: Int = #line,
               context: Any? = nil)
    {
        self.log.error(msg, file, function, line: line, context: context)
    }
    
    func warning(_ msg: Any,
                 _ file: String = #file,
                 _ function: String = #function,
                 _ line: Int = #line,
                 context: Any? = nil)
    {
        self.log.warning(msg, file, function, line: line, context: context)
    }
    
    func debug(_ msg: Any,
               _ file: String = #file,
               _ function: String = #function,
               _ line: Int = #line,
               context: Any? = nil)
    {
        self.log.debug(msg, file, function, line: line, context: context)
    }
    
    func info(_ msg: Any,
              _ file: String = #file,
              _ function: String = #function,
              _ line: Int = #line,
              context: Any? = nil)
    {
        self.log.info(msg, file, function, line: line, context: context)
    }
    
    func verbose(_ msg: Any,
                 _ file: String = #file,
                 _ function: String = #function,
                 _ line: Int = #line,
                 context: Any? = nil)
    {
        self.log.verbose(msg, file, function, line: line, context: context)
    }
}




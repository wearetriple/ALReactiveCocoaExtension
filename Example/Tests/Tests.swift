import UIKit
import XCTest
import ALReactiveCocoaExtension
import ReactiveCocoa

enum ALErrorType : ErrorType {
    case TestError
}

class Tests: XCTestCase {
    
    func testCastingSuccess() {
        let expectation = expectationWithDescription("This will cast AnyObject to Double")
        
        let producer:SignalProducer<AnyObject, NSError> = SignalProducer(value: 50.0)
        var errorValue:ErrorType?
        var doubleValue:Double?
        
        producer.onError({ (error) in
            errorValue = error
            expectation.fulfill()
        }).onNextAs { (number:Double) in
            doubleValue = number
        }.onCompleted({ 
            expectation.fulfill()
        }).start()
        
        waitForExpectationsWithTimeout(10.0) { (_) in
            XCTAssertNil(errorValue)
            XCTAssertNotNil(doubleValue)
        }
    }
    
    func testCastingFailure() {
        let expectation = expectationWithDescription("This will fail to cast AnyObject to String")
        
        let producer:SignalProducer<AnyObject, NSError> = SignalProducer(value: 50.0)
        var errorValue:ErrorType?
        var stringValue:String?
        
        producer.onNextAs { (string:String) in
            stringValue = string
        }.onError({ (error) in
            errorValue = error
            expectation.fulfill()
        }).onCompleted({
            expectation.fulfill()
        }).start()
        
        waitForExpectationsWithTimeout(10.0) { (_) in
            XCTAssertNotNil(errorValue)
            XCTAssertNil(stringValue)
        }
    }
    
    func testErrorCast(){
        
        let producer:SignalProducer<AnyObject, ALErrorType> = SignalProducer(value: "String")
        
        producer.flatMapErrorToNSError().onError { (error) -> () in
            print(error.userInfo)
        }
    }
    
}

extension SignalProducerType {
    func flatMapErrorToNSError() -> SignalProducer<Value, NSError> {
        return flatMapError { (error) -> SignalProducer<Value, NSError> in
            return SignalProducer(error: error as NSError)
        }
    }
}

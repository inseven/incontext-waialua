// MIT License
//
// Copyright (c) 2023 Jason Barrie Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

import XCTest
@testable import ic3

class ParserTests: XCTestCase {

    func testTrue() {
        XCTAssertTrue(true)
    }

    func testParseInt() throws {
        XCTAssertEqual(try SetOperation(string: "set cheese = 2"),
                       SetOperation(identifier: "cheese", result: .int(2)))
    }

    func testParseDouble() throws {
        XCTAssertEqual(try SetOperation(string: "set cheese = 3.14"),
                       SetOperation(identifier: "cheese", result: .double(3.14)))
    }

    func testParseString() throws {
        XCTAssertEqual(try SetOperation(string: "set cheese = \"two\""),
                       SetOperation(identifier: "cheese", result: .string("two")))
    }

    func testParseFunction() throws {
        let expected = SetOperation(identifier: "cheese",
                                    result: .executable(.init(operand: nil,
                                                              operation: .call(.init(name: "titlecase",
                                                                                     arguments: [])))))
        XCTAssertEqual(try SetOperation(string: "set cheese = titlecase()"), expected)
    }

    func testParseFunctionWithSingleArgument() throws {
        let arguments = [NamedResultable(name: "name", result: .string("fromage"))]
        let expected = SetOperation(identifier: "cheese",
                                    result: .executable(.init(operand: nil,
                                                              operation: .call(.init(name: "titlecase",
                                                                                     arguments: arguments)))))
        XCTAssertEqual(try SetOperation(string: "set cheese = titlecase(name: \"fromage\")"), expected)
    }

    // TODO: "hello".uppercase() should work
    // TODO: foo."hello" should fail


    func testParseSymbol() throws {
        let expected = SetOperation(identifier: "cheese",
                                    result: .executable(.init(operand: nil,
                                                              operation: .lookup("foo"))))
        XCTAssertEqual(try SetOperation(string: "set cheese = foo"), expected)
    }

    func testParseKeyPath() throws {
        let fooLookup = Resultable.executable(.init(operand: nil,
                                                    operation: .lookup("foo")))
        let expected = SetOperation(identifier: "cheese",
                                    result: .executable(.init(operand: fooLookup,
                                                              operation: .lookup("bar"))))
        XCTAssertEqual(try SetOperation(string: "set cheese = foo.bar"), expected)
    }

    func testParseLookupAndCall() throws {
        let fooLookup = Resultable.executable(.init(operand: nil,
                                                    operation: .lookup("foo")))
        let call = FunctionCall(name: "bar", arguments: [])
        let expected = SetOperation(identifier: "cheese",
                                    result: .executable(.init(operand: fooLookup,
                                                              operation: .call(call))))
        XCTAssertEqual(try SetOperation(string: "set cheese = foo.bar()"), expected)
    }

    func testParseStringWithCall() throws {
        let arguments = [NamedResultable(name: "name", result: .string("fromage"))]
        let expected = SetOperation(identifier: "cheese",
                                    result: .executable(.init(operand: .string("fromage"),
                                                              operation: .call(.init(name: "titlecase",
                                                                                     arguments: arguments)))))
        XCTAssertEqual(try SetOperation(string: "set cheese = \"fromage\".titlecase(name: \"fromage\")"), expected)
    }

//    func testParsePath() throws {
//        let result = try SetExpression.parse("set cheese = foo.bar", using: SetExpression.Lexer.self)
//        print(result)
//    }
//
//    // The parser result should be something like:
//    // Apply(FunctionCall("visit", [("country", "France")]), Apply(FunctionCall("travel", []), foo))
//
//    func testParseMultipleCalls() throws {
//        let result = try SetExpression.parse("set cheese = foo.travel().visit(country: \"France\")", using: SetExpression.Lexer.self)
//        print(result)
//
//
//    }

    // TODO: Check parsing top-level literal fails.
    // TODO: What's the difference between a property getter and a function call?
    // e.g. How does foo.bar().baz look in the output?

}

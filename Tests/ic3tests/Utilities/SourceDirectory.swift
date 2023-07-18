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

@testable import ic3

class SourceDirectory {

    enum Location {
        case root
        case content
    }

    let rootURL: URL
    let contentURL: URL

    lazy var site: Site = {
        try! Site(rootURL: rootURL)
    }()

    init(rootURL: URL) throws {
        self.rootURL = rootURL
        self.contentURL = rootURL.appendingPathComponent("content", isDirectory: true)
    }

    func url(for location: Location) -> URL {
        switch location {
        case .root:
            return rootURL
        case .content:
            return contentURL
        }
    }

    func add(_ path: String, location: Location = .root, contents: String) throws -> File {
        let rootURL = url(for: location)
        assert(!path.hasPrefix("/"), "Paths must be relative")
        let fileURL = URL(filePath: path, relativeTo: rootURL)
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
        return File(url: fileURL, contentModificationDate: try FileManager.default.modificationDateOfItem(at: fileURL))
    }

}

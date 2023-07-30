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

import Stencil
import SwiftSoup

struct DocumentContext: EvaluationContext, DynamicMemberLookup {

    let store: Queryable
    let document: Document

    func documents(query: QueryDescription) throws -> [DocumentContext] {
        return try store.documents(query: query)
            .map { DocumentContext(store: store, document: $0) }
    }

    func relativeSourcePath(for relativePath: String) -> String {
        let rootURL = URL(fileURLWithPath: "/", isDirectory: true)
        let documentURL = URL(filePath: document.relativeSourcePath, relativeTo: rootURL)
        let parentURL = documentURL.deletingLastPathComponent()
        let url = parentURL.appendingPathComponent(relativePath)
        return url.relativePath
    }

    // TODO: Implement the thumbnail getter.

    // Generic transform; could be a protocol?
    // Takes a selector, and outputs the replacement for the selector?
    // Enough information injected (store, document, etc) to allow for correction of URLs and application of templates.
    // Perhaps there are off-the-shelf ones which perform a lookup and apply a template, and ones which just rewrite URLs
    // for matching selectors.
    // TODO: HTML media queries sound really nice.
    // TODO: Should the image transform _always_ place all image sizes into a fixed place?
    // Markdown files should be handled one way, and regular HTML tags should be handled another, since there's no way
    // that a user can write good image tags from Markdown.
    // TODO: Perhaps all document types can have an 'inline' template that is specified in the configuration and used
    //       whenever they're rendered inline.  ****IMPORTANT****
    /*
     .replaceInline("//img", .relativeLookup("@src"))  <-- this would replace all 'img' tags with an inline template
                                                           rendered with the document based on the relative lookup of
                                                           the src property of the tag.
     .convertRelativePaths("//img[@src]") <-- convert any relative paths to the new primary destination in the site
                                              note: this would require us to actually designate a primary file which
                                              we're not currently doing in the case of an image.
     */
    let transforms: [Transformer] = [
        ImageDocumentTransform(),
    ]

    // TODO: Add a render cache for pages?
    // TODO: Unique document contexts in a cache to save loading them every time; query for the ids, and then and look
    //       them up by URL?

    func html() throws -> String {

        // The current implementation _seems_ to only replace markdown generated images with the inline image.html format.
        // It would probably be better if we could make this either an explicit function of the site, or clear in the code.
        // How do we differentiate between things the user wants to take manual control over and things we should do ourselves?
        // TODO: Can the template selection be done by mimetype?

        let content = try SwiftSoup.parse(document.contents)
        for transform in transforms {
            try transform.transform(store: store, document: self, content: content)
        }

        let html = try content.html()

        // TODO: Run the document's preferred templating engine on the html.

        return html
    }

    func lookup(_ name: String) throws -> Any? {
        switch name {
        case "query": return Function { (name: String) -> [DocumentContext] in
            guard let queries = document.metadata["queries"] as? [String: Any],
                  let query = queries[name] else {
                throw InContextError.unknownQuery(name)
            }
            return try documents(query: try QueryDescription(definition: query))
        }
        case "children": return Function { () -> [DocumentContext] in
            return try documents(query: QueryDescription(parent: document.url))
        }
        case "parent": return Function { () -> DocumentContext? in
            return try documents(query: QueryDescription(url: document.parent)).first
        }
        case "child": return Function { (relativePath: String) -> DocumentContext? in
            let relativeSourcePath = relativeSourcePath(for: relativePath)
            return try documents(query: QueryDescription(relativeSourcePath: relativeSourcePath)).first
        }
        default:
            break
        }
        guard let value = self[dynamicMember: name] else {
            throw InContextError.unknownSymbol(name)
        }
        return value
    }

    // TODO: Errors if values don't exist?
    // TODO: Support auto-executing callables in a single dispatch model.
    subscript(dynamicMember member: String) -> Any? {
        if member == "content" {
            return document.contents
        } else if member == "date" {
            return document.date
        } else if member == "html" {
            // TODO: Don't crash!
            return try! html()
        } else if member == "url" {
            return document.url
        }
        return document.metadata[member]
    }

}

// TODO: I could support initializing sets to make it easier to generate tags efficiently.

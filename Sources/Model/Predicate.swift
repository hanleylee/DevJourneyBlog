//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation

struct Predicate<Target> {
    let matches: (Target) -> Bool

    /// Initialize a new predicate instance using a given matching closure.
    /// You can also create predicates based on operators and key paths.
    /// - parameter matcher: The matching closure to use.
    public init(matcher: @escaping (Target) -> Bool) {
        matches = matcher
    }
}

extension Predicate {
    /// Create a predicate that matches any candidate.
    static var any: Self { Predicate { _ in true } }

    /// Create an inverse of this predicate - that is one that matches
    /// all candidates that this predicate does not, and vice versa.
    func inverse() -> Self {
        Predicate { !self.matches($0) }
    }
}

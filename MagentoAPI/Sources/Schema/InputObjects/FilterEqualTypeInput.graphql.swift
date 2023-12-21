// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Defines a filter that matches the input exactly.
public struct FilterEqualTypeInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    eq: GraphQLNullable<String> = nil,
    `in`: GraphQLNullable<[String?]> = nil
  ) {
    __data = InputDict([
      "eq": eq,
      "in": `in`
    ])
  }

  /// Use this attribute to exactly match the specified string. For example, to filter on a specific category ID, specify a value such as `5`.
  public var eq: GraphQLNullable<String> {
    get { __data["eq"] }
    set { __data["eq"] = newValue }
  }

  /// Use this attribute to filter on an array of values. For example, to filter on category IDs 4, 5, and 6, specify a value of `["4", "5", "6"]`.
  public var `in`: GraphQLNullable<[String?]> {
    get { __data["in"] }
    set { __data["in"] = newValue }
  }
}

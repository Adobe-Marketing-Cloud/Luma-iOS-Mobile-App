// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Defines a filter that performs a fuzzy search.
public struct FilterMatchTypeInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    match: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "match": match
    ])
  }

  /// Use this attribute to exactly match the specified string. For example, to filter on a specific SKU, specify a value such as `24-MB01`.
  public var match: GraphQLNullable<String> {
    get { __data["match"] }
    set { __data["match"] = newValue }
  }
}

// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Defines a filter that matches a range of values, such as prices or dates.
public struct FilterRangeTypeInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    from: GraphQLNullable<String> = nil,
    to: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "from": from,
      "to": to
    ])
  }

  /// Use this attribute to specify the lowest possible value in the range.
  public var from: GraphQLNullable<String> {
    get { __data["from"] }
    set { __data["from"] = newValue }
  }

  /// Use this attribute to specify the highest possible value in the range.
  public var to: GraphQLNullable<String> {
    get { __data["to"] }
    set { __data["to"] = newValue }
  }
}

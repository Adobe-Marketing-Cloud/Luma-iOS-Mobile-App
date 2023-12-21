// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Defines the dynamic block filter. The filter can identify the block type, location and IDs to return.
public struct DynamicBlocksFilterInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    audience_id: GraphQLNullable<FilterEqualTypeInput> = nil,
    dynamic_block_uids: GraphQLNullable<[ID?]> = nil,
    locations: GraphQLNullable<[GraphQLEnum<DynamicBlockLocationEnum>?]> = nil,
    type: GraphQLEnum<DynamicBlockTypeEnum>
  ) {
    __data = InputDict([
      "audience_id": audience_id,
      "dynamic_block_uids": dynamic_block_uids,
      "locations": locations,
      "type": type
    ])
  }

  /// Input to filter dynamic blocks by user's audience ID.
  public var audience_id: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["audience_id"] }
    set { __data["audience_id"] = newValue }
  }

  /// An array of dynamic block UIDs to filter on.
  public var dynamic_block_uids: GraphQLNullable<[ID?]> {
    get { __data["dynamic_block_uids"] }
    set { __data["dynamic_block_uids"] = newValue }
  }

  /// An array indicating the locations the dynamic block can be placed.
  public var locations: GraphQLNullable<[GraphQLEnum<DynamicBlockLocationEnum>?]> {
    get { __data["locations"] }
    set { __data["locations"] = newValue }
  }

  /// A value indicating the type of dynamic block to filter on.
  public var type: GraphQLEnum<DynamicBlockTypeEnum> {
    get { __data["type"] }
    set { __data["type"] = newValue }
  }
}

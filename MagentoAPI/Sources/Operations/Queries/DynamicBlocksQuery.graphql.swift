// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DynamicBlocksQuery: GraphQLQuery {
  public static let operationName: String = "dynamicBlocks"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query dynamicBlocks($input: DynamicBlocksFilterInput) {
        dynamicBlocks(input: $input) {
          __typename
          items {
            __typename
            content {
              __typename
              html
            }
          }
        }
      }
      """#
    ))

  public var input: GraphQLNullable<DynamicBlocksFilterInput>

  public init(input: GraphQLNullable<DynamicBlocksFilterInput>) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: MagentoAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("dynamicBlocks", DynamicBlocks.self, arguments: ["input": .variable("input")]),
    ] }

    /// Return a list of dynamic blocks filtered by type, location, or UIDs.
    public var dynamicBlocks: DynamicBlocks { __data["dynamicBlocks"] }

    /// DynamicBlocks
    ///
    /// Parent Type: `DynamicBlocks`
    public struct DynamicBlocks: MagentoAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.DynamicBlocks }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("items", [Item?].self),
      ] }

      /// An array containing individual dynamic blocks.
      public var items: [Item?] { __data["items"] }

      /// DynamicBlocks.Item
      ///
      /// Parent Type: `DynamicBlock`
      public struct Item: MagentoAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.DynamicBlock }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("content", Content.self),
        ] }

        /// The renderable HTML code of the dynamic block.
        public var content: Content { __data["content"] }

        /// DynamicBlocks.Item.Content
        ///
        /// Parent Type: `ComplexTextValue`
        public struct Content: MagentoAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.ComplexTextValue }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("html", String.self),
          ] }

          /// Text that can contain HTML tags.
          public var html: String { __data["html"] }
        }
      }
    }
  }
}

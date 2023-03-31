// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CategoriesQuery: GraphQLQuery {
  public static let operationName: String = "Categories"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query Categories {
        categoryList {
          __typename
          children_count
          children {
            __typename
            id
            name
            image
            children {
              __typename
              id
              name
              image
            }
          }
        }
      }
      """#
    ))

  public init() {}

  public struct Data: MagentoAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("categoryList", [CategoryList?]?.self),
    ] }

    /// Return an array of categories based on the specified filters.
    public var categoryList: [CategoryList?]? { __data["categoryList"] }

    /// CategoryList
    ///
    /// Parent Type: `CategoryTree`
    public struct CategoryList: MagentoAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.CategoryTree }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("children_count", String?.self),
        .field("children", [Child?]?.self),
      ] }

      public var children_count: String? { __data["children_count"] }
      /// A tree of child categories.
      public var children: [Child?]? { __data["children"] }

      /// CategoryList.Child
      ///
      /// Parent Type: `CategoryTree`
      public struct Child: MagentoAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.CategoryTree }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("id", Int?.self),
          .field("name", String?.self),
          .field("image", String?.self),
          .field("children", [Child?]?.self),
        ] }

        /// An ID that uniquely identifies the category.
        @available(*, deprecated, message: "Use `uid` instead.")
        public var id: Int? { __data["id"] }
        /// The display name of the category.
        public var name: String? { __data["name"] }
        public var image: String? { __data["image"] }
        /// A tree of child categories.
        public var children: [Child?]? { __data["children"] }

        /// CategoryList.Child.Child
        ///
        /// Parent Type: `CategoryTree`
        public struct Child: MagentoAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.CategoryTree }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("id", Int?.self),
            .field("name", String?.self),
            .field("image", String?.self),
          ] }

          /// An ID that uniquely identifies the category.
          @available(*, deprecated, message: "Use `uid` instead.")
          public var id: Int? { __data["id"] }
          /// The display name of the category.
          public var name: String? { __data["name"] }
          public var image: String? { __data["image"] }
        }
      }
    }
  }
}

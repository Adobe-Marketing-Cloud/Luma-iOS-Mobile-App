// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ProductsQuery: GraphQLQuery {
  public static let operationName: String = "products"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query products($filter: ProductAttributeFilterInput) {
        products(filter: $filter) {
          __typename
          total_count
          items {
            __typename
            name
            sku
            price_range {
              __typename
              minimum_price {
                __typename
                regular_price {
                  __typename
                  value
                  currency
                }
              }
            }
            image {
              __typename
              url
              label
            }
          }
          page_info {
            __typename
            page_size
            current_page
          }
        }
      }
      """#
    ))

  public var filter: GraphQLNullable<ProductAttributeFilterInput>

  public init(filter: GraphQLNullable<ProductAttributeFilterInput>) {
    self.filter = filter
  }

  public var __variables: Variables? { ["filter": filter] }

  public struct Data: MagentoAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("products", Products?.self, arguments: ["filter": .variable("filter")]),
    ] }

    /// Search for products that match the criteria specified in the `search` and `filter` attributes.
    public var products: Products? { __data["products"] }

    /// Products
    ///
    /// Parent Type: `Products`
    public struct Products: MagentoAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.Products }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("total_count", Int?.self),
        .field("items", [Item?]?.self),
        .field("page_info", Page_info?.self),
      ] }

      /// The number of products that are marked as visible. By default, in complex products, parent products are visible, but their child products are not.
      public var total_count: Int? { __data["total_count"] }
      /// An array of products that match the specified search criteria.
      public var items: [Item?]? { __data["items"] }
      /// An object that includes the page_info and currentPage values specified in the query.
      public var page_info: Page_info? { __data["page_info"] }

      /// Products.Item
      ///
      /// Parent Type: `ProductInterface`
      public struct Item: MagentoAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Interfaces.ProductInterface }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("name", String?.self),
          .field("sku", String?.self),
          .field("price_range", Price_range.self),
          .field("image", Image?.self),
        ] }

        /// The product name. Customers use this name to identify the product.
        public var name: String? { __data["name"] }
        /// A number or code assigned to a product to identify the product, options, price, and manufacturer.
        public var sku: String? { __data["sku"] }
        /// The range of prices for the product
        public var price_range: Price_range { __data["price_range"] }
        /// The relative path to the main image on the product page.
        public var image: Image? { __data["image"] }

        /// Products.Item.Price_range
        ///
        /// Parent Type: `PriceRange`
        public struct Price_range: MagentoAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.PriceRange }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("minimum_price", Minimum_price.self),
          ] }

          /// The lowest possible price for the product.
          public var minimum_price: Minimum_price { __data["minimum_price"] }

          /// Products.Item.Price_range.Minimum_price
          ///
          /// Parent Type: `ProductPrice`
          public struct Minimum_price: MagentoAPI.SelectionSet {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.ProductPrice }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("regular_price", Regular_price.self),
            ] }

            /// The regular price of the product.
            public var regular_price: Regular_price { __data["regular_price"] }

            /// Products.Item.Price_range.Minimum_price.Regular_price
            ///
            /// Parent Type: `Money`
            public struct Regular_price: MagentoAPI.SelectionSet {
              public let __data: DataDict
              public init(data: DataDict) { __data = data }

              public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.Money }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("value", Double?.self),
                .field("currency", GraphQLEnum<MagentoAPI.CurrencyEnum>?.self),
              ] }

              /// A number expressing a monetary value.
              public var value: Double? { __data["value"] }
              /// A three-letter currency code, such as USD or EUR.
              public var currency: GraphQLEnum<MagentoAPI.CurrencyEnum>? { __data["currency"] }
            }
          }
        }

        /// Products.Item.Image
        ///
        /// Parent Type: `ProductImage`
        public struct Image: MagentoAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.ProductImage }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("url", String?.self),
            .field("label", String?.self),
          ] }

          /// The URL of the product image or video.
          public var url: String? { __data["url"] }
          /// The label of the product image or video.
          public var label: String? { __data["label"] }
        }
      }

      /// Products.Page_info
      ///
      /// Parent Type: `SearchResultPageInfo`
      public struct Page_info: MagentoAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { MagentoAPI.Objects.SearchResultPageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("page_size", Int?.self),
          .field("current_page", Int?.self),
        ] }

        /// The maximum number of items to return per page of results.
        public var page_size: Int? { __data["page_size"] }
        /// The specific page to return.
        public var current_page: Int? { __data["current_page"] }
      }
    }
  }
}

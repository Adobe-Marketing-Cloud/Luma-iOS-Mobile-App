// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == MagentoAPI.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == MagentoAPI.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == MagentoAPI.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == MagentoAPI.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return MagentoAPI.Objects.Query
    case "Products": return MagentoAPI.Objects.Products
    case "VirtualProduct": return MagentoAPI.Objects.VirtualProduct
    case "CategoryTree": return MagentoAPI.Objects.CategoryTree
    case "CmsPage": return MagentoAPI.Objects.CmsPage
    case "SimpleProduct": return MagentoAPI.Objects.SimpleProduct
    case "BundleProduct": return MagentoAPI.Objects.BundleProduct
    case "DownloadableProduct": return MagentoAPI.Objects.DownloadableProduct
    case "ConfigurableProduct": return MagentoAPI.Objects.ConfigurableProduct
    case "GiftCardProduct": return MagentoAPI.Objects.GiftCardProduct
    case "GroupedProduct": return MagentoAPI.Objects.GroupedProduct
    case "PriceRange": return MagentoAPI.Objects.PriceRange
    case "ProductPrice": return MagentoAPI.Objects.ProductPrice
    case "Money": return MagentoAPI.Objects.Money
    case "ProductImage": return MagentoAPI.Objects.ProductImage
    case "ProductVideo": return MagentoAPI.Objects.ProductVideo
    case "SearchResultPageInfo": return MagentoAPI.Objects.SearchResultPageInfo
    case "DynamicBlocks": return MagentoAPI.Objects.DynamicBlocks
    case "DynamicBlock": return MagentoAPI.Objects.DynamicBlock
    case "ComplexTextValue": return MagentoAPI.Objects.ComplexTextValue
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}

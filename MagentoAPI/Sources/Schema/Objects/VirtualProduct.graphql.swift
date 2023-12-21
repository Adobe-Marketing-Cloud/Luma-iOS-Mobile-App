// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// Defines a virtual product, which is a non-tangible product that does not require shipping and is not kept in inventory.
  static let VirtualProduct = Object(
    typename: "VirtualProduct",
    implementedInterfaces: [
      Interfaces.ProductInterface.self,
      Interfaces.RoutableInterface.self,
      Interfaces.CustomizableProductInterface.self
    ]
  )
}
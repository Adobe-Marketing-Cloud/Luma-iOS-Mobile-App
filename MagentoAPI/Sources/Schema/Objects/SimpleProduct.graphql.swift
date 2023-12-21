// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// Defines a simple product, which is tangible and is usually sold in single units or in fixed quantities.
  static let SimpleProduct = Object(
    typename: "SimpleProduct",
    implementedInterfaces: [
      Interfaces.ProductInterface.self,
      Interfaces.RoutableInterface.self,
      Interfaces.PhysicalProductInterface.self,
      Interfaces.CustomizableProductInterface.self
    ]
  )
}
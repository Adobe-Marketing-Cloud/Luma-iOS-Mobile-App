// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Defines the filters to be used in the search. A filter contains at least one attribute, a comparison operator, and the value that is being searched for.
public struct ProductAttributeFilterInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    activity: GraphQLNullable<FilterEqualTypeInput> = nil,
    category_gear: GraphQLNullable<FilterEqualTypeInput> = nil,
    category_id: GraphQLNullable<FilterEqualTypeInput> = nil,
    category_uid: GraphQLNullable<FilterEqualTypeInput> = nil,
    climate: GraphQLNullable<FilterEqualTypeInput> = nil,
    collar: GraphQLNullable<FilterEqualTypeInput> = nil,
    color: GraphQLNullable<FilterEqualTypeInput> = nil,
    description: GraphQLNullable<FilterMatchTypeInput> = nil,
    eco_collection: GraphQLNullable<FilterEqualTypeInput> = nil,
    erin_recommends: GraphQLNullable<FilterEqualTypeInput> = nil,
    features_bags: GraphQLNullable<FilterEqualTypeInput> = nil,
    format: GraphQLNullable<FilterEqualTypeInput> = nil,
    gender: GraphQLNullable<FilterEqualTypeInput> = nil,
    material: GraphQLNullable<FilterEqualTypeInput> = nil,
    name: GraphQLNullable<FilterMatchTypeInput> = nil,
    new: GraphQLNullable<FilterEqualTypeInput> = nil,
    pattern: GraphQLNullable<FilterEqualTypeInput> = nil,
    performance_fabric: GraphQLNullable<FilterEqualTypeInput> = nil,
    price: GraphQLNullable<FilterRangeTypeInput> = nil,
    purpose: GraphQLNullable<FilterEqualTypeInput> = nil,
    sale: GraphQLNullable<FilterEqualTypeInput> = nil,
    short_description: GraphQLNullable<FilterMatchTypeInput> = nil,
    size: GraphQLNullable<FilterEqualTypeInput> = nil,
    sku: GraphQLNullable<FilterEqualTypeInput> = nil,
    sleeve: GraphQLNullable<FilterEqualTypeInput> = nil,
    strap_bags: GraphQLNullable<FilterEqualTypeInput> = nil,
    style_bags: GraphQLNullable<FilterEqualTypeInput> = nil,
    style_bottom: GraphQLNullable<FilterEqualTypeInput> = nil,
    style_general: GraphQLNullable<FilterEqualTypeInput> = nil,
    url_key: GraphQLNullable<FilterEqualTypeInput> = nil
  ) {
    __data = InputDict([
      "activity": activity,
      "category_gear": category_gear,
      "category_id": category_id,
      "category_uid": category_uid,
      "climate": climate,
      "collar": collar,
      "color": color,
      "description": description,
      "eco_collection": eco_collection,
      "erin_recommends": erin_recommends,
      "features_bags": features_bags,
      "format": format,
      "gender": gender,
      "material": material,
      "name": name,
      "new": new,
      "pattern": pattern,
      "performance_fabric": performance_fabric,
      "price": price,
      "purpose": purpose,
      "sale": sale,
      "short_description": short_description,
      "size": size,
      "sku": sku,
      "sleeve": sleeve,
      "strap_bags": strap_bags,
      "style_bags": style_bags,
      "style_bottom": style_bottom,
      "style_general": style_general,
      "url_key": url_key
    ])
  }

  /// Attribute label: Activity
  public var activity: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["activity"] }
    set { __data["activity"] = newValue }
  }

  /// Attribute label: Category Gear
  public var category_gear: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["category_gear"] }
    set { __data["category_gear"] = newValue }
  }

  /// Deprecated: use `category_uid` to filter product by category ID.
  public var category_id: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["category_id"] }
    set { __data["category_id"] = newValue }
  }

  /// Filter product by the unique ID for a `CategoryInterface` object.
  public var category_uid: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["category_uid"] }
    set { __data["category_uid"] = newValue }
  }

  /// Attribute label: Climate
  public var climate: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["climate"] }
    set { __data["climate"] = newValue }
  }

  /// Attribute label: Collar
  public var collar: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["collar"] }
    set { __data["collar"] = newValue }
  }

  /// Attribute label: Color
  public var color: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["color"] }
    set { __data["color"] = newValue }
  }

  /// Attribute label: Description
  public var description: GraphQLNullable<FilterMatchTypeInput> {
    get { __data["description"] }
    set { __data["description"] = newValue }
  }

  /// Attribute label: Eco Collection
  public var eco_collection: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["eco_collection"] }
    set { __data["eco_collection"] = newValue }
  }

  /// Attribute label: Erin Recommends
  public var erin_recommends: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["erin_recommends"] }
    set { __data["erin_recommends"] = newValue }
  }

  /// Attribute label: Features
  public var features_bags: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["features_bags"] }
    set { __data["features_bags"] = newValue }
  }

  /// Attribute label: Format
  public var format: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["format"] }
    set { __data["format"] = newValue }
  }

  /// Attribute label: Gender
  public var gender: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["gender"] }
    set { __data["gender"] = newValue }
  }

  /// Attribute label: Material
  public var material: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["material"] }
    set { __data["material"] = newValue }
  }

  /// Attribute label: Product Name
  public var name: GraphQLNullable<FilterMatchTypeInput> {
    get { __data["name"] }
    set { __data["name"] = newValue }
  }

  /// Attribute label: New
  public var new: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["new"] }
    set { __data["new"] = newValue }
  }

  /// Attribute label: Pattern
  public var pattern: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["pattern"] }
    set { __data["pattern"] = newValue }
  }

  /// Attribute label: Performance Fabric
  public var performance_fabric: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["performance_fabric"] }
    set { __data["performance_fabric"] = newValue }
  }

  /// Attribute label: Price
  public var price: GraphQLNullable<FilterRangeTypeInput> {
    get { __data["price"] }
    set { __data["price"] = newValue }
  }

  /// Attribute label: Purpose
  public var purpose: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["purpose"] }
    set { __data["purpose"] = newValue }
  }

  /// Attribute label: Sale
  public var sale: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["sale"] }
    set { __data["sale"] = newValue }
  }

  /// Attribute label: Short Description
  public var short_description: GraphQLNullable<FilterMatchTypeInput> {
    get { __data["short_description"] }
    set { __data["short_description"] = newValue }
  }

  /// Attribute label: Size
  public var size: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["size"] }
    set { __data["size"] = newValue }
  }

  /// Attribute label: SKU
  public var sku: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["sku"] }
    set { __data["sku"] = newValue }
  }

  /// Attribute label: Sleeve
  public var sleeve: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["sleeve"] }
    set { __data["sleeve"] = newValue }
  }

  /// Attribute label: Strap/Handle
  public var strap_bags: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["strap_bags"] }
    set { __data["strap_bags"] = newValue }
  }

  /// Attribute label: Style Bags
  public var style_bags: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["style_bags"] }
    set { __data["style_bags"] = newValue }
  }

  /// Attribute label: Style Bottom
  public var style_bottom: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["style_bottom"] }
    set { __data["style_bottom"] = newValue }
  }

  /// Attribute label: Style General
  public var style_general: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["style_general"] }
    set { __data["style_general"] = newValue }
  }

  /// The part of the URL that identifies the product
  public var url_key: GraphQLNullable<FilterEqualTypeInput> {
    get { __data["url_key"] }
    set { __data["url_key"] = newValue }
  }
}

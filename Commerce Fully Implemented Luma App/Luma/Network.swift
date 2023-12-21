//
//  Network.swift
//  Luma
//
//  Copyright © 2023 xscoder. All rights reserved.
//

import Apollo
import Foundation


class Network {
  static let shared = Network()
  private(set) lazy var apollo = ApolloClient(url: URL(string: GRAPHQL_ENDPOINT)!)
}

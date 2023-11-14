//
//  ProductsView.swift
//  Luma
//
//  Created by Rob In der Maur on 27/05/2022.
//

import AEPEdge
import AEPIdentity
import SwiftUI
import os.log

struct ProductsView: View {
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("productsType") private var productsType = "Products"
    @State private var products = [Product]()
    @State var general: General?
    
    var groupedProducts: [String: [Product]] {
        Dictionary(grouping: products, by: { $0.category })
    }
    
    var featuredProducts: [Product] {
        products.filter { $0.featured == true }.shuffled()
    }
    
    var categories: [String] {
        groupedProducts.map( { $0.key }).sorted().reversed()
    }
    
    var body: some View {
        NavigationView {
            //VStack {
                List {
                    Section(header: Text("\(Image(systemName: "star.fill")) Featured")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(featuredProducts, id: \.sku) { product in
                                    NavigationLink {
                                        ProductView(product: product)
                                    }
                                    label : {
                                        VStack {
                                            AsyncImage(url: URL(string: product.imageURL)) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .cornerRadius(10)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 100, height: 100)
                                            
                                            Text(product.name)
                                                .font(.footnote)
                                                .frame(width: 80, height: 20)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    ForEach(categories, id: \.self) { category in
                        Section(category.replacingOccurrences(of: ":", with: " ‣ ")) {
                            ForEach(products.filter { $0.category == category }) { product in
                                ProductRow(product: product)
                            }
                        }
                    }
                    //}
                //}
            }
            .navigationTitle(productsType)
            .navigationBarTitleDisplayMode(.automatic)
        }
        .onFirstAppear {
            Task {
                general = await Network.shared.loadGeneral(configLocation: configLocation)
                await loadProducts(configLocation: configLocation)
            }
        }
        .onAppear {
            // Track view screen
            MobileSDK.shared.sendTrackScreenEvent(stateName: "luma: content: ios: us: en: products")
        }
    }
    
    func loadProducts(configLocation: String) async {
        products = await Network.shared.loadProducts(configLocation: configLocation)
        Logger.configuration.info("ProductsView - Loaded \(products.count) products...")
    }
}

struct ProductsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsView()
    }
}

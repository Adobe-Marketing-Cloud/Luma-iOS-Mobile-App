//
//  ProductRow.swift
//  Luma
//
//  Created by Rob In der Maur on 27/05/2022.
//

import SwiftUI

struct ProductRow: View {
    let product: Product
    
    var body: some View {
        NavigationLink(destination: ProductView(product: product)) {
            HStack {
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50.0)
                } placeholder: {
                    ProgressView()
                }
                // .frame(width: 100.0, height: 50.0)
                .cornerRadius(5)
                Text(product.name)
                Spacer()
                if product.featured == true {
                    Image(systemName: "star.fill")
                }
            }
        }
    }
}

struct ProductRow_Previews: PreviewProvider {
    static var previews: some View {
        ProductRow(product: Product.example)
    }
}

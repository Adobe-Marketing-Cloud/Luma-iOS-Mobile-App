//
//  ProductView.swift
//  Luma
//
//  Created by Rob In der Maur on 27/05/2022.
//

import AEPEdgeConsent
import AEPEdgeIdentity
import AEPEdge
import AEPIdentity
import AppTrackingTransparency
import SwiftUI

struct ProductView: View {
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("currency") private var currency = "$"
    
    var product: Product
    private let formattedPriceValue = "0.00"
    
    @State private var showAddToCartDialog = false
    @State private var showPurchaseDialog = false
    @State private var showSaveForLaterDialog = false
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: product.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
            //.frame(width: 128.0, height: 128.0)
            .cornerRadius(10)
            
            Spacer()
            
            if product.featured == true {
                Text(product.category.replacingOccurrences(of: ":", with: " ‣ "))
                    .font(Font.system(.footnote).smallCaps())
                    .foregroundColor(Color.gray)
                + Text(" \(Image(systemName: "star.fill"))")
                    .font(Font.system(.footnote).smallCaps())
                + Text("\n") + Text(product.description)
            }
            else {
                Text(product.category.replacingOccurrences(of: ":", with: " ‣ "))
                    .font(Font.system(.footnote).smallCaps())
                    .foregroundColor(Color.gray)
                + Text("\n") + Text(product.description)
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "square.fill")
                    .foregroundColor(Color[product.color])
                
                Spacer()
                Text("\(currency) \(String(format: "%.2f", product.price))")
                    .fontWeight(.bold)
                Spacer()
                if product.size == "xl" {
                    HStack {
                        Text("\(Image(systemName: "x.square.fill")) \(Image(systemName: "l.square.fill"))")
                            .foregroundColor(.primary)
                    }
                }
                else if product.size == "xs" {
                    HStack {
                        Text("\(Image(systemName: "x.square.fill")) \(Image(systemName: "s.square.fill"))")
                            .foregroundColor(.primary)
                    }
                }
                else {
                    HStack {
                        Image(systemName: "\(product.size).square.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Spacer()
            
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            Task {
                                if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                                    // Send saveForLater commerce experience event
                                    
                                }
                            }
                            showSaveForLaterDialog.toggle()
                        } label: {
                            Label("", systemImage: "heart")
                        }
                        .alert(isPresented: $showSaveForLaterDialog, content: {
                            Alert(title: Text( "Saved for later"), message: Text("The selected item is saved to your wishlist…"))
                        })
                        
                        Button {
                            Task {
                                if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                                    // Send productListAdds commerce experience event
                                    
                                }
                            }
                            showAddToCartDialog.toggle()
                        } label: {
                            Label("", systemImage: "cart.badge.plus")
                        }
                        .alert(isPresented: $showAddToCartDialog, content: {
                            Alert(title: Text( "Added to basket"), message: Text("The selected item is added to your basket…"))
                        })
                        
                        Button {
                            Task {
                                if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                                    // Send purchase commerce experience event
                                    
                                    // Update attributes
                                    
                                }
                            }
                            showPurchaseDialog.toggle()
                        } label: {
                            Label("", systemImage: "creditcard")
                        }
                        .alert(isPresented: $showPurchaseDialog, content: {
                            Alert(title: Text( "Purchases"), message: Text("The selected item is purchased…"))
                        })
                    }
                }
            }
            .navigationTitle(product.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding()
        .task {
            if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                // Send productViews commerce experience event
                
            }
        }
        .onAppear {
            // Track view screen
            
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        ProductView(product: Product.example)
    }
}

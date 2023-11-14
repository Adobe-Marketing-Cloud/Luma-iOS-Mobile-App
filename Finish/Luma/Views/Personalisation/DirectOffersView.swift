//
//  DirectOffersView.swift
//  Luma
//
//  Created by Rob In der Maur on 05/01/2023.
//

import os.log
import SwiftUI

struct DirectOffersView: View {
    let proposition: Proposition
    let index: Int
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("configLocation") private var configLocation = ""
    @State private var offersOD = [ContentItem]()
    
    var body: some View {
        Section {
            VStack {
                if offersOD.count == 0 {
                    Spacer()
                    Image("aep-logo")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                    Spacer()
                }
                else {
                    Spacer()
                    ForEach(offersOD, id: \.title) { offer in
                        AsyncImage(url: URL(string: offer.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                        }
                        VStack(alignment: .center) {
                            Text(offer.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                            Text(offer.text)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .lineLimit(10)
                        }
                    }
                    Spacer()
                }
            }
        } header: {
            Text("Proposition \(index+1)")
        } footer: {
            Text("\(offersOD.count) offer(s) returned for this decision…")
        }
        .task {
            self.getOffersFromProposition()
        }
    }
    
    func getOffersFromProposition() {
        offersOD = [ContentItem]()
        if let offers = proposition.options {
            for offer in offers {
                let contentString = offer.content
                Logger.aepMobileSDK.info("getOffersFromProposition - OD content: \(contentString)")
                if let contentData = contentString.data(using: .utf8) {
                    if let content = try? JSONDecoder().decode(ContentItem.self, from: contentData) {
                        offersOD.append(content)
                    }
                }
            }
        }
    }
}

struct DirectOffersView_Previews: PreviewProvider {
    static var previews: some View {
        DirectOffersView(proposition: Proposition(activity: Activity(id: "", etag: ""), placement: Placement(id: "", etag: ""), scope: "", options: nil, fallback: nil), index: 0)
    }
}

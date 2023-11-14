//
//  InfoSheet.swift
//  Luma
//
//  Created by Rob In der Maur on 06/01/2023.
//

import SwiftUI

struct InfoSheet: View {
    @State var infoText = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Text("Details of request and response")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark.circle.fill")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            TextEditor(text: $infoText)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
        }
        .padding()
    }
}

struct InfoSheet_Previews: PreviewProvider {
    static var previews: some View {
        InfoSheet()
    }
}

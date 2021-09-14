//
//  StorageIRIView.swift
//  
//
//  Created by Christopher G Prince on 9/12/21.
//

import Foundation
import SwiftUI
import SFSafeSymbols
import iOSShared

struct StorageIRIView: View {
    @StateObject var model: StorageIRIModel
    
    // This doesn't work in this context, to dismiss the view controller.
    //@Environment(\.presentationMode) var presentationMode
    
    @Environment(\.colorScheme) var colorScheme
    let leadingTrailingPadding: CGFloat = 20
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    model.dismiss()
                }, label: {
                    Image(systemName: SFSymbol.multiplyCircle.rawValue)
                })
                .padding([.leading], 10)
                .padding([.top], 10)
                
                Spacer()
            }
            
            Text("Neebla Storage Location")
                .font(.title)
                .padding([.top], 10)
        }
        
        Spacer()
        
        VStack {
            Text("Enter your storage location web link. This is the place in your Solid Pod where Neebla will store your data. Once you set this up, it cannot later be easily changed.")
                .font(.title2)
                
            Spacer().frame(height: 10)

            TextArea("Storage Location (URL)", text: $model.storageIRI ?? "")
                .border(colorScheme == .dark ? Color.black : Color(UIColor.lightGray))
                .frame(height: 100)
                .onChange(of: model.storageIRI) { value in
                    model.updateStorageIRI()
                }
//                // Background color of TextField is fine in non-dark mode. But in dark mode, by default the user can't see the outline of the text field-- and I like them to be able to do that.
//                .if(colorScheme == .dark) {
//                    $0.background(Color(UIColor.darkGray))
//                }
        }.padding([.leading, .trailing], leadingTrailingPadding)

        Spacer().frame(height: 10)

        HStack {
            Button(action: {
                model.dismiss()
            }, label: {
                Text("Cancel")
            })
            .padding([.leading], leadingTrailingPadding * 2)
            
            Spacer()
            
            Button(action: {
                model.continueTapped()
            }, label: {
                Text("Continue")
            })
            .padding([.trailing], leadingTrailingPadding * 2)
            .disabled(!model.continueEnabled)
        }
        
        Spacer()
    }
}

// From https://stackoverflow.com/questions/62741851/how-to-add-placeholder-text-to-texteditor-in-swiftui
struct TextArea: View {
    private let placeholder: String
    @Binding var text: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
        
        // Remove the background color here; without this, I don't see the placeholder.
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        TextEditor(text: $text)
            .background(
                HStack(alignment: .top) {
                    text.isBlank ? Text(placeholder) : Text("")
                    Spacer()
                }
                .foregroundColor(Color.primary.opacity(0.25))
                .padding(EdgeInsets(top: 0, leading: 4, bottom: 7, trailing: 0))
            )
    }
}

extension String {
    var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace }) || count == 0
    }
}

//
//  Setup.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/22.
//

import SwiftUI

struct Setup: View {
    @State private var instanceUrl: String = ""
    @State private var instancePassword: String = ""
    @State private var instanceEtapiToken: String = ""
    
    @FocusState private var instanceUrlFieldFocused: Bool
    @FocusState private var instancePasswordFieldFocused: Bool
    @FocusState private var instanceEtapiTokenFieldFocused: Bool
    
    @State private var useEtapiToken: Bool = false
    
    private var titleText: String = "Please setup before using"
    private var urlText: String = "INSTANCE URL"
    private var exampleURLText: String = "https://trilium.example.com"
    private var passwordText: String = "INSTANCE PASSWORD"
    private var passwordPlaceholderText: String = "Trilium instance login password"
    private var etapiPlaceholderText: String = "Generated ETAPI Token"
    private var etapiTokenBtnText: String = "ETAPI Token"
    private var passwordBtnText: String = "Password"
    private var etapiTokenText: String = "ETAPI TOKEN"
    
    var body: some View {
        VStack {
            Image("IconColor")
            Text(titleText)
            Form {
                Section(header: Text(urlText)) {
                    TextField(urlText, text: $instanceUrl, prompt: Text(verbatim: exampleURLText))
                        .focused($instanceUrlFieldFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onSubmit {
                            print("url submit")
                        }
                }
                
                Section(header: Text(useEtapiToken ? etapiTokenText : passwordText),
                        footer: Text("Will be automaticly saved and using for login/authenticate to the instance")) {
                    SecureField(useEtapiToken ? etapiPlaceholderText : passwordPlaceholderText, text: $instancePassword)
                        .focused($instancePasswordFieldFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(false)
                        .onSubmit {
                            print("pw/etapi submit")
                        }
                    
                    Button {
                        useEtapiToken = !useEtapiToken
                    } label: {
                        Text("or use " + (useEtapiToken ? passwordBtnText : etapiTokenBtnText))
                    }
                    .buttonStyle(.borderless)
                }
                
                Button {
                    print("submit")
                } label: {
                    Text("Signin")
                }
                // align text center
                .frame(maxWidth: .infinity, alignment: .center)
                
            }.scrollDisabled(true)
        }
    }
}

#Preview {
    Setup()
}

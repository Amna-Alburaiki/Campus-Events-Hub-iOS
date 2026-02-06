//
//  SignUpView.swift
//  Campus Events Hub
//
//  Created by Alanood Almarzouqi on 08/11/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var errorMessage = ""
    @Binding var isLoggedIn : Bool
    @State var showAlert = false
    
    @AppStorage("savedEmail") private var savedEmail: String = ""
    @AppStorage("savedPassword") private var savedPassword: String = ""
    @State private var rememberMe: Bool = true
    
    var body: some View {
        ZStack {
            // Simple beige background that looks the same everywhere
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                Spacer().frame(height: 40)
                
                // HCT logo
                Image("hct_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                
                Text("Campus Events Hub")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                // White card with CLEAR fields
                VStack(spacing: 16) {
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                    
                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                    
                    Toggle("Remember email & password", isOn: $rememberMe)
                        .font(.footnote)
                }
                .padding()
                .background(Color(".secondarySystemBackground"))
                .cornerRadius(20)
                .shadow(radius: 4)
                .padding(.horizontal)
                
                //---- Buttons ----//
                VStack(spacing: 12) {
                    Button(action: Signin) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: Signup) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.brown)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.brown, lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .onAppear {
            email = savedEmail
            password = savedPassword
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Attention"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .preferredColorScheme(.light)   // keeps login screen light on all iPhones
    }
    
    //------------FUNCTIONS------------//
    
    func Signin() {
        if email.trimmingCharacters(in: .whitespaces).isEmpty ||
            password.trimmingCharacters(in: .whitespaces).isEmpty {
            
            errorMessage = "Please fill all the fields."
            showAlert = true
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            if let error = error {
                print("Sign in error:", error.localizedDescription)
                // Friendly message for the rubric
                errorMessage = "The username or password is not correct. Please try again."
                showAlert = true
                return
            }
            
            if rememberMe {
                savedEmail = email
                savedPassword = password
            } else {
                savedEmail = ""
                savedPassword = ""
            }
            
            isLoggedIn = true
        }
    }
    
    func Signup() {
        if email.trimmingCharacters(in: .whitespaces).isEmpty ||
            password.trimmingCharacters(in: .whitespaces).isEmpty {
            
            errorMessage = "Please fill all the fields."
            showAlert = true
            return
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            showAlert = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            if let error = error {
                print("Sign up error:", error.localizedDescription)
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            if let user = authResult?.user {
                saveUserRole(uid: user.uid, email: email)
            }
            
            if rememberMe {
                savedEmail = email
                savedPassword = password
            } else {
                savedEmail = ""
                savedPassword = ""
            }
            
            isLoggedIn = true
        }
    }
    
    func saveUserRole(uid: String, email: String) {
        let db = Firestore.firestore()
        
        db.collection("Users").document(uid).setData([
            "email": email,
            "isAdmin": false
        ]) { error in
            if let error = error {
                print("Error saving user role: \(error.localizedDescription)")
            } else {
                print("User role saved successfully!")
            }
        }
    }
}

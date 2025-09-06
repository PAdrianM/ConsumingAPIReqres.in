//
//  RegisterViewController.swift
//  practiceConsumeAPI
//
//  Created by Andrea Hernandez on 1/23/24.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signInButtonTaped(_ sender: UIButton) {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Por favor, completa todos los campos.")
            return
        }
        
        // Realizar el registro
        registerUser(email: email, password: password)
    }
    
    private func registerUser(email: String, password: String) {
        guard let url = URL(string: "https://reqres.in/api/register") else {
            showAlert(message: "Error al validar los datos. Intentelo mas tarde")
            return
        }
        
        let requestBody = ["email": email, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("reqres-free-v1", forHTTPHeaderField: "x-api-key") // API Key agregada
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            // DEBUG: Imprimir lo que estás enviando
            if let bodyData = request.httpBody,
               let bodyString = String(data: bodyData, encoding: .utf8) {
                print("Registro enviando: \(bodyString)")
            }
            
        } catch {
            showAlert(message: "Error al procesar los datos.")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "Error en la solicitud: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.showAlert(message: "Respuesta inválida del servidor")
                }
                return
            }
            
            // DEBUG: Ver qué código de estado recibimos
            print("Status Code: \(httpResponse.statusCode)")
            if let data = data,
               let responseString = String(data: data, encoding: .utf8) {
                print("Response Body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                // Registro exitoso
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.showAlert(message: "No se recibieron datos")
                    }
                    return
                }
                
                do {
                    let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                    print("Registro exitoso. ID: \(registerResponse.id), Token: \(registerResponse.token)")
                    
                    DispatchQueue.main.async {
                        self.showAlert(message: "Registro exitoso. ID: \(registerResponse.id)")
                        self.clearTextFields()
                    }
                } catch {
                    print("Error decodificando: \(error)")
                    DispatchQueue.main.async {
                        self.showAlert(message: "Error al procesar la respuesta: \(error.localizedDescription)")
                    }
                }
                
            case 400:
                // Bad Request
                var errorMessage = "Datos incorrectos"
                
                if let data = data {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = json["error"] as? String {
                        errorMessage = error
                    }
                }
                
                DispatchQueue.main.async {
                    self.showAlert(message: "Error 400: \(errorMessage)")
                }
                
            default:
                DispatchQueue.main.async {
                    self.showAlert(message: "Error en el registro. Código: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Aviso", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func clearTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
}

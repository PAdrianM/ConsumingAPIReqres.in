//
//  LogInViewController.swift
//  practiceConsumeAPI
//
//  Created by Andrea Hernandez on 1/23/24.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logInButtonTaped(_ sender: UIButton) {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Por favor, completa todos los campos.")
            return
        }
        
        // Realizar la llamada a la API de login
        loginUser(email: email, password: password)
    }
    
    private func loginUser(email: String, password: String) {
        let loginURL = URL(string: "https://reqres.in/api/login")!
        let parameters: [String: String] = ["email": email, "password": password]
        
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("reqres-free-v1", forHTTPHeaderField: "x-api-key") // 🔑 ¡Esta es la línea nueva!
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            
            // DEBUG: Imprimir lo que estás enviando
            if let bodyData = request.httpBody,
               let bodyString = String(data: bodyData, encoding: .utf8) {
                print("🚀 Enviando: \(bodyString)")
            }
            
        } catch {
            showAlert(message: "Error al validar los datos. Intentelo mas tarde")
            return
        }
        
        
        // Realizar la solicitud
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
               
               if httpResponse.statusCode == 200 {
                   // Login exitoso
                   guard let data = data else {
                       DispatchQueue.main.async {
                           self.showAlert(message: "No se recibieron datos")
                       }
                       return
                   }
                   
                   do {
                       let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                       print("Token: \(loginResponse.token)")
                       
                       DispatchQueue.main.async {
                           self.performSegue(withIdentifier: "toDashboard", sender: nil)
                           self.emailTextField.text = ""
                           self.passwordTextField.text = ""
                       }
                   } catch {
                       print("Error decodificando: \(error)")
                       DispatchQueue.main.async {
                           self.showAlert(message: "Error al procesar la respuesta: \(error.localizedDescription)")
                       }
                   }
               } else {
                   // Error en el login
                   var errorMessage = "Credenciales incorrectas"
                   
                   if let data = data {
                       if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let error = json["error"] as? String {
                           errorMessage = error
                       }
                   }
                   
                   DispatchQueue.main.async {
                       self.showAlert(message: "Error \(httpResponse.statusCode): \(errorMessage)")
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
}

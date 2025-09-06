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
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonTaped(_ sender: UIButton) {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Por favor, completa todos los campos.")
            return
        }
        
        // Construir el cuerpo de la solicitud
        let requestBody = ["email": email, "password": password]
        
        // Crear la solicitud
        guard let url = URL(string: "https://reqres.in/api/register") else {
            showAlert(message: "Error al validar los datos. Intentelo mas tarde")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convertir el cuerpo de la solicitud a datos
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            showAlert(message: "Error al procesar los datos.")
            return
        }
        
        // Realizar la solicitud
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                // Registro exitoso
                do {
                    let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data!)
                    print("Registro exitoso. ID: \(registerResponse.id), Token: \(registerResponse.token)")
                    print("Status Code 200 Success")
                    
                    DispatchQueue.main.async {
                        self.showAlert(message: "Registro exitoso. ID: \(registerResponse.id), Token: \(registerResponse.token)")
                        self.clearTextFields()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert(message: "Error al procesar la respuesta.")
                        print("Status Code 400 Error")
                    }
                }
            } else {
                // Registro fallido
                DispatchQueue.main.async {
                    self.showAlert(message: "Error en el registro. Por favor, inténtelo nuevamente.")
                }
            }
        }
        .resume()
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

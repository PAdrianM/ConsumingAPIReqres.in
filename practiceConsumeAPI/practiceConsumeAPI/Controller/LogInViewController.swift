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
        // Construir la URL para la API de login
        let loginURL = URL(string: "https://reqres.in/api/login")!
        
        // Crear los parámetros de la solicitud
        let parameters: [String: String] = ["email": email,"password": password]
        
        // Crear la solicitud
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convertir los parámetros a datos JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            showAlert(message: "Error al validar los datos. Intentelo mas tarde")
            return
        }
        
        // Realizar la solicitud
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Si el código de estado es 200, consideramos que las credenciales son correctas
                    do {
                        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data!)
                        print("Token: \(loginResponse.token)")
                        print("Status Code 200 Success")
                        
                        // Navegar al DashboardTableViewController si el inicio de sesión es exitoso
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "toDashboard", sender: nil)
                            self.emailTextField.text = ""
                            self.passwordTextField.text = ""
                        }
                    } catch {
                        self.showAlert(message: "Error: Verifique que las credenciales sean correctas")
                    }
                } else {
                    // Si el código de estado no es 200, consideramos que las credenciales son incorrectas
                    DispatchQueue.main.async {
                        self.showAlert(message: "Credenciales incorrectas")
                        
                        //                        print("Token: \(loginResponse.error)")
                        print("Status Code 400 Error")
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(message: "Error en la solicitud: \(error.localizedDescription)")
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
}

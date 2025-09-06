//
//  DashboardViewController.swift
//  practiceConsumeAPI
//
//  Created by Andrea Hernandez on 1/24/24.
//

import UIKit

class DashboardViewController: UITableViewController {
    
    @IBOutlet var userTableView: UITableView!
    
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserList()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300 // Altura más razonable
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.userLanel.text = user.first_name
        cell.lasNameLbale.text = user.last_name
        cell.emailLabel.text = user.email
        
        // Limpiar la imagen anterior para evitar problemas de reutilización
        cell.avatarImageView.image = nil
        
        // Asignar la imagen desde la URL
        if let imageUrl = URL(string: user.avatar) {
            cell.avatarImageView.loadFrom(url: imageUrl)
        }
        
        return cell
    }
    
    // MARK: - API Request
    
    func fetchUserList() {
        guard let url = URL(string: "https://reqres.in/api/users?page=1") else {
            print("URL incorrecta.")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("reqres-free-v1", forHTTPHeaderField: "x-api-key") // 🔑 API Key agregada
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error de red: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Respuesta inválida del servidor")
                return
            }
            
            print("Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("Error en la respuesta del servidor. Código: \(httpResponse.statusCode)")
                if let data = data,
                   let errorString = String(data: data, encoding: .utf8) {
                    print("Error Response: \(errorString)")
                }
                return
            }
            
            guard let data = data else {
                print("No se recibieron datos.")
                return
            }
            
            // DEBUG: Ver los datos recibidos
            print("Datos recibidos: \(String(data: data, encoding: .utf8) ?? "")")
            
            do {
                let userListResponse = try JSONDecoder().decode(UserListResponse.self, from: data)
                self.users = userListResponse.data
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                print("Se cargaron \(userListResponse.data.count) usuarios")
                
            } catch {
                print("Error al decodificar la respuesta: \(error.localizedDescription)")
                print("Error detallado: \(error)")
            }
        }
        
        task.resume()
    }
}

// MARK: - UIImageView Extension

extension UIImageView {
    func loadFrom(url: URL) {
        DispatchQueue.global().async { [weak self] in
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            } catch {
                print("Error cargando imagen: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    // Puedes poner una imagen por defecto aquí
                    self?.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
    }
}

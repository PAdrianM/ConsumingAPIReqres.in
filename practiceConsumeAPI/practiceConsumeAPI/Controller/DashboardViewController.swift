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
        return 300 // Establece la altura que uno desee
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Se manda a llamar la celda prototipo con identificador Cell para reutilizarla
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.userLanel.text = "\(user.first_name)"
        cell.lasNameLbale.text = "\(user.last_name)"
        cell.emailLabel.text = user.email
        // Asignar la imagen desde la URL
        if let imageUrl = URL(string: user.avatar) {
            cell.avatarImageView.loadFrom(url: imageUrl)
        }
        
        return cell
    }
    
    // MARK: - API Request
    
    //Se crea la funcion que buscara los usuarios de la pagina 1 o 2
    func fetchUserList() {
        //Se crea la solicitud
        guard let url = URL(string: "https://reqres.in/api/users?page=2") else {
            print("URL incorrecta.")
            return
        }
        //Se realiza la solicitud iniciando la sesion
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error de red: \(error.localizedDescription)")
                return
            }
            //verificar si la respuesta del servidor HTTP tiene un código de estado exitoso (200)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error en la respuesta del servidor. Código: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return
            }
            
            guard let data = data else {
                print("No se recibieron datos.")
                return
            }
            
            //Se imprime la data en consola para verificar que este llegando
            print("Datos recibidos: \(String(data: data, encoding: .utf8) ?? "")")
            
            //Se hacec un do-catch el cual se encargara de recargar la lista con los datos de manera asincronica
            do {
                let userListResponse = try JSONDecoder().decode(UserListResponse.self, from: data)
                self.users = userListResponse.data
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error al decodificar la respuesta: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}

extension UIImageView {
    func loadFrom(url: URL) {
        //Crea un trabajo asíncrono en una cola global en segundo plano. Esto se hace para no bloquear el hilo principal mientras se carga la imagen.
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

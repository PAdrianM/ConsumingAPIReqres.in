import SwiftUI

// MARK: - Los modelos ya están definidos en archivos separados
// User.swift, LoginResponse.swift, RegisterResponse.swift, UserListResponse.swift

// MARK: - Servicio de Autenticación
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var users: [User] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var currentUser: String?
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let loginURL = URL(string: "https://reqres.in/api/login")!
        let parameters: [String: String] = ["email": email, "password": password]
        
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("reqres-free-v1", forHTTPHeaderField: "x-api-key")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            print("Login enviando: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error al validar los datos"
                self.isLoading = false
                completion(false)
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error en la solicitud: \(error.localizedDescription)"
                    completion(false)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Respuesta inválida del servidor"
                    completion(false)
                }
                return
            }
            
            print("Login Status Code: \(httpResponse.statusCode)")
            if let data = data {
                print("Login Response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.isAuthenticated = true
                            self.currentUser = email
                            print("Login exitoso. Token: \(loginResponse.token)")
                            completion(true)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.errorMessage = "Error al procesar la respuesta"
                            completion(false)
                        }
                    }
                }
            } else {
                var errorMessage = "Credenciales incorrectas"
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorDesc = json["error"] as? String {
                    errorMessage = errorDesc
                }
                
                DispatchQueue.main.async {
                    self.errorMessage = errorMessage
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Register
    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let registerURL = URL(string: "https://reqres.in/api/register")!
        let parameters: [String: String] = ["email": email, "password": password]
        
        var request = URLRequest(url: registerURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("reqres-free-v1", forHTTPHeaderField: "x-api-key")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            print("Register enviando: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error al validar los datos"
                self.isLoading = false
                completion(false)
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error en la solicitud: \(error.localizedDescription)"
                    completion(false)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Respuesta inválida del servidor"
                    completion(false)
                }
                return
            }
            
            print("Register Status Code: \(httpResponse.statusCode)")
            if let data = data {
                print("Register Response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.isAuthenticated = true
                            self.currentUser = email
                            print("Registro exitoso. ID: \(registerResponse.id), Token: \(registerResponse.token)")
                            completion(true)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.errorMessage = "Error al procesar la respuesta"
                            completion(false)
                        }
                    }
                }
            } else {
                var errorMessage = "Error en el registro"
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorDesc = json["error"] as? String {
                    errorMessage = errorDesc
                }
                
                DispatchQueue.main.async {
                    self.errorMessage = errorMessage
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch Users
    func fetchUsers() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://reqres.in/api/users?page=1") else {
            DispatchQueue.main.async {
                self.errorMessage = "URL incorrecta"
                self.isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("reqres-free-v1", forHTTPHeaderField: "x-api-key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error de red: \(error.localizedDescription)"
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Respuesta inválida del servidor"
                }
                return
            }
            
            print("Users Status Code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No se recibieron datos"
                    }
                    return
                }
                
                print("Users Response: \(String(data: data, encoding: .utf8) ?? "")")
                
                do {
                    let userListResponse = try JSONDecoder().decode(UserListResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.users = userListResponse.data
                        print("Se cargaron \(userListResponse.data.count) usuarios")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error al procesar los datos: \(error.localizedDescription)"
                        print("Error decodificando: \(error)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Error en la respuesta del servidor: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }
    
    func logout() {
        isAuthenticated = false
        users = []
        errorMessage = nil
        currentUser = nil
    }
}

// MARK: - Enumeración de Vistas
enum AppView {
    case welcome, login, register, home
}

// MARK: - Vista Principal
struct ContentView: View {
    @StateObject private var authService = AuthService()
    @State private var currentView: AppView = .welcome
    
    var body: some View {
        ZStack {
            switch currentView {
            case .welcome:
                WelcomeView(
                    goToLogin: { currentView = .login },
                    goToRegister: { currentView = .register }
                )
            case .login:
                LoginView(
                    goToHome: { currentView = .home },
                    goBack: { currentView = .welcome },
                    authService: authService
                )
            case .register:
                RegisterView(
                    goToHome: { currentView = .home },
                    goBack: { currentView = .welcome },
                    authService: authService
                )
            case .home:
                HomeView(
                    goToWelcome: {
                        currentView = .welcome
                        authService.logout()
                    },
                    authService: authService
                )
            }
        }
        .animation(.easeInOut, value: currentView)
    }
}

// MARK: - Vista de Bienvenida
struct WelcomeView: View {
    let goToLogin: () -> Void
    let goToRegister: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icono principal
            Image(systemName: "person.3.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)
            
            VStack(spacing: 10) {
                Text("Bienvenido")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Gestiona empleados de manera eficiente")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Botones de acción
            VStack(spacing: 15) {
                Button(action: goToLogin) {
                    Text("Iniciar Sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: goToRegister) {
                    Text("Crear Cuenta")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Vista de Login
struct LoginView: View {
    @State private var email: String = "eve.holt@reqres.in"
    @State private var password: String = "cityslicka"
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    let goToHome: () -> Void
    let goBack: () -> Void
    @ObservedObject var authService: AuthService
    
    var body: some View {
        VStack(spacing: 30) {
            // Header con botón de regreso
            HStack {
                Button(action: goBack) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            
            Spacer()
            
            // Título
            VStack(spacing: 10) {
                Text("Iniciar Sesión")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Ingresa tus credenciales")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Campos de entrada
            VStack(spacing: 20) {
                TextField("Correo electrónico", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .focused($isEmailFocused)
                
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isPasswordFocused)
                
                // Mostrar error si existe
                if let errorMessage = authService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Botón de login
                Button(action: performLogin) {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(authService.isLoading ? "Iniciando..." : "Iniciar Sesión")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(authService.isLoading ? Color.gray : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
            }
            
            Spacer()
            
            // Credenciales de prueba
            VStack(spacing: 5) {
                Text("Credenciales de prueba:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("eve.holt@reqres.in / cityslicka")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .onSubmit {
            if isEmailFocused {
                isPasswordFocused = true
            } else if isPasswordFocused {
                performLogin()
            }
        }
    }
    
    private func performLogin() {
        isEmailFocused = false
        isPasswordFocused = false
        
        authService.login(email: email, password: password) { success in
            if success {
                goToHome()
            }
        }
    }
}

// MARK: - Vista de Registro
struct RegisterView: View {
    @State private var email: String = "eve.holt@reqres.in"
    @State private var password: String = "pistol"
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    let goToHome: () -> Void
    let goBack: () -> Void
    @ObservedObject var authService: AuthService
    
    var body: some View {
        VStack(spacing: 30) {
            // Header con botón de regreso
            HStack {
                Button(action: goBack) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            
            Spacer()
            
            // Título
            VStack(spacing: 10) {
                Text("Crear Cuenta")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Completa la información")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Campos de entrada
            VStack(spacing: 20) {
                TextField("Correo electrónico", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .focused($isEmailFocused)
                
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isPasswordFocused)
                
                // Mostrar error si existe
                if let errorMessage = authService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Botón de registro
                Button(action: performRegister) {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(authService.isLoading ? "Creando..." : "Crear Cuenta")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(authService.isLoading ? Color.gray : Color.green)
                    .cornerRadius(12)
                }
                .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
            }
            
            Spacer()
            
            // Credenciales de prueba
            VStack(spacing: 5) {
                Text("Credenciales de prueba:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("eve.holt@reqres.in / pistol")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .onSubmit {
            if isEmailFocused {
                isPasswordFocused = true
            } else if isPasswordFocused {
                performRegister()
            }
        }
    }
    
    private func performRegister() {
        isEmailFocused = false
        isPasswordFocused = false
        
        authService.register(email: email, password: password) { success in
            if success {
                goToHome()
            }
        }
    }
}

// MARK: - Vista Principal (Home)
struct HomeView: View {
    @State private var selectedTab = 0
    let goToWelcome: () -> Void
    @ObservedObject var authService: AuthService
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Primera pestaña - Lista de empleados
            EmployeeListView(authService: authService)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Empleados")
                }
                .tag(0)
            
            // Segunda pestaña - Perfil/Logout
            ProfileView(authService: authService, goToWelcome: goToWelcome)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Perfil")
                }
                .tag(1)
        }
        .onAppear {
            authService.fetchUsers()
        }
    }
}

// MARK: - Vista de Lista de Empleados
struct EmployeeListView: View {
    @ObservedObject var authService: AuthService
    @State private var searchText = ""
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return authService.users
        } else {
            return authService.users.filter { user in
                user.first_name.localizedCaseInsensitiveContains(searchText) ||
                user.last_name.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if authService.isLoading && authService.users.isEmpty {
                    VStack {
                        ProgressView()
                        Text("Cargando empleados...")
                            .padding(.top)
                    }
                } else if let error = authService.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        
                        Text("Error")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Reintentar") {
                            authService.fetchUsers()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List(filteredUsers) { user in
                        EmployeeRow(user: user)
                    }
                    .searchable(text: $searchText, prompt: "Buscar empleados...")
                    .refreshable {
                        authService.fetchUsers()
                    }
                }
            }
            .navigationTitle("Empleados (\(authService.users.count))")
        }
    }
}

// MARK: - Fila de Empleado
struct EmployeeRow: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar del usuario
            AsyncImage(url: URL(string: user.avatar)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure(_):
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                case .empty:
                    ProgressView()
                @unknown default:
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            // Información del usuario
            VStack(alignment: .leading, spacing: 4) {
                Text("\(user.first_name) \(user.last_name)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("ID: \(user.id)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Indicador visual
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Vista de Perfil
struct ProfileView: View {
    @ObservedObject var authService: AuthService
    let goToWelcome: () -> Void
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Avatar del usuario
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                
                // Información del usuario
                VStack(spacing: 10) {
                    Text("Usuario Actual")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let currentUser = authService.currentUser {
                        Text(currentUser)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Estadísticas
                VStack(spacing: 15) {
                    HStack {
                        VStack {
                            Text("\(authService.users.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Empleados")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack {
                            Text("Activo")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Estado")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Botón de cerrar sesión
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("Cerrar Sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Perfil")
            .alert("Cerrar Sesión", isPresented: $showingLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar Sesión", role: .destructive) {
                    goToWelcome()
                }
            } message: {
                Text("¿Estás seguro de que quieres cerrar sesión?")
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

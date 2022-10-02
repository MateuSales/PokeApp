import UIKit

final class ViewController: UIViewController {

    private let pokemonNameLabel = CustomLabel(
        fontSize: 24,
        weight: .bold,
        textAlignment: .center
    )
    
    private let pokemonImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()

    private let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.value = 1
        stepper.minimumValue = 1
        stepper.maximumValue = 898
        return stepper
    }()
    
    private let pokemonIDLabel = CustomLabel(
        fontSize: 16,
        weight: .regular,
        textAlignment: .right
    )
    
    private var pokemonID = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialViews()
        addViewsCorrectly()
        setupConstraints()
        
        loadPokemonAndImage()
    }
    
    @objc
    func stepperChanged() {
        pokemonID = Int(stepper.value)
        pokemonIDLabel.text = "Pokemon ID: \(pokemonID)"

        loadPokemonAndImage()
    }
    
    // MARK: - Layout
    
    private func setupInitialViews() {
        pokemonIDLabel.text = "Pokemon ID: \(pokemonID)"
        view.backgroundColor = .white
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
    }
    
    private func addViewsCorrectly() {
        view.addSubview(pokemonNameLabel)
        view.addSubview(pokemonImageView)
        view.addSubview(stepper)
        view.addSubview(pokemonIDLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pokemonNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            pokemonNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pokemonNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            pokemonImageView.topAnchor.constraint(equalTo: pokemonNameLabel.bottomAnchor, constant: 40),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 240),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 240),
            pokemonImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stepper.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 40),
            stepper.leadingAnchor.constraint(equalTo: pokemonImageView.leadingAnchor),
            
            pokemonIDLabel.leadingAnchor.constraint(equalTo: stepper.trailingAnchor, constant: 16),
            pokemonIDLabel.centerYAnchor.constraint(equalTo: stepper.centerYAnchor),
            pokemonIDLabel.trailingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor)
        ])
    }
    
    private func showAlert() {
        let alertController = UIAlertController(
            title: "Tivemos um problema :(",
            message: "A requisição falhou, tente novamente mais tarde :)",
            preferredStyle: .alert
        )
        
        alertController.addAction(.init(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    // MARK: - Business Logic
    
    private func loadPokemonAndImage() {
        makeRequest { result in
            switch result {
            case .success(let pokemon):
                self.handleSuccess(pokemon: pokemon)
            case .failure:
                self.showAlert()
            }
        }
    }
    
    private func makeRequest(completion: @escaping (Result<Pokemon, CustomError>) -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonID)/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let urlRequest = URLRequest(url: url)

        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            DispatchQueue.main.async {
                if error != nil {
                    completion(.failure(.requestError))
                    return
                }
                
                guard let data else {
                    completion(.failure(.dataEmpty))
                    return
                }
                
                if let pokemon = try? JSONDecoder().decode(Pokemon.self, from: data) {
                    completion(.success(pokemon))
                } else {
                    completion(.failure(.decodedError))
                }
            }
        }.resume()
    }
    
    private func handleSuccess(pokemon: Pokemon) {
        pokemonNameLabel.text = pokemon.name.uppercased()
        downloadImage(url: pokemon.sprites.other.official.urlImage)
    }
    
    private func downloadImage(url: String) {
        guard let url = URL(string: url) else { return }
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            guard let data else { return }
            
            let uiImage = UIImage(data: data)

            DispatchQueue.main.async {
                self.pokemonImageView.image = uiImage
            }
        }.resume()
    }
}


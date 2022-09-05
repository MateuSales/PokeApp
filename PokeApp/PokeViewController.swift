import UIKit

final class PokeViewController: UIViewController {
    private let pokemonNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.maximumValue = 100
        stepper.minimumValue = 1
        stepper.value = 1
        return stepper
    }()
    
    private let pokemonIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private var pokemonID = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        pokemonIDLabel.text = "Pokemon ID: \(pokemonID)"
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        
        addViewsInHierarchy()
        setupConstraints()
        
        makeRequest { [weak self] result in
            switch result {
            case .success(let pokemon):
                self?.handleSuccess(pokemon)
            case .failure:
                self?.showAlert()
            }
        }
    }
}

// MARK: - Layout

private extension PokeViewController {
    func addViewsInHierarchy() {
        [
            pokemonNameLabel,
            pokemonImageView,
            stepper,
            pokemonIDLabel
        ].forEach {
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            pokemonNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            pokemonNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pokemonNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pokemonImageView.topAnchor.constraint(equalTo: pokemonNameLabel.bottomAnchor, constant: 40),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 280),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 280),
            pokemonImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stepper.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 40),
            stepper.leadingAnchor.constraint(equalTo: pokemonImageView.leadingAnchor, constant: 20),
            
            pokemonIDLabel.leadingAnchor.constraint(equalTo: stepper.trailingAnchor, constant: 30),
            pokemonIDLabel.trailingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor),
            pokemonIDLabel.centerYAnchor.constraint(equalTo: stepper.centerYAnchor)
        ])
    }
}

// MARK: - Use Cases

private extension PokeViewController {
    func makeRequest(completion: @escaping (Result<Pokemon, PokeError>) -> Void) {
        guard let url = URL(
            string: "https://pokeapi.co/api/v2/pokemon/\(pokemonID)/"
        ) else {
            return completion(.failure(.invalidURL))
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    return completion(.failure(.requestError))
                }
                
                if let data = data {
                    guard let pokemon = try? JSONDecoder().decode(Pokemon.self, from: data) else {
                        return completion(.failure(.decodedError))
                    }
                    
                    completion(.success(pokemon))
                } else {
                    completion(.failure(.invalidData))
                }
            }
        }.resume()
    }
    
    func showAlert() {
        let alertController = UIAlertController(
            title: "Error",
            message: "Aconteceu algo de errado na requisição!!!",
            preferredStyle: .alert
        )
        
        alertController.addAction(.init(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    func handleSuccess(_ pokemon: Pokemon) {
        pokemonNameLabel.text = pokemon.name.uppercased()
        
        guard let urlImage = URL(string: pokemon.sprites.other.official.urlImage) else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: urlImage),
                  let imagePokemon = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.pokemonImageView.image = imagePokemon
            }
        }
    }
    
    @objc func stepperChanged(_ sender: UIStepper) {
        pokemonID = Int(sender.value)
        pokemonIDLabel.text = "Pokemon ID: \(pokemonID)"
        
        makeRequest { [weak self] result in
            switch result {
            case .success(let pokemon):
                self?.handleSuccess(pokemon)
            case .failure:
                self?.showAlert()
            }
        }
    }
}

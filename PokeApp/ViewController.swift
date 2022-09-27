import UIKit

enum CustomError: Error {
    case invalidURL
    case requestError
    case emptyData
    case decodeError
}

class ViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!

    private var pokemonID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.backgroundColor = .lightGray
        
        stepper.value = 1
        stepper.minimumValue = 1
        stepper.maximumValue = 898
        
        pokemonID = Int(stepper.value)
        idLabel.text = "Pokemon ID: \(pokemonID)"
        
        makeRequest { result in
            switch result {
            case .success(let pokemon):
                self.handleSuccess(pokemon: pokemon)
            case .failure:
                self.showAlert()
            }
        }
    }
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        pokemonID = Int(sender.value)
        idLabel.text = "Pokemon ID: \(pokemonID)"
        
        makeRequest { result in
            switch result {
            case .success(let pokemon):
                self.handleSuccess(pokemon: pokemon)
            case .failure:
                self.showAlert()
            }
        }
    }
    
    func makeRequest(completion: @escaping (Result<Pokemon, CustomError>) -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonID)") else {
            completion(.failure(.invalidURL))
            return
        }

        let urlRequest = URLRequest(url: url)

        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(.failure(.requestError))
                    return
                }
                
                guard let data else {
                    completion(.failure(.emptyData))
                    return
                }
                
                guard let pokemon = try? JSONDecoder().decode(Pokemon.self, from: data) else {
                    completion(.failure(.decodeError))
                    return
                }
                
                completion(.success(pokemon))
            }
        }.resume()
    }
    
    func handleSuccess(pokemon: Pokemon) {
        name.text = pokemon.name.uppercased()
        
        guard let url = URL(string: pokemon.sprites.other.official.urlImage) else {
            return
        }

        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
            guard let data else {
                return
            }
            let pokemonImage = UIImage(data: data)

            DispatchQueue.main.async {
                self.image.image = pokemonImage
            }
        }.resume()
    }
    
    func showAlert() {
        let alertController = UIAlertController(
            title: "Deu ruim :(",
            message: "Tivemos problemas na requisição!!! Tente novamente mais tarde :)",
            preferredStyle: .alert
        )
        
        alertController.addAction(.init(title: "OK", style: .default))
        
        present(alertController, animated: true)
    }
}


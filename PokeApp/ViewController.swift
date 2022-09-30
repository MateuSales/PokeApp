import UIKit

enum CustomError: Error {
    case invalidURL
    case requestError
    case dataEmpty
    case decodedError
}

class ViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!

    private var pokemonID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
                
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
        name.text = pokemon.name.uppercased()
        downloadImage(url: pokemon.sprites.other.official.urlImage)
    }
    
    private func downloadImage(url: String) {
        guard let url = URL(string: url) else { return }
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            guard let data else { return }
            
            let uiImage = UIImage(data: data)

            DispatchQueue.main.async {
                self.image.image = uiImage
            }
        }.resume()
    }
    
    private func showAlert() {
        let alertController = UIAlertController(
            title: "Tivemos um problema :(",
            message: "Tente novamente mais tarde",
            preferredStyle: .alert
        )
        alertController.addAction(.init(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}


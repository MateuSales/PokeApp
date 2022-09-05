import Foundation

protocol HomeServicing {
    func getPokemon(id: Int, completion: @escaping (Result<Pokemon, CustomError>) -> Void)
    func getImage(urlImage: String, completion: @escaping (Result<Data, CustomError>) -> Void)
}

protocol URLSessionable {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionable { }

class HomeService: HomeServicing {
    private let urlString: String
    private let session: URLSessionable
    
    init(urlString: String, session: URLSessionable) {
        self.urlString = urlString
        self.session = session
    }
    
    func getPokemon(id: Int, completion: @escaping (Result<Pokemon, CustomError>) -> Void) {
        guard let url = URL(string: "\(urlString)\(id)") else {
            return completion(.failure(.invalidURL))
        }

        session.dataTask(with: url) { data, _, error in
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
    
    func getImage(urlImage: String, completion: @escaping (Result<Data, CustomError>) -> Void) {
        guard let url = URL(string: urlImage) else {
            return completion(.failure(.invalidURL))
        }

        session.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                guard let data = data else {
                    return completion(.failure(.invalidData))
                }

                completion(.success(data))
            }
        }.resume()
    }
}

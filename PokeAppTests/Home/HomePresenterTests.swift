import XCTest
@testable import PokeApp

class HomePresenterTests: XCTestCase {
    
    func test_fetchPokemon_whenRequestFails_shouldCallDisplayError() {
        let (sut, doubles) = makeSUT(id: 56)
        doubles.serviceSpy.getPokemonResult = .failure(.requestError)
        
        sut.fetchPokemon()
        
        XCTAssertEqual(doubles.serviceSpy.idReceiveds, [56])
        XCTAssertEqual(doubles.delegateSpy.receivedMessages, [.displayError])
    }
    
    func test_fetchPokemon_whenGetPokemonIsSuccess_AndGetImageFails_shouldCallsDelegateCorrectly() {
        let (sut, doubles) = makeSUT(id: 56)
        doubles.serviceSpy.getPokemonResult = .success(makePokemon())
        doubles.serviceSpy.getImageResult = .failure(.requestError)
        
        sut.fetchPokemon()
        
        XCTAssertEqual(doubles.serviceSpy.idReceiveds, [56])
        XCTAssertEqual(doubles.serviceSpy.urlImageReceiveds, ["any_url_image"])
        XCTAssertEqual(doubles.delegateSpy.receivedMessages, [
            .displayPokemon(.init(pokemonName: "ANY_NAME", pokemonIDText: "Pokemon ID: 56")),
            .displayError]
        )
    }
    
    func test_fetchPokemon_whenGetPokemonIsSuccess_AndGetImageIsSuccess_shouldCallsDelegateCorrectly() {
        let (sut, doubles) = makeSUT(id: 56)
        doubles.serviceSpy.getPokemonResult = .success(makePokemon())
        doubles.serviceSpy.getImageResult = .success(makeData())
        
        sut.fetchPokemon()
        
        XCTAssertEqual(doubles.serviceSpy.idReceiveds, [56])
        XCTAssertEqual(doubles.serviceSpy.urlImageReceiveds, ["any_url_image"])
        XCTAssertEqual(doubles.delegateSpy.receivedMessages, [
            .displayPokemon(.init(pokemonName: "ANY_NAME", pokemonIDText: "Pokemon ID: 56")),
            .displayImage]
        )
    }
}

// MARK: - Helpers

private extension HomePresenterTests {
    typealias SutAndDoubles = (
        sut: HomePresenter,
        doubles: (
            serviceSpy: HomeServicingSpy,
            delegateSpy: HomePresenterDelegateSpy)
    )
    
    func makeSUT(id: Int = 0) -> SutAndDoubles {
        let serviceSpy = HomeServicingSpy()
        let delegateSpy = HomePresenterDelegateSpy()
        let sut = HomePresenter(service: serviceSpy, pokemonID: id)
        sut.delegate = delegateSpy
        
        return (sut: sut, (serviceSpy: serviceSpy, delegateSpy: delegateSpy))
    }
    
    func makePokemon() -> Pokemon {
        .init(
            name: "any_name",
            sprites: .init(
                other: .init(
                    official: .init(
                        urlImage: "any_url_image"
                    )
                )
            )
        )
    }
    
    func makeData() -> Data {
        UIImage(named: "some_image")!.pngData()!
    }
}

// MARK: - HomeServicingSpy

private final class HomeServicingSpy: HomeServicing {
    var getPokemonResult: Result<Pokemon, CustomError>?
    var getImageResult: Result<Data, CustomError>?

    private(set) var idReceiveds: [Int] = []
    private(set) var urlImageReceiveds: [String] = []
    
    func getPokemon(id: Int, completion: @escaping (Result<Pokemon, CustomError>) -> Void) {
        guard let getPokemonResult = getPokemonResult else {
            XCTFail("getPokemonResult without value")
            return
        }
        idReceiveds.append(id)
        completion(getPokemonResult)
    }
    
    func getImage(urlImage: String, completion: @escaping (Result<Data, CustomError>) -> Void) {
        guard let getImageResult = getImageResult else {
            XCTFail("getImageResult without value")
            return
        }
        urlImageReceiveds.append(urlImage)
        completion(getImageResult)
    }
}

// MARK: - HomePresenterDelegateSpy

private final class HomePresenterDelegateSpy: HomePresenterDelegate {
    enum Message: Equatable {
        case displayImage
        case displayPokemon(HomeViewModel)
        case displayError
    }
    
    private(set) var receivedMessages: [Message] = []

    func displayImage(with image: UIImage) {
        receivedMessages.append(.displayImage)
    }
    
    func displayPokemon(with viewModel: HomeViewModel) {
        receivedMessages.append(.displayPokemon(viewModel))
    }
    
    func displayError() {
        receivedMessages.append(.displayError)
    }
}

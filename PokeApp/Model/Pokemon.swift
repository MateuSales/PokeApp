struct Pokemon: Decodable {
    struct FrontDefault: Decodable {
        let urlImage: String
        
        enum CodingKeys: String, CodingKey {
            case urlImage = "front_default"
        }
    }
    
    struct Other: Decodable {
        let official: FrontDefault
        
        enum CodingKeys: String, CodingKey {
            case official = "official-artwork"
        }
    }

    struct Sprite: Decodable {
        let other: Other
        
        enum CodingKeys: String, CodingKey {
            case other
        }
    }

    let name: String
    let sprites: Sprite
    
    enum CodingKeys: String, CodingKey {
        case name
        case sprites
    }
}

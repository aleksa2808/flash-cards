//
//  DeckStore.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 28.11.22..
//

import Foundation

struct Card: Identifiable, Codable {
    var id: UUID = UUID()
    var frontText: String
    var backText: String
}

class DeckStore: ObservableObject {
    @Published var deck: [Card] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("deck.data")
    }
    
    static func load(completion: @escaping (Result<[Card], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let deck = try JSONDecoder().decode([Card].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(deck))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(deck: [Card], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(deck)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(deck.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

//
//  DeckStore.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 28.11.22..
//

import Foundation

// TODO: need hashable?
struct Card: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var frontText: String
    var backText: String
}

struct Deck: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var cards: [Card]
}

class DeckStore: ObservableObject {
    @Published var decks: [Deck] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("decks.data")
    }
    
    static func load(completion: @escaping (Result<[Deck], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let decks = try JSONDecoder().decode([Deck].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(decks))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(decks: [Deck], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(decks)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(decks.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

//
//  Models.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 23.03.2025.
//

import Foundation

struct Ticket: Codable {
    let id: String
    let user_id: String
    let route_id: String?
    let price: Int
    let status: String
    let payment_status: String
    let qr_code: String
    let created_at: String
    let slot: Slot
    let path: String
    let paid: Bool
    let qrCodeBase64: String?

    enum CodingKeys: String, CodingKey {
        case id, user_id, route_id, price, status, payment_status, qr_code, created_at, slot, path, paid, qrCodeBase64
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        user_id = try container.decode(String.self, forKey: .user_id)
        route_id = try container.decodeIfPresent(String.self, forKey: .route_id)
        price = try container.decode(Int.self, forKey: .price)
        status = try container.decode(String.self, forKey: .status)
        payment_status = try container.decode(String.self, forKey: .payment_status)
        qr_code = try container.decode(String.self, forKey: .qr_code)
        created_at = try container.decode(String.self, forKey: .created_at)
        
        
        slot = try container.decodeIfPresent(Slot.self, forKey: .slot) ?? Slot.defaultSlot()
        path = try container.decodeIfPresent(String.self, forKey: .path) ?? ""
        paid = try container.decodeIfPresent(Bool.self, forKey: .paid) ?? false
        qrCodeBase64 = try container.decodeIfPresent(String.self, forKey: .qrCodeBase64) ?? ""
    }
}

struct Slot: Codable {
    let id: String
    let departure: String
    let destination: String
    let start_date: Date
    let end_date: Date
    let available_seats: Int
    let bus_id: String
    let price: Int
    let created_at: String
    let updated_at: String
    let carNumber: String?
    let availableSeats: Int?

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    enum CodingKeys: String, CodingKey {
        case id, departure, destination, start_date = "start_date", end_date = "end_date", available_seats, bus_id, price, created_at, updated_at, carNumber, availableSeats
    }

    init(id: String = "default_id",
         departure: String = "Unknown",
         destination: String = "Unknown",
         start_date: Date = Date(),
         end_date: Date = Date(),
         available_seats: Int = 0,
         bus_id: String = "default_bus_id",
         price: Int = 0,
         created_at: String = "",
         updated_at: String = "",
         carNumber: String? = nil,
         availableSeats: Int? = nil) {
        self.id = id
        self.departure = departure
        self.destination = destination
        self.start_date = start_date
        self.end_date = end_date
        self.available_seats = available_seats
        self.bus_id = bus_id
        self.price = price
        self.created_at = created_at
        self.updated_at = updated_at
        self.carNumber = carNumber
        self.availableSeats = availableSeats
    }

    static func defaultSlot() -> Slot {
        return Slot()
    }
}

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
    var slot: Slot
    let path: String
    let paid: Bool
    let qrCodeBase64: String?
    let order_number: String

    enum CodingKeys: String, CodingKey {
        case id, user_id, route_id, price, status, payment_status, qr_code, created_at, slot, path, paid, qrCodeBase64,order_number
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
        order_number = try container.decode(String.self, forKey: .order_number)
        
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
//    let created_at: String?
//    let updated_at: String?
    let carNumber: String?
    let availableSeats: Int?
    var isFavourite: Bool?
    let departure_location: String
    let destination_location: String

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    enum CodingKeys: String, CodingKey {
        case id, departure, destination, start_date, end_date, available_seats, bus_id, price
        case carNumber = "bus_number"
        case availableSeats = "bus_total_seats"
        case isFavourite = "is_favorite"
        case departure_location = "departure_location"
        case destination_location = "destination_location"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        departure = try container.decode(String.self, forKey: .departure)
        destination = try container.decode(String.self, forKey: .destination)
        available_seats = try container.decode(Int.self, forKey: .available_seats)
        bus_id = try container.decode(String.self, forKey: .bus_id)
        price = try container.decode(Int.self, forKey: .price)
//        created_at = try container.decode(String.self, forKey: .created_at)
//        updated_at = try container.decode(String.self, forKey: .updated_at)
        carNumber = try container.decodeIfPresent(String.self, forKey: .carNumber)
        availableSeats = try container.decodeIfPresent(Int.self, forKey: .availableSeats)
        isFavourite = try container.decodeIfPresent(Bool.self, forKey: .isFavourite)
        departure_location = try container.decode(String.self, forKey: .departure_location)
        destination_location = try container.decode(String.self, forKey: .destination_location)
        
        let startDateString = try container.decode(String.self, forKey: .start_date)
        let endDateString = try container.decode(String.self, forKey: .end_date)

        guard let startDate = Slot.dateFormatter.date(from: startDateString),
              let endDate = Slot.dateFormatter.date(from: endDateString) else {
            throw DecodingError.dataCorruptedError(forKey: .start_date, in: container, debugDescription: "Date format does not match")
        }

        start_date = startDate
        end_date = endDate
    }

    init(
        id: String = "default_id",
        departure: String = "Unknown",
        destination: String = "Unknown",
        start_date: Date = Date(),
        end_date: Date = Date(),
        available_seats: Int = 0,
        bus_id: String = "default_bus_id",
        price: Int = 0,
//        created_at: String = "",
//        updated_at: String = "",
        carNumber: String? = nil,
        availableSeats: Int? = nil,
        isFavourite: Bool? = false,
        departure_location: String = "unk",
        destination_location: String = "unk"
    ) {
        self.id = id
        self.departure = departure
        self.destination = destination
        self.start_date = start_date
        self.end_date = end_date
        self.available_seats = available_seats
        self.bus_id = bus_id
        self.price = price
//        self.created_at = created_at
//        self.updated_at = updated_at
        self.carNumber = carNumber
        self.availableSeats = availableSeats
        self.isFavourite = isFavourite
        self.departure_location = departure_location
        self.destination_location = destination_location
    }

    static func defaultSlot() -> Slot {
        return Slot()
    }
}

struct Page: Decodable {
    let id: Int
    let title: String
    let content: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case title = "Title"
        case content = "Content"
        case updatedAt = "UpdatedAt"
    }
}

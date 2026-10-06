import Foundation

struct Person: Identifiable, Equatable {
    var id = UUID()
    var firstName: String          // required
    var lastName: String           // required
    var birthDate: Date?           // optional, not in the future
    var phone: String              // optional, digits/spaces/hyphens, "+" only at the start, >= 7 digits
    var email: String              // required, valid format
    var address: String            // optional

    var fullName: String { "\(firstName) \(lastName)" }
}

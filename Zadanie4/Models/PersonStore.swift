import Foundation

final class PersonStore: ObservableObject {
    @Published private(set) var people: [Person] = PersonStore.sampleData

    func add(_ person: Person) {
        people.append(person)
    }

    func update(_ person: Person) {
        guard let index = people.firstIndex(where: { $0.id == person.id }) else { return }
        people[index] = person
    }

    func delete(_ person: Person) {
        people.removeAll { $0.id == person.id }
    }

    func person(withID id: UUID) -> Person? {
        people.first { $0.id == id }
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date? {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }

    private static var sampleData: [Person] {
        [
            Person(firstName: "Anna", lastName: "Kowalska", birthDate: date(1999, 4, 12),
                   phone: "+48 600 100 200", email: "anna.kowalska@example.com",
                   address: "ul. Lipowa 1, Warszawa"),
            Person(firstName: "Jan", lastName: "Nowak", birthDate: nil,
                   phone: "", email: "jan.nowak@example.com", address: "")
        ]
    }
}

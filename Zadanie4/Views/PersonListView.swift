import SwiftUI

struct PersonListView: View {
    @EnvironmentObject private var store: PersonStore
    @State private var pokazDodawanie = false
    @State private var osobaDoUsuniecia: Person?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.people) { person in
                    NavigationLink {
                        PersonDetailView(personID: person.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(person.fullName)
                                .font(.headline)
                            Text(person.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Usuń", role: .destructive) {
                            osobaDoUsuniecia = person
                        }
                    }
                }
            }
            .overlay {
                if store.people.isEmpty {
                    Text("Brak osób. Dotknij +, aby dodać.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Osoby")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        pokazDodawanie = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Dodaj osobę")
                }
            }
            .sheet(isPresented: $pokazDodawanie) {
                PersonFormView(title: "Nowa osoba") { store.add($0) }
            }
            .confirmationDialog(
                "Czy na pewno usunąć tę osobę?",
                isPresented: Binding(
                    get: { osobaDoUsuniecia != nil },
                    set: { if !$0 { osobaDoUsuniecia = nil } }
                ),
                titleVisibility: .visible,
                presenting: osobaDoUsuniecia
            ) { person in
                Button("Usuń \(person.fullName)", role: .destructive) {
                    store.delete(person)
                }
                Button("Anuluj", role: .cancel) { }
            }
        }
    }
}

import SwiftUI

struct PersonListView: View {
    @EnvironmentObject private var store: PersonStore
    @State private var showingAdd = false
    @State private var personToDelete: Person?

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
                            personToDelete = person
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
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Dodaj osobę")
                }
            }
            .sheet(isPresented: $showingAdd) {
                PersonFormView(title: "Nowa osoba") { store.add($0) }
            }
            .confirmationDialog(
                "Czy na pewno usunąć tę osobę?",
                isPresented: Binding(
                    get: { personToDelete != nil },
                    set: { if !$0 { personToDelete = nil } }
                ),
                titleVisibility: .visible,
                presenting: personToDelete
            ) { person in
                Button("Usuń \(person.fullName)", role: .destructive) {
                    store.delete(person)
                }
                Button("Anuluj", role: .cancel) { }
            }
        }
    }
}

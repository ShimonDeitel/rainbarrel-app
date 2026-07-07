import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: BarrelEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .accessibilityIdentifier("entryRow_\(entry.location)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                    .listRowBackground(Theme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Rainbarrel")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryRow: View {
    let entry: BarrelEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.location).font(Theme.bodyFont).fontWeight(.semibold)
            Text(entry.lastCleaned).font(Theme.captionFont).foregroundStyle(.secondary)
            if !entry.notes.isEmpty {
                Text(entry.notes).font(Theme.captionFont).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var location: String
    @State private var lastCleaned: String
    @State private var diverterOK: String
    @State private var notes: String
    @FocusState private var focusedField: Field?
    private enum Field { case f1, f2, f3, f4 }

    let existing: BarrelEntry?
    let onSave: (BarrelEntry) -> Void

    init(entry: BarrelEntry?, onSave: @escaping (BarrelEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _location = State(initialValue: entry?.location ?? "")
        _lastCleaned = State(initialValue: entry?.lastCleaned ?? "")
        _diverterOK = State(initialValue: entry?.diverterOK ?? "")
        _notes = State(initialValue: entry?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Location", text: $location)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field_location")
                    TextField("Lastcleaned", text: $lastCleaned)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field_lastCleaned")
                    TextField("Diverterok", text: $diverterOK)
                        .focused($focusedField, equals: .f3)
                        .accessibilityIdentifier("field_diverterOK")
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .f4)
                        .accessibilityIdentifier("field_notes")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(existing == nil ? "New Barrel" : "Edit Barrel")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = BarrelEntry(
                            id: existing?.id ?? UUID(),
                            location: location,
                            lastCleaned: lastCleaned,
                            diverterOK: diverterOK,
                            notes: notes,
                            createdAt: existing?.createdAt ?? Date()
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(location.isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}

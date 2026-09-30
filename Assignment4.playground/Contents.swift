// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

print("\n--- Level 1.1 ---")
for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}
print("Deck(rawValue: \"greenhouse\") = \(String(describing: Deck(rawValue: "greenhouse")))")

// 1.2
enum AlarmLevel: Int {
    case green = 0, yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = min(max(mass / 500, AlarmLevel.green.rawValue), AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: step) ?? .red
    }
}

print("\n--- Level 1.2 ---")
print("green=\(AlarmLevel.green.rawValue) yellow=\(AlarmLevel.yellow.rawValue) orange=\(AlarmLevel.orange.rawValue) red=\(AlarmLevel.red.rawValue)")
for testMass in [0, 940, 1000, 1499, 1500, 4000] {
    print("level(forTotalMass: \(testMass)) = \(AlarmLevel.level(forTotalMass: testMass))")
}


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    switch parts[0] {
    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let massKg = Int(parts[2]),
              massKg >= 0 else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: massKg)

    case "container":
        guard parts.count == 3,
              parts[1].isEmpty == false,
              let massKg = Int(parts[2]),
              massKg >= 0 else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: massKg)

    case "livestock":
        guard parts.count == 4,
              parts[1].isEmpty == false,
              let count = Int(parts[2]),
              let massPerUnitKg = Int(parts[3]),
              count >= 0, massPerUnitKg >= 0 else {
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnitKg)

    default:
        return .unknown(raw: line)
    }
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print("\n--- Level 2 ---")
var manifestTotalMass = 0
var unknownLineCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    let entryMass = mass(of: entry)
    manifestTotalMass += entryMass
    if case .unknown = entry {
        unknownLineCount += 1
    }
    print("\"\(line)\" -> \(entry) -> \(entryMass) kg")
}
print("unknown lines: \(unknownLineCount)")

let A = manifestTotalMass
print("A = \(A)")


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(oxygen - amount, 0)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

print("\n--- Level 3.1 ---")
var trainee = CrewSnapshot.rookie(named: "Aruzhan")
print("rookie: \(trainee.name), \(trainee.deck), oxygen \(trainee.oxygen)")
trainee.breathe(35)
print("breathe(35): oxygen \(trainee.oxygen)")
trainee.breathe(500)
print("breathe(500): oxygen \(trainee.oxygen)")
trainee.move(to: .engine)
print("move(to: .engine): deck \(trainee.deck)")
trainee.reviveInMedbay()
print("reviveInMedbay(): \(trainee.deck), oxygen \(trainee.oxygen)")

// 3.2
func buildRoster(from records: [(name: String, deck: String, oxygen: Int)]) -> [CrewSnapshot] {
    var result: [CrewSnapshot] = []
    for record in records {
        if let deck = Deck(rawValue: record.deck) {
            result.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
        } else {
            print("WARNING: \(record.name) has unknown deck \"\(record.deck)\", skipped")
        }
    }
    return result
}

print("\n--- Level 3.2 ---")
let crewRoster: [CrewSnapshot] = buildRoster(from: crewData)
for member in crewRoster {
    print("\(member.name): \(member.deck), oxygen \(member.oxygen)")
}
let testRoster = buildRoster(from: [(name: "Ghost", deck: "greenhouse", oxygen: 50)])
print("test roster size: \(testRoster.count)")

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)
func drainOxygenCopy(_ snapshot: CrewSnapshot) {
    var local = snapshot
    local.breathe(30)
    print("   inside function: \(local.oxygen)")
}

func drainOxygenInPlace(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(30)
    print("   inside function: \(snapshot.oxygen)")
}

print("\n--- Level 3.3 ---")
let originalSnapshot = CrewSnapshot.rookie(named: "Dias")
print("copy before: original \(originalSnapshot.oxygen), \(originalSnapshot.deck)")
var copiedSnapshot = originalSnapshot
copiedSnapshot.breathe(40)
copiedSnapshot.move(to: .cargo)
print("copy after:  copy \(copiedSnapshot.oxygen), \(copiedSnapshot.deck)")
print("copy after:  original \(originalSnapshot.oxygen), \(originalSnapshot.deck) (unchanged)")

let passedSnapshot = CrewSnapshot.rookie(named: "Madi")
print("plain before: \(passedSnapshot.oxygen)")
drainOxygenCopy(passedSnapshot)
print("plain after:  \(passedSnapshot.oxygen) (unchanged)")

var inoutSnapshot = CrewSnapshot.rookie(named: "Saule")
print("inout before: \(inoutSnapshot.oxygen)")
drainOxygenInPlace(&inoutSnapshot)
print("inout after:  \(inoutSnapshot.oxygen) (changed)")


// MARK: Level 4 · The Teleport Pod

// 4.1
// The struct got a memberwise init for free because structs always get one
// if you don't write your own. Classes don't get a memberwise init at all,
// only an empty init() when every stored property has a default value.
// id and chargeLevel have no defaults, so I have to write the init myself.
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else {
            return false
        }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else {
            return nil
        }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }

    // Bonus 1
    deinit {
        print("   deinit: pod \(id)")
    }
}

func findCrew(named name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    for member in roster where member.name == name {
        return member
    }
    return nil
}

print("\n--- Level 4.1 ---")
let rulesPod = TeleportPod(id: "TEST", chargeLevel: 25)
print("load into empty pod: \(rulesPod.load(CrewSnapshot.rookie(named: "A")))")
print("load into occupied pod: \(rulesPod.load(CrewSnapshot.rookie(named: "B")))")
let testArrival = rulesPod.fire()
print("fire: \(testArrival?.name ?? "nobody"), charge \(rulesPod.chargeLevel)")
print("load with charge \(rulesPod.chargeLevel): \(rulesPod.load(CrewSnapshot.rookie(named: "C")))")

// 4.2 · Charge ledger
print("\n--- Level 4.2 ---")
let ledgerPod = TeleportPod(id: "P-1", chargeLevel: 100)
print("start: charge \(ledgerPod.chargeLevel)")

var ledgerStep = 1
for name in ["Timur", "Dana", "Nurlan"] {
    if let member = findCrew(named: name, in: crewRoster) {
        let loaded = ledgerPod.load(member)
        let arrived = ledgerPod.fire()
        print("step \(ledgerStep): load \(name) \(loaded), fire \(arrived?.name ?? "nobody"), charge \(ledgerPod.chargeLevel)")
    } else {
        print("step \(ledgerStep): \(name) not found, charge \(ledgerPod.chargeLevel)")
    }
    ledgerStep += 1
}
let emptyShot = ledgerPod.fire()
print("step \(ledgerStep): fire empty pod -> \(emptyShot?.name ?? "nil"), charge \(ledgerPod.chargeLevel)")

let C = ledgerPod.chargeLevel
print("C = \(C)")

// 4.3 · Reference-semantics demonstration
print("\n--- Level 4.3 ---")
let podOriginal = TeleportPod(id: "P-2", chargeLevel: 90)
let podAlias = podOriginal
print("pod before: original \(podOriginal.chargeLevel), alias \(podAlias.chargeLevel)")
podAlias.chargeLevel = 15
print("pod after:  original \(podOriginal.chargeLevel), alias \(podAlias.chargeLevel)")

let snapOriginal = CrewSnapshot.rookie(named: "Erlan")
var snapCopy = snapOriginal
print("snapshot before: original \(snapOriginal.oxygen), copy \(snapCopy.oxygen)")
snapCopy.oxygen = 15
print("snapshot after:  original \(snapOriginal.oxygen), copy \(snapCopy.oxygen)")
// Assigning a class copies the reference (both names point to one pod),
// assigning a struct copies the whole value.


// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int]

    var hullIntegrity: Int {
        willSet {
            print("   hull: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    lazy var fullDiagnostics: String = self.makeDiagnostics()

    var totalOxygen: Int {
        var sum = 0
        for (_, level) in oxygenByDeck {
            sum += level
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.isEmpty {
                return 0
            }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Deck.allCases {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)], hullIntegrity: Int = 100) {
        self.callSign = callSign
        var built: [Deck: Int] = [:]
        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                built[deck] = reading.oxygen
            } else {
                print("   \(callSign): skipped unknown deck \"\(reading.deck)\"")
            }
        }
        self.oxygenByDeck = built
        self.hullIntegrity = min(max(hullIntegrity, 0), 100)
    }

    private func makeDiagnostics() -> String {
        print("Running full scan...")
        var report = "\(callSign) hull \(hullIntegrity)"
        for deck in Deck.allCases {
            if let level = oxygenByDeck[deck] {
                report += " | \(deck.rawValue) \(level)"
            } else {
                report += " | \(deck.rawValue) no data"
            }
        }
        return report
    }
}

print("\n--- Level 5.1 ---")
let station = Station(callSign: "ALMA-7", readings: deckReadings)
let B = station.averageOxygen
print("\(station.callSign): \(station.oxygenByDeck.count) decks, totalOxygen \(station.totalOxygen)")
print("B = \(B)")

let backupStation = Station(callSign: "ALMA-7-BACKUP", readings: deckReadings)
print("backup station never reads fullDiagnostics: total \(backupStation.totalOxygen), hull \(backupStation.hullIntegrity)")

print("first access:")
print(station.fullDiagnostics)
print("second access:")
print(station.fullDiagnostics)

station.averageOxygen = 70
print("after averageOxygen = 70:")
for deck in Deck.allCases {
    print("   \(deck.rawValue): \(station.oxygenByDeck[deck] ?? 0)")
}
print("total \(station.totalOxygen), average \(station.averageOxygen)")
print("third access:")
print(station.fullDiagnostics)

// 5.2 · The clamp trap: 130, then -40, then 55
print("\n--- Level 5.2 ---")
station.hullIntegrity = 130
print("hull = \(station.hullIntegrity)")
station.hullIntegrity = -40
print("hull = \(station.hullIntegrity)")
station.hullIntegrity = 55
print("hull = \(station.hullIntegrity)")
// No infinite loop: when a property is set inside its own didSet,
// Swift doesn't call willSet/didSet again, it just stores the value.


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/

// Report 1
// Expected: everyone loses 10 oxygen.
// Actual: compiles, prints 62, the roster doesn't change.
// Rule: CrewSnapshot is a struct, so `member` is a copy of each element.
// The copy changes and is thrown away.
// Fix: change the array through its index.
print("\n--- Level 6 ---")
var fixedRoster = crewRoster
print("report 1 before: \(fixedRoster[0].oxygen)")
for index in 0..<fixedRoster.count {
    fixedRoster[index].oxygen -= 10
}
print("report 1 after: \(fixedRoster[0].oxygen)")

// Report 2
// Expected: podA stays 100.
// Actual: compiles, prints 0.
// Rule: TeleportPod is a class, `let podB = podA` copies the reference,
// so both point to the same pod.
// Fix: make a separate pod if you need a separate one.
let fixedPodA = TeleportPod(id: "A", chargeLevel: 100)
let fixedPodB = TeleportPod(id: "A-copy", chargeLevel: fixedPodA.chargeLevel)
fixedPodB.chargeLevel = 0
print("report 2: podA \(fixedPodA.chargeLevel), podB \(fixedPodB.chargeLevel)")

// Report 3
// Expected: add() appends an entry.
// Actual: doesn't compile - "cannot use mutating member on immutable value: 'self' is immutable".
// Rule: in a struct method self is immutable unless the method is mutating.
// Fix: add `mutating`.
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var logbook = Logbook()
print("report 3 before: \(logbook.entries.count) entries")
logbook.add("teleporter reports full transfer")
logbook.add("crew member seen on two decks")
print("report 3 after: \(logbook.entries)")

// Report 4
// Expected: both assignments work.
// Actual: snapshot.oxygen = 40 doesn't compile - "cannot assign to property: 'snapshot' is a 'let' constant".
// pod.chargeLevel = 10 compiles fine.
// Rule: let on a struct freezes the whole value, all its properties.
// let on a class only freezes the reference, the object itself can still change.
// Fix: use var for the snapshot. The pod line is fine.
var fixedSnapshot = CrewSnapshot.rookie(named: "Dana")
fixedSnapshot.oxygen = 40
print("report 4 snapshot: \(fixedSnapshot.oxygen)")
let report4Pod = TeleportPod(id: "B", chargeLevel: 50)
report4Pod.chargeLevel = 10
print("report 4 pod: \(report4Pod.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }

final class FlightRecorder {
    // private: nobody outside can read, replace or clear the array
    private var entries: [String] = []

    // private(set): can be read from outside but not changed back to false
    private(set) var isSealed = false

    // internal: read-only, there's no setter
    internal var entryCount: Int {
        return entries.count
    }

    // internal: read-only, gives a string, not the array itself
    internal var transcript: String {
        var text = "recorder (\(isSealed ? "sealed" : "open")):"
        var number = 1
        for entry in entries {
            text += "\n   \(number). \(entry)"
            number += 1
        }
        return text
    }

    // internal: the only way to add, refuses after seal
    @discardableResult
    internal func add(_ entry: String) -> Bool {
        if isSealed {
            return false
        }
        entries.append(entry)
        return true
    }

    // internal: can only seal, there's no unseal
    internal func seal() {
        isSealed = true
    }

    // fileprivate: other files can't use it, only this one (auditTranscript)
    fileprivate func auditLines() -> [String] {
        return entries
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    let lines = recorder.auditLines()
    var characters = 0
    for line in lines {
        characters += line.count
    }
    return "audit: \(lines.count) entries, \(characters) chars, sealed \(recorder.isSealed)"
}

print("\n--- Level 7 ---")
let recorder = FlightRecorder()
recorder.add("07:00 teleporter online")
recorder.add("07:05 full crew transfer")
recorder.add("07:06 Timur on engine and medbay at the same time")
print("entries: \(recorder.entryCount), sealed: \(recorder.isSealed)")
print(recorder.transcript)
recorder.seal()
let lateEntryAccepted = recorder.add("12:00 everything is fine")
print("add after seal: \(lateEntryAccepted), entries: \(recorder.entryCount)")
print(auditTranscript(of: recorder))

// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level
//
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

print("\n--- Finale ---")
let D = AlarmLevel.level(forTotalMass: A).rawValue
print("D = \(D) (\(AlarmLevel.level(forTotalMass: A)))")
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

// Bonus 2
print("\n--- Bonus 2 ---")
var survivor: TeleportPod? = nil
print("before do")
do {
    let tempPod = TeleportPod(id: "TMP-1", chargeLevel: 30)
    let secondReference = tempPod
    let keptPod = TeleportPod(id: "TMP-2", chargeLevel: 30)
    survivor = keptPod
    print("inside do: \(tempPod.id) === \(secondReference.id): \(tempPod === secondReference)")
    print("inside do: last line")
}
// TMP-1 deinit fires on the closing } above: both references are local,
// they die together with the block and the count goes to 0.
// TMP-2 is still held by survivor, so it lives until survivor = nil.
print("after do: survivor = \(survivor?.id ?? "nil")")
survivor = nil
print("after survivor = nil")

// Bonus 3
func sameOccupant(_ first: CrewSnapshot?, _ second: CrewSnapshot?) -> Bool {
    switch (first, second) {
    case (nil, nil):
        return true
    case let (a?, b?):
        return a.name == b.name && a.deck == b.deck && a.oxygen == b.oxygen
    default:
        return false
    }
}

func comparePods(_ first: TeleportPod, _ second: TeleportPod) -> String {
    if first === second {
        return "same pod"
    }
    if first.id == second.id
        && first.chargeLevel == second.chargeLevel
        && sameOccupant(first.occupant, second.occupant) {
        return "different pods, equal contents"
    }
    return "different pods, different contents"
}

print("\n--- Bonus 3 ---")
let recordOne = TeleportPod(id: "P-7", chargeLevel: 60)
let recordTwo = recordOne
let recordClone = TeleportPod(id: "P-7", chargeLevel: 60)
let otherPod = TeleportPod(id: "P-8", chargeLevel: 20)
print("one vs two: \(comparePods(recordOne, recordTwo))")
print("one vs clone: \(comparePods(recordOne, recordClone))")
print("one vs other: \(comparePods(recordOne, otherPod))")


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?

    Structs get a memberwise init automatically if you don't write your own.
    Classes never get one, only an empty init() when all properties have
    default values. TeleportPod's id and chargeLevel don't have defaults.

 2. What does `mutating` do to self, and why do classes never need it?

    It makes self changeable inside the method (basically like inout), so the
    method can change properties or even replace self, like in reviveInMedbay.
    That's also why it only works on a var. In a class self is a reference,
    methods change the object and not the reference, so mutating isn't needed.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?

    For a struct let freezes the whole value, so snapshot.oxygen = 40 fails
    even though oxygen is var. For a class let only freezes the reference:
    pod can't point to another pod, but pod.chargeLevel = 10 is fine.

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?

    It gets its value after init, on first access, and let has to be set
    during init, so lazy has to be var. Behaviour changes when creating the
    value has side effects or depends on state: fullDiagnostics prints
    "Running full scan..." only once and never for the backup station, and
    after I set averageOxygen = 70 it still shows the old values because it
    was already computed.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?

    auditTranscript is a free function outside the class and it uses
    auditLines(). With private it wouldn't compile because private only works
    inside the class. fileprivate lets this file use it but not other files.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?

    TMP-1's deinit fires on the closing } of the do block, because both of
    its references are inside the block and disappear there. TMP-2's fires on
    survivor = nil. === checks if two references are the same object, and
    structs are copied on every assignment, so there is no "same object" -
    the compiler only allows === for classes.
*/

import Foundation

let fleetData: [(kind: String, id: String, charge: Int)] = [
    ("welder",  "W-1", 80),
    ("scanner", "S-1", 60),
    ("cargo",   "C-1", 45),
    ("welder",  "W-2", 30),
    ("hologram","X-1", 90),
    ("scanner", "S-2", 15)
]
let sensorData: [(id: String, charge: Int)] = [("H-1", 72), ("H-2", 18)]

final class LegacyBeacon {
    var id: String
    var signalStrength: Int
    init(id: String, signalStrength: Int) { self.id = id; self.signalStrength = signalStrength }
}
let beacon = LegacyBeacon(id: "OLD-1", signalStrength: 33)

// Level 1
// Class, not struct: a battery is one physical object with identity, so every
// reference (drone, charger) must see and change the SAME charge, not a copy.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int { charge }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(100, charge + amount)
    }
}

// let testCell = PowerCell(charge: 50)
// testCell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level

extension Int {
    var powerBar: String {
        let filled = min(max(self / 10, 0), 10)
        return String(repeating: "#", count: filled)
             + String(repeating: ".", count: 10 - filled)
    }
}

protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    func healthCode(for level: Int) -> Int {
        if level < 20 { return 2 }
        if level < 50 { return 1 }
        return 0
    }
}

// Level 2
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        let level = cell.level()
        return "\(id): \(level)% \(level.powerBar)"
    }

    func performTask() -> Int { 0 }

    // `final` buys us: no subclass can replace the ritual (spend first, work
    // second), so nobody can make a drone work without paying for it.
    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id): seam welded" }
}

final class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("WARNING: skipped record \(record.id) - unknown kind '\(record.kind)'")
    }
}

// Level 4
// Drone is a CLASS (reference type): recharge(by:) changes the object the
// reference points to, never `self` itself, so `mutating` is not needed.
// `mutating` exists only for value types, where changing a property replaces self.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }
    func recharge(by amount: Int) { cell.recharge(by: amount) }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(100, chargeLevel + amount)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: min(max(record.charge, 0), 100)))
}

// Level 5
extension LegacyBeacon: Diagnosable {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: signalStrength) }

    func diagnose() -> String {
        "*** LEGACY HARDWARE *** \(componentID): signal \(signalStrength), code \(statusCode)"
    }
}

// Level 3
func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<max(rounds, 0) {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)

print("--- After the shift ---")
var B = 0
var C = 0
for drone in fleet {
    print(drone.statusLine)
    B += drone.cell.level()
    if drone.cell.level() >= drone.powerCost { C += 1 }
}
print("Drones able to run one more task: \(C)")

// The element type is a protocol, because a class and a struct share no
// superclass: [Drone] could never hold a SensorModule (a struct) or the beacon.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}

var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }
print("\n--- Diagnostics (drones + sensors) ---")
print(diagnosticsReport(components))

components.append(beacon)
print("\n--- Diagnostics (with beacon) ---")
print(diagnosticsReport(components))

var D = 0
for component in components { D += component.statusCode }

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("\nMISSION CODE: \(missionCode)")

// Level 6 · Incident Reports

// ---- Report 1 ----
// class PatchDrone: Drone { func performTask() -> Int { return 30 } }
// Expected: PatchDrone works and returns 30 units.
// Reality: DOES NOT COMPILE: "overriding declaration requires an 'override' keyword".
// Rule: redefining a superclass member must be marked `override`, so you can't
//       override by accident (or silently fail to override after a rename).
// Fix: override func performTask() -> Int { return 30 }

// ---- Report 2 ----
// final class HeavyWelder: WelderDrone { override func runOnce() -> Int { return 999 } }
// Expected: a welder that always reports 999 units.
// Reality: DOES NOT COMPILE: "inheritance from a final class 'WelderDrone'"
//          (and also "instance method overrides a 'final' instance method" for runOnce).
// Rule: `final` forbids subclassing (class) and overriding (member).
// Fix: don't override runOnce; change powerCost/performTask in a subclass of
//      a non-final base, e.g. make HeavyWelder inherit from Drone directly.

// ---- Report 3 ----
// let fleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
// let first = fleet[0]
// print(first.weldSeam())
// Expected: "W-9: seam welded".
// Reality: DOES NOT COMPILE: "value of type 'Drone' has no member 'weldSeam'".
// Rule: the compiler only allows what the STATIC type (Drone) declares, even
//       though the object at runtime is a WelderDrone.
// Fix:
//   if let welder = first as? WelderDrone { print(welder.weldSeam()) }
// as? returns an optional because the cast can fail at runtime (the object may
// not be a WelderDrone), and nil is how that failure is expressed.

// ---- Report 4 ----
// protocol Labelled { var componentID: String { get } }
// extension Labelled { func label() -> String { "generic component" } }
// struct Thruster: Labelled { let componentID: String
//                             func label() -> String { "thruster \(componentID)" } }
// let parts: [Labelled] = [Thruster(componentID: "T-1")]
// print(parts[0].label())
// Expected: "thruster T-1".   Reality: compiles, prints "generic component".
// Rule: label() is NOT a protocol requirement, only an extension method, so it
//       is dispatched STATICALLY by the variable's type (Labelled), and the
//       extension's version is picked. Requirements go through the witness
//       table (dynamic dispatch) and would call the struct's version.
// Fix (one line): add `func label() -> String` to the protocol body:
//   protocol Labelled { var componentID: String { get }; func label() -> String }

// DEFENSE QUESTIONS
// 1. A class is a reference type: recharge(by:) mutates the object that the
//    reference points to, and `self` (the reference) is never reassigned, so
//    no `mutating` is needed. A struct is a value type: changing chargeLevel
//    replaces the whole value `self`, so the method must be `mutating`. The
//    protocol requirement is `mutating` so that both kinds of types can conform.
//
// 2. Inheritance can: share STORED properties and a concrete implementation
//    (id, cell, runOnce) in a base class, and let subclasses refine it with
//    override + super. A protocol can: unite unrelated types (a class, a
//    struct, and LegacyBeacon, a type we can't edit) under one interface via
//    retroactive conformance; classes can't inherit from structs, and a type
//    can adopt many protocols but have only one superclass.
//
// 3. `final` prevents subclassing (on a class) and overriding (on a member).
//    Making runOnce() final protects the shift ritual "spend, then work":
//    no subclass can skip the payment or return fake work like HeavyWelder's 999.
//
// 4. label() was not a requirement of Labelled, only a method in its extension.
//    Calling it on a value typed as Labelled uses static dispatch, so the
//    compiler picks the extension's version; the struct's method only shadows
//    it when called on the concrete type Thruster.

// BONUS
// 1. Making "don't use Drone directly" visible:
//    * Runtime: in Drone.init add
//        precondition(type(of: self) != Drone.self, "Drone is abstract, subclass it")
//      (or fatalError("override me") inside performTask()).
//    * Compile time: make the base a protocol (see 2), because a protocol
//      cannot be instantiated at all.
//
// 2. Protocol-based fleet:
protocol Worker {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}
extension Worker {
    var powerCost: Int { 10 }
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}
struct WelderUnit: Worker {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
}
//
// 3. Comparison: The class design gives one shared base with stored state and
//    a `final` ritual that cannot be bypassed, but it forces single inheritance
//    and reference semantics. The protocol design gives value types and works
//    for any hardware, but runOnce lives in an extension, so a type can
//    redefine it (not final-protected) and there are no stored properties
//    in the protocol. For this station I'd pick the protocol design; if drones
//    had to share mutable state, classes (or a shared class like PowerCell
//    inside structs) would be needed, since copies of structs would diverge.

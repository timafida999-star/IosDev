// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          value >= 0 || parts.0 == "TEMP"
    else { return nil }
    return (sensor: parts.0, value: value)
}

print(parseReading("O2:87") as Any)
print(parseReading("TEMP:-12") as Any)
print(parseReading("RAD:-1") as Any)
print(parseReading(":55") as Any)

func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid: valid, invalidCount: invalidCount)
}

let parsedLog = parseLog(rawLog)
print("Valid: \(parsedLog.valid.count), invalid: \(parsedLog.invalidCount)")
print(parseLog(["O2:50", "bad", "TEMP:-5", "RAD:-2"]))

let A = parsedLog.invalidCount
print("A = \(A)")


func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let o2Readings = select(parsedLog.valid) { $0.sensor == "O2" }
print(o2Readings)
print(values(of: o2Readings))
print(select(parsedLog.valid) { $0.value > 90 })

func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minValue = first
    var maxValue = first
    var sum = 0
    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
        sum += value
    }
    return (min: minValue, max: maxValue, average: Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) as Any)
print(stats() as Any)
print(stats(of: []) as Any)
print(stats(of: values(of: o2Readings)) as Any)

let B = Int(stats(of: values(of: o2Readings))?.average ?? 0)
print("B = \(B)")

let validReadings = parsedLog.valid

let sorted1 = validReadings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
let sorted2 = validReadings.sorted(by: { a, b in return a.value > b.value })
let sorted3 = validReadings.sorted(by: { a, b in a.value > b.value })
let sorted4 = validReadings.sorted(by: { $0.value > $1.value })
let sorted5 = validReadings.sorted { $0.value > $1.value }

func sameReadings(_ first: [Reading], _ second: [Reading]) -> Bool {
    guard first.count == second.count else { return false }
    for index in 0..<first.count {
        if first[index] != second[index] {
            return false
        }
    }
    return true
}

let allSortsMatch = sameReadings(sorted1, sorted2)
    && sameReadings(sorted1, sorted3)
    && sameReadings(sorted1, sorted4)
    && sameReadings(sorted1, sorted5)
print(sorted1)
print("All five sorts match: \(allSortsMatch)")


func heatUp(_ t: Int) -> Int {
    t + 5
}

func coolDown(_ t: Int) -> Int {
    t - 3
}

func hold(_ t: Int) -> Int {
    t
}

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

print(chooseProtocol(for: 10)(10))
print(chooseProtocol(for: 30)(30))
print(chooseProtocol(for: 20)(20))

func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    let safeRange = 18...24
    var temp = start
    var steps = 0
    while !safeRange.contains(temp) && steps < maxSteps {
        let stabilize = chooseProtocol(for: temp)
        temp = stabilize(temp)
        steps += 1
    }
    return (finalTemp: temp, steps: steps, isStable: safeRange.contains(temp))
}

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))
print(runUntilStable(from: 20))

let tempValues = values(of: select(parsedLog.valid) { $0.sensor == "TEMP" })
let lowestTemp = stats(of: tempValues)?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps
print("Lowest temp: \(lowestTemp), C = \(C)")


func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

for member in crew {
    print("\(member.name): \(oxygenLevel(of: member) as Any)")
}

func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }
    let state = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(state)"
}

for member in crew {
    print(status(of: member))
}

@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let capacity = 100
    let available = max(source, 0)
    let freeSpace = max(capacity - target, 0)
    let transferred = min(amount, available, freeSpace)
    source -= transferred
    target += transferred
    return transferred
}

var testSource = 50
var testTarget = 90
let testMoved1 = transferOxygen(from: &testSource, to: &testTarget, amount: 30)
print(testMoved1, testSource, testTarget)
var testSource2 = 5
var testTarget2 = 0
let testMoved2 = transferOxygen(from: &testSource2, to: &testTarget2, amount: 20)
print(testMoved2, testSource2, testTarget2)
let testMoved3 = transferOxygen(from: &testSource2, to: &testTarget2, amount: -10)
print(testMoved3, testSource2, testTarget2)

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Transferred \(moved): Lab = \(labTank.level), Hab = \(habTank.level)")
} else {
    print("Transfer impossible: missing tank")
}

let D = hab.oxygenTank?.level ?? 0
print("D = \(D)")

func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let ordered = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in ordered {
        result.append(member.name)
    }
    return result
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder("Nurlan", "Ghost2", "Timur", roster: roster))


/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    // member.module! -> Nurlan (module == nil): crash "Unexpectedly found nil while unwrapping"
    // oxygenTank!    -> Dana (Dock has no tank): crash
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            // oxygenLevel(of:)! -> Dana / Nurlan return nil: crash (with starter crew it crashes on Dana, 2nd in array)
            result = member.name
            // logic bug: no break/return, loop continues and overwrites result,
            // so it returns the LAST critical member, not the first one
            // (invisible with starter data because only Aigerim is critical)
        }
    }
    return result!
    // empty crew or nobody below 20 -> result is nil: crash
    // return type String can't express "nobody is critical"
}
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let tank = member.module?.oxygenTank else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

for member in crew {
    print(reportOxygen(for: member))
}

let testLowA = CrewMember(name: "TestA", role: "Test", priority: 5,
                          module: Module(name: "TestModuleA", oxygenTank: Tank(level: 5)))
let testLowB = CrewMember(name: "TestB", role: "Test", priority: 6,
                          module: Module(name: "TestModuleB", oxygenTank: Tank(level: 15)))
let testOk = CrewMember(name: "TestOK", role: "Test", priority: 7,
                        module: Module(name: "TestModuleC", oxygenTank: Tank(level: 80)))
let testNoData = CrewMember(name: "TestVoid", role: "Test", priority: 8, module: nil)

let criticalResult = firstCritical(in: [testNoData, testOk, testLowA, testLowB])
print("First critical: \(criticalResult ?? "none")")
print("Logic bug fixed: \(criticalResult == "TestA")")
print("Nobody critical: \(firstCritical(in: [testOk, testNoData]) ?? "none")")
print("Empty crew: \(firstCritical(in: []) ?? "none")")
print("Station crew: \(firstCritical(in: crew) ?? "none")")


let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var firedCount = 0
    return { level in
        guard level < threshold else { return false }
        firedCount += 1
        print("Alarm #\(firedCount)")
        return true
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12))
print(alarm(40))
print(alarm(5))

let secondAlarm = makeAlarm(threshold: 50)
print(secondAlarm(30))
print(alarm(1))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    guard let keeps the unwrapped value in the outer scope after the check,
    and the compiler forces the else branch to leave the scope (return / continue / throw).
    if let only gives the value inside its braces, so every extra check adds nesting.
    Example: parseReading with if let becomes a pyramid:
        if let parts = splitOnce(raw, by: ":") {
            if !parts.0.isEmpty {
                if let value = Int(parts.1) {
                    if value >= 0 || parts.0 == "TEMP" { return (parts.0, value) }
                }
            }
        }
        return nil
    With guard let it's one flat check and the happy path stays at the left edge.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    Int... is only call-site syntax: the caller must write separate values stats(1, 2, 3),
    and Swift packs them into an array itself. From outside the parameter type is Int...,
    not [Int], and Swift has no "spread" operator to unpack an array into arguments.
    That's why the array version stats(of:) exists and the variadic one just calls it.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    Law of exclusivity: two inout arguments would be overlapping write accesses
    to the same variable ("overlapping accesses to 'x'").
    It prevents aliasing: source and target would be the same memory, and the result
    of source -= n; target += n would depend on write-back order, so oxygen could
    appear or disappear when "transferring" a tank into itself.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    ?? requires the right side to have the same type as the wrapped value on the left.
    Left is Int?, so the default must be Int, but "no data" is String.
    Fix: convert first, e.g.
        if let level = oxygenLevel(of: dana) { print("\(level)") } else { print("no data") }

 5. Full type of chooseProtocol and how to read it:
    (Int) -> (Int) -> Int
    The arrow is right-associative, so it is (Int) -> ((Int) -> Int):
    a function that takes an Int (current temperature) and returns another function
    that takes an Int and returns an Int (the chosen protocol).
        let chooser: (Int) -> (Int) -> Int = chooseProtocol(for:)
        chooser(30)(30)   // 27

 Bonus. Where does the alarm counter live after makeAlarm returns?
    firedCount is captured by the returned closure. Because the closure escapes,
    Swift doesn't keep the variable on makeAlarm's stack frame, it moves it into a
    heap-allocated box, and the closure holds a strong reference to that box.
    The counter lives as long as the closure (alarm) lives. Each makeAlarm call
    creates a new box, so alarm and secondAlarm have independent counters.
*/

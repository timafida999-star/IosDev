import Cocoa

//ИЗИ ТАСКИ
//1
let fruits = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]
print("1.1 Третий фрукт:", fruits[2])

//2
var favoriteNumbers: Set<Int> = [7, 13, 21, 42]
favoriteNumbers.insert(100)
print("1.2 Обновлённый set:", favoriteNumbers)

//3
let languages = ["Swift": 2014, "Python": 1991, "Rust": 2010]
print("1.3 Год выхода Swift:", languages["Swift"]!)

//4
var colors = ["Red", "Green", "Blue", "Yellow"]
colors[1] = "Orange"
print("1.4 Обновлённые цвета:", colors)

//средние задачи
//1
let setA: Set<Int> = [1, 2, 3, 4]
let setB: Set<Int> = [3, 4, 5, 6]
print("2.1 Пересечение:", setA.intersection(setB))

//2
var scores = ["Alice": 85, "Bob": 90, "Charlie": 78]
scores.updateValue(95, forKey: "Bob")
print("2.2 Обновлённые баллы:", scores)

// 3
let arr1 = ["apple", "banana"]
let arr2 = ["cherry", "date"]
print("2.3 Объединённый массив:", arr1 + arr2)

//сложные
//1
var populations = ["Kazakhstan": 19_000_000, "USA": 331_000_000, "Japan": 125_000_000]
populations["Germany"] = 83_000_000
print("3.1 Обновлённые популяции:", populations)

// 2
let animals1: Set<String> = ["cat", "dog"]
let animals2: Set<String> = ["dog", "mouse"]
let unionResult = animals1.union(animals2)
print("3.2 Итог:", unionResult.subtracting(animals2))

//3
let studentGrades = [
    "Alice": [90, 85, 88],
    "Bob":   [75, 80, 95]
]
print("3.3 Вторая оценка Alice:", studentGrades["Alice"]![1])

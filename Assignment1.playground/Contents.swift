import UIKit

//step1
let firstName = "Tamerlan"
let lastName = "Issakhanov"
let age = 21
let birthYear = 2005
let isStudent = true
let height = 1.81
//bonus info
let city = "Almaty"
let major = "Computer Science"
//bonuss challenge
let currentYear = 2026
let calculatedAge = currentYear - birthYear
//step2
let hobby = "GYM"
let numberOfHobbies = 4
let favoriteNumber = 9
let isHobbyCreative = true
//emoji
let favoriteEmoji = "💪"
//emoji on var name
let 🎓 = isStudent
//goals
let futureGoals = "become a father"

let studentStatus = isStudent ? "I am currently a student" : "I am not currently a student"
let hobbyCreativity = isHobbyCreative ? "a creative hobby" : "not a very creative hobby"

//step3 summary
let lifeStory = "My name is \(firstName) \(lastName) \(favoriteEmoji), from \(city). I am \(age) years old (double-checked with math: \(calculatedAge)), born in \(birthYear), and I'm \(height)m tall. \(studentStatus) studying \(major). I enjoy \(hobby), which is \(hobbyCreativity). I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber). In the future, I want to \(futureGoals)."

//step4
//я все добавил вроде б, все этапы и на бонуски
print(lifeStory)

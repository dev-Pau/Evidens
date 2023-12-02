import UIKit
struct Discipline {
    static let medicine = "Medicine"
    static let odontology = "Odontology"
    static let pharmacy = "Pharmacy"
    static let physiotherapy = "Physiotherapy"
    static let nursing = "Nursing"
    static let veterinary = "Veterinary Medicine"
    static let psychology = "Psychology"
    static let podiatry = "Podiatry"
    static let nutrition = "Human Nutrition & Dietetics"
    static let optics = "Optics and Optometry"
    static let biomedical = "Biomedical Science"
    static let physical = "Physical Activity and Sport Science"
    static let speech = "Speech Therapy"
    static let occupational = "Occupational Therapy"
}

let allDisciplines = [
    Discipline.medicine, Discipline.odontology, Discipline.pharmacy,
    Discipline.physiotherapy, Discipline.nursing, Discipline.veterinary,
    Discipline.psychology, Discipline.podiatry, Discipline.nutrition,
    Discipline.optics, Discipline.biomedical, Discipline.physical,
    Discipline.speech, Discipline.occupational
]

func distributeDisciplines(disciplines: [String], numberOfArrays: Int) -> [[String]] {
    var arrays: [[String]] = Array(repeating: [], count: numberOfArrays)
    var totalLengths: [Int] = Array(repeating: 0, count: numberOfArrays)

    for discipline in disciplines {
        guard let minIndex = totalLengths.indices.min(by: { totalLengths[$0] < totalLengths[$1] }) else {
            // Handle the case where indices is empty
            continue
        }
        arrays[minIndex].append(discipline)
        totalLengths[minIndex] += discipline.count
    }

    return arrays
}

let numberOfArrays = 2 // Change this value based on the desired number of arrays
let distributedArrays = distributeDisciplines(disciplines: allDisciplines, numberOfArrays: numberOfArrays)

for (index, array) in distributedArrays.enumerated() {
    print("Array \(index + 1):", array)
}
var greeting = "Hello, playground"

import Foundation

struct ValidationIssue: Identifiable {
    enum Field { case firstName, lastName, birthDate, phone, email }

    let field: Field
    let message: String
    var id: String { message }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

/// Collects ALL validation errors at once (the assignment requires the full list).
enum PersonValidator {
    static func validate(firstName: String,
                         lastName: String,
                         birthDate: Date?,
                         phone: String,
                         email: String,
                         now: Date = Date()) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        if firstName.trimmed.isEmpty {
            issues.append(ValidationIssue(field: .firstName, message: "Imię jest wymagane."))
        }
        if lastName.trimmed.isEmpty {
            issues.append(ValidationIssue(field: .lastName, message: "Nazwisko jest wymagane."))
        }

        if let birthDate, birthDate > now {
            issues.append(ValidationIssue(field: .birthDate, message: "Data urodzenia nie może być w przyszłości."))
        }

        let phone = phone.trimmed
        if !phone.isEmpty {
            var onlyAllowedCharacters = true
            for (index, character) in phone.enumerated() {
                if character.isASCII && character.isNumber { continue }
                if character == " " || character == "-" { continue }
                if character == "+" && index == 0 { continue }
                onlyAllowedCharacters = false
                break
            }
            if !onlyAllowedCharacters {
                issues.append(ValidationIssue(field: .phone,
                    message: "Numer telefonu może zawierać tylko cyfry, spacje, myślniki oraz znak + na początku."))
            }
            let digitCount = phone.filter { $0.isASCII && $0.isNumber }.count
            if digitCount < 7 {
                issues.append(ValidationIssue(field: .phone,
                    message: "Numer telefonu musi zawierać co najmniej 7 cyfr."))
            }
        }

        let email = email.trimmed
        if email.isEmpty {
            issues.append(ValidationIssue(field: .email, message: "Adres e-mail jest wymagany."))
        } else {
            let pattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$"#
            if email.range(of: pattern, options: .regularExpression) == nil {
                issues.append(ValidationIssue(field: .email, message: "Adres e-mail ma nieprawidłowy format."))
            }
        }

        return issues
    }
}

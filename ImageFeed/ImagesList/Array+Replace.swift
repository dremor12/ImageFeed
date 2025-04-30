import Foundation

extension Array {
    func withReplaced(itemAt index: Index, newValue: Element) -> Self {
        var copy = self
        copy[index] = newValue
        return copy
    }
}

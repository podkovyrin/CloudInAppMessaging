//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

final class LocaleItem: NSObject, SearchSelectorItem {
    private(set) var attributedTitle: NSAttributedString

    /** These properties need @objc to make them key value compliant when filtering using NSPredicate,
     and so they are accessible and usable in Objective-C to interact with other frameworks.
     */
    @objc let code: String
    @objc let localizedCode: String

    init(code: String, localizedCode: String) {
        self.code = code
        self.localizedCode = localizedCode

        attributedTitle = LocaleItem.attributedString(code: code,
                                                      localizedCode: localizedCode,
                                                      searchQuery: "")
    }

    func updateAttributedTitle(with searchQuery: String) {
        attributedTitle = LocaleItem.attributedString(code: code,
                                                      localizedCode: localizedCode,
                                                      searchQuery: searchQuery)
    }
}

private extension LocaleItem {
    static func attributedString(code: String, localizedCode: String, searchQuery: String) -> NSAttributedString {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let textColor = Styles.Colors.textColor
        let string = [code, localizedCode].joined(separator: " - ")
        if searchQuery.isEmpty {
            let attributes = [NSAttributedString.Key.font: font,
                              NSAttributedString.Key.foregroundColor: textColor]

            return NSAttributedString(string: string, attributes: attributes)
        }
        else {
            return NSAttributedString.attributedText(string,
                                                     font: font,
                                                     textColor: textColor,
                                                     highlightedText: searchQuery,
                                                     highlightedTextColor: Styles.Colors.tintColor)
        }
    }
}

final class LocaleSelectorModel: SearchSelectorModel {
    var items: [LocaleItem] {
        if searchQuery.isEmpty {
            return allItems
        }
        else {
            return filteredItems
        }
    }

    var selectedIndexes = Set<Int>()

    private var allItems: [LocaleItem]
    private var searchQuery = ""
    private var filteredItems = [LocaleItem]()

    init(codes: [String], localizeCode: (String) -> (String), selectedIndexes: Set<Int>) {
        var items = [LocaleItem]()
        for code in codes {
            let localizedCode = localizeCode(code)
            let localeItem = LocaleItem(code: code, localizedCode: localizedCode)
            items.append(localeItem)
        }
        allItems = items

        self.selectedIndexes = selectedIndexes
    }

    func filterItems(searchQuery: String) {
        self.searchQuery = searchQuery

        let predicate = searchPredicate(for: searchQuery)
        filteredItems = allItems.filter { predicate.evaluate(with: $0) }
        allItems.forEach { $0.updateAttributedTitle(with: searchQuery) }
    }

    // MARK: Private

    private func searchPredicate(for query: String) -> NSPredicate {
        let searchItems = query.components(separatedBy: " ") as [String]

        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            findMatches(searchString: searchString)
        }

        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)

        return finalCompoundPredicate
    }

    private func findMatches(searchString: String) -> NSCompoundPredicate {
        enum ExpressionKeys: String {
            case code
            case localizedCode
        }

        var searchItemsPredicate = [NSPredicate]()

        let searchKeyPaths = [ExpressionKeys.code.rawValue, ExpressionKeys.localizedCode.rawValue]
        for keyPath in searchKeyPaths {
            let leftExpression = NSExpression(forKeyPath: keyPath)
            let rightExpression = NSExpression(forConstantValue: searchString)

            let comparisonPredicate =
                NSComparisonPredicate(leftExpression: leftExpression,
                                      rightExpression: rightExpression,
                                      modifier: .direct,
                                      type: .contains,
                                      options: [.caseInsensitive, .diacriticInsensitive])

            searchItemsPredicate.append(comparisonPredicate)
        }

        let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)

        return orMatchPredicate
    }
}

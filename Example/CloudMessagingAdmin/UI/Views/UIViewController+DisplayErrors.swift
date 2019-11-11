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

import CloudKit
import UIKit

extension UIViewController {
    func displayErrorsIfNeeded(_ errors: [Error]) {
        guard !errors.isEmpty else { return }

        let message = errors.map { $0.userMessage }.joined(separator: "\n\n")

        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)

        present(alert, animated: true)
    }
}

extension Error {
    var userMessage: String {
        if let error = self as? CKError {
            switch error.code {
            case .notAuthenticated:
                return "Not authenticated. iCloud account is required."
            default:
                return localizedDescription
            }
        }

        return localizedDescription
    }
}

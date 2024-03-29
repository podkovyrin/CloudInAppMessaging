//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Andrew Podkovyrin. All rights reserved.
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
import Foundation
import UIKit

enum CloudKitErrorHandler {
    static let maxRetryCount = 3

    static func retryIfPossible(with error: Error?, retryCount: Int, block: @escaping () -> Void) -> Bool {
        guard let error = error as? CKError else {
            return false
        }

        if retryCount >= maxRetryCount {
            return false
        }

        if let retryAfter = error.retryAfterSeconds {
            cksLog("Retrying after \(retryAfter)...")
            DispatchQueue.main.asyncAfter(deadline: .now() + retryAfter, execute: block)

            return true
        }
        else if error.code == .serverResponseLost {
            // The server received and processed this request, but the response was lost due to a network failure.
            // There is no guarantee that this request succeeded.
            // Your client should re-issue the request (if it is idempotent)

            cksLog("Server response lost, retrying now...")
            DispatchQueue.main.async(execute: block)

            return true
        }

        return false
    }
}

extension CKError {
    var isUserActionNeeded: Bool {
        // userDeletedZone: ask the user for permission to upload the data again.
        //
        // quotaExceeded: In the private database: The user has run out of iCloud storage space.
        //                Prompt the user to go to iCloud Settings to manage storage.
        //
        // incompatibleVersion: Alert your user to upgrade to the newest version of your app
        //
        // notAuthenticated: Prompt the user to go to Settings and sign in to iCloud.

        return code == .userDeletedZone
            || code == .quotaExceeded
            || code == .incompatibleVersion
            || code == .notAuthenticated
    }
}

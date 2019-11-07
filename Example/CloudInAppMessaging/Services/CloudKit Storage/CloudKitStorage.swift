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
import UIKit

// swiftlint:disable file_length

protocol CloudKitStorageDelegate: AnyObject {
    func cloudKitStorage(_ cloudKitStorage: CloudKitStorage, didFailedWithError error: CKError)
}

final class CloudKitStorage {
    weak var delegate: CloudKitStorageDelegate?

    private let container = CKContainer(identifier: "iCloud.com.podkovyrin.CloudInAppMessaging.test")
    private let database: CKDatabase
    private let operationQueue = ANOperationQueue()

    init() {
        // don't allow simultaneous operations to prevent collisions
        operationQueue.maxConcurrentOperationCount = 1

        database = container.publicCloudDatabase
    }

    // MARK: - Public

    func fetch(query: CKQuery, completion: @escaping ([CKRecord], [Error]) -> Void) {
        cksLog("Fetching objects...")

        let configuration = defaultConfiguration()

        let operation = FetchOperation(configuration: configuration, query: query)
        operation.delegate = self
        operation.addCompletionObserver { operation, errors in
            completion(operation.records, errors)
        }
        operationQueue.addOperation(operation)
    }

    func save(recordsToSave: [CKRecord],
              recordIDsToDelete: [CKRecord.ID],
              completion: @escaping ([Error]) -> Void) {
        if recordsToSave.isEmpty && recordIDsToDelete.isEmpty {
            return
        }

        cksLog("Saving objects...")

        let configuration = defaultConfiguration()

        let operation = ModifyRecordsOperation(configuration: configuration,
                                               recordsToSave: recordsToSave,
                                               recordIDsToDelete: recordIDsToDelete)
        operation.delegate = self
        operation.addCompletionObserver { _, errors in
            completion(errors)
        }
        operationQueue.addOperation(operation)
    }

    // MARK: Private

    private func defaultConfiguration() -> CloudKitOperationConfiguration {
        let operationConfiguaration = CKOperation.Configuration()
        operationConfiguaration.qualityOfService = .userInitiated

        var configuration = CloudKitOperationConfiguration(container: container,
                                                           database: database)
        configuration.operationConfiguaration = operationConfiguaration

        return configuration
    }
}

// MARK: CloudKitOperationDelegate

extension CloudKitStorage: CloudKitOperationDelegate {
    func operationRequiresUserAction(_ operation: Operation, error: CKError) {
        DispatchQueue.main.async {
            self.delegate?.cloudKitStorage(self, didFailedWithError: error)
        }
    }
}

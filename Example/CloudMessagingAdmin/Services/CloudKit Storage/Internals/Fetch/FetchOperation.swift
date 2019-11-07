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
import Foundation

final class FetchOperation: BaseCloudKitOperation {
    private let query: CKQuery
    private let zone: CKRecordZone?
    private weak var operation: CKOperation?

    /// Result
    private(set) var records = [CKRecord]()

    init(configuration: CloudKitOperationConfiguration, query: CKQuery, zone: CKRecordZone? = nil) {
        self.query = query
        self.zone = zone

        super.init(configuration: configuration)
    }

    override func execute() {
        let completion: (Error?) -> Void = { [weak self] error in
            guard let self = self else { return }

            self.finishWithError(error)
        }

        fetch(with: query, zone: zone, completion: completion)
    }

    override func cancel() {
        operation?.cancel()
        super.cancel()
    }

    // MARK: Private

    private func fetch(with query: CKQuery,
                       zone: CKRecordZone?,
                       completion: @escaping (Error?) -> Void) {
        let operation = CKQueryOperation(query: query)
        if let zone = zone {
            operation.zoneID = zone.zoneID
        }

        performFetchOperation(operation, completion: completion)
    }

    private func fetch(with cursor: CKQueryOperation.Cursor,
                       completion: @escaping (Error?) -> Void) {
        let operation = CKQueryOperation(cursor: cursor)

        performFetchOperation(operation, completion: completion)
    }

    private func performFetchOperation(_ operation: CKQueryOperation,
                                       completion: @escaping (Error?) -> Void) {
        if let operationConfiguration = configuration {
            operation.configuration = operationConfiguration
        }

        operation.recordFetchedBlock = { [weak self] record in
            guard let self = self else { return }
            self.records.append(record)
        }

        operation.queryCompletionBlock = { [weak self] cursor, error in
            guard let self = self, !self.isCancelled else { return }

            // has more data to fetch
            if let cursor = cursor {
                self.fetch(with: cursor, completion: completion)

                return
            }

            guard let error = error else {
                completion(nil)

                return
            }

            let retrying = CloudKitErrorHandler.retryIfPossible(with: error,
                                                                retryCount: self.retryCount) { [weak self] in
                guard let self = self else { return }
                self.records = []
                self.fetch(with: self.query, zone: self.zone, completion: completion)
            }

            if retrying {
                self.retryCount += 1
            }
            else {
                cksLog("Error fetching records: \(error)")

                completion(error)
            }
        }

        database.add(operation)
        self.operation = operation
    }
}

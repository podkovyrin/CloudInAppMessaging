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

import CloudInAppMessaging
import CloudKit
import Foundation

final class AlertCampaignCloudKitService {
    private lazy var cloudKitStorage: CloudKitStorage = {
        let storage = CloudKitStorage()
        storage.delegate = self
        return storage
    }()

    func fetch(completion: @escaping ([CLMAlertCampaign], [Error]) -> Void) {
        let query = CKQuery(recordType: CLMAlertCampaign.RecordType, predicate: NSPredicate(value: true))

        cloudKitStorage.fetch(query: query) { [weak self] records, errors in
            guard let self = self else { return }

            if !errors.isEmpty {
                completion([], errors)
            }
            else {
                self.fetchTranslations(for: records) { alerts, errors in
                    completion(alerts, errors)
                }
            }
        }
    }

    func save(_ alertCampaign: CLMAlertCampaign, completion: @escaping ([Error]) -> Void) {
        let alertRecord = alertCampaign.record()
        let translationRecords = alertCampaign.translations.map { $0.record() }

        var recordsToSave = [CKRecord]()
        recordsToSave.append(alertRecord)
        recordsToSave.append(contentsOf: translationRecords)

        cloudKitStorage.save(recordsToSave: recordsToSave,
                             recordIDsToDelete: [],
                             completion: completion)
    }

    func delete(_ alertCampaign: CLMAlertCampaign, completion: @escaping ([Error]) -> Void) {
        let alertRecord = alertCampaign.record()
        let recordID = alertRecord.recordID

        cloudKitStorage.save(recordsToSave: [],
                             recordIDsToDelete: [recordID],
                             completion: completion)
    }

    // MARK: Private

    private func fetchTranslations(for records: [CKRecord],
                                   completion: @escaping ([CLMAlertCampaign], [Error]) -> Void) {
        var alerts = [CLMAlertCampaign]()
        var allErrors = [Error]()

        let dispatchGroup = DispatchGroup()
        for record in records {
            dispatchGroup.enter()

            fetchTranslations(for: record) { alertCampaign, errors in
                if let alertCampaign = alertCampaign {
                    alerts.append(alertCampaign)
                }
                allErrors.append(contentsOf: errors)

                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            let sortedAlerts = alerts.sorted { alert1, alert2 -> Bool in
                if let s1 = alert1.startDate, let s2 = alert2.startDate {
                    return s1 < s2
                }

                if let e1 = alert1.startDate, let e2 = alert2.startDate {
                    return e1 < e2
                }

                return alert1.identifier < alert2.identifier
            }
            completion(sortedAlerts, allErrors)
        }
    }

    private func fetchTranslations(for record: CKRecord,
                                   completion: @escaping (CLMAlertCampaign?, [Error]) -> Void) {
        let predicate = NSPredicate(format: "%K = %@",
                                    CLMAlertCampaign.ReferenceKey,
                                    record.recordID)
        let query = CKQuery(recordType: CLMAlertTranslation.RecordType, predicate: predicate)
        cloudKitStorage.fetch(query: query) { records, errors in
            if !errors.isEmpty {
                completion(nil, errors)
            }
            else {
                let translations = records.map { CLMAlertTranslation(record: $0) }
                let alert = CLMAlertCampaign(record: record)
                alert.translations = translations

                completion(alert, [])
            }
        }
    }
}

extension AlertCampaignCloudKitService: CloudKitStorageDelegate {
    func cloudKitStorage(_ cloudKitStorage: CloudKitStorage, didFailWithError error: Error) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let rootController = appDelegate.window?.rootViewController else {
            fatalError("Inconsistent state")
        }

        rootController.displayErrorsIfNeeded([error])
    }
}

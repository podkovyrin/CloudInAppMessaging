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

class BaseCloudKitOperation: ANOperation {
    weak var delegate: CloudKitOperationDelegate?

    let database: CKDatabase
    let configuration: CKOperation.Configuration?
    var retryCount = 0

    init(configuration: CloudKitOperationConfiguration, enableDefaultConditions: Bool = false) {
        database = configuration.database
        self.configuration = configuration.operationConfiguaration

        super.init()

        if enableDefaultConditions {
            addCondition(configuration.cloudContainerCondition)
        }
    }

    override func finished(_ errors: [Error]) {
        guard let error = errors.first as? CKError, error.isUserActionNeeded else {
            return
        }
        delegate?.operationRequiresUserAction(self, error: error)
    }
}

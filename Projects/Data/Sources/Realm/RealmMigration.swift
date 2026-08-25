//
//  RealmMigration.swift
//  BanGiDa
//

import Foundation
import RealmSwift
import Domain

/// Realm 스키마 마이그레이션 설정.
///
/// 원래 `AppDelegate.configureRealmMigration()`에 있었으나, Application 계층이
/// Realm 스키마(`Diary`)를 직접 알아야 해서 Data 모듈로 내렸다. 동작은 그대로다.
package enum RealmMigration {
    package static func configureDefaultConfiguration() {
        let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldVersion in
            if oldVersion < 1 {
                migration.enumerateObjects(ofType: Diary.className()) { _, newObject in
                    newObject?["repeatRule"] = AlarmRepeat.none.rawValue
                }
            }
        })

        Realm.Configuration.defaultConfiguration = config
    }
}

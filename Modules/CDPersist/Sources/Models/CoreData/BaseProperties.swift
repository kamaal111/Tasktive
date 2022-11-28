//
//  BaseProperties.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 28/11/2022.
//

import ManuallyManagedObject

let baseProperties: [ManagedObjectPropertyConfiguration] = [
    ManagedObjectPropertyConfiguration(name: "updateDate", type: .date, isOptional: false),
    ManagedObjectPropertyConfiguration(name: "kCreationDate", type: .date, isOptional: false),
    ManagedObjectPropertyConfiguration(name: "id", type: .uuid, isOptional: false),
]

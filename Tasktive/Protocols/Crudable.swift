//
//  Crudable.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import Foundation

protocol Crudable {
    associatedtype ReturnType: Crudable
    associatedtype Arguments
    associatedtype CrudErrors: Error

    static func create(with args: Arguments) -> Result<ReturnType, CrudErrors>
}

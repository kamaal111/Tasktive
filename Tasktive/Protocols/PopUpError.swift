//
//  PopUpError.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//

import PopperUp
import Foundation

protocol PopUpError: Error {
    var style: PopperUpStyles { get }
    var timeout: TimeInterval? { get }
}

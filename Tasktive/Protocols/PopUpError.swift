//
//  PopUpError.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//

import Foundation
import PopperUp

protocol PopUpError: Error {
    var style: PopperUpStyles { get }
    var timeout: TimeInterval? { get }
}

//
//  OrderSessionError.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 19.12.25.
//

import Foundation


enum OrderSessionError: Error, LocalizedError, UserRepresentableError {
    case network(HTTPError)
    case errorCreatingPDFFile
    case errorSavingPDFFile
}

extension OrderSessionError {
    var userMessage: String {
        switch self {
        case .network(let error): error.userMessage
        case .errorCreatingPDFFile: "Unable to generate the PDF."
        case .errorSavingPDFFile: "Unable to save the PDF."
        }
    }
}


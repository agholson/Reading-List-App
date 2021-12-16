//
//  Books.swift
//  Reading List App
//
//  Created by CodeWithChris on 2021-04-23.
//

import Foundation
import FirebaseFirestoreSwift


// Data structure for books
struct Book: Hashable, Identifiable, Codable {
    // ID is the document ID in the Firestore database
    @DocumentID var id: String?
    var title: String
    var author: String
    var genre: String
    var status: String
    var pages: Int
    var rating: Int
}

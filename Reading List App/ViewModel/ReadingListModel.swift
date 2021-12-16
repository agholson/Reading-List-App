//
//  ReadingListModel.swift
//  Reading List App
//
//  Created by CodeWithChris on 2021-04-23.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift


class ReadingListModel: ObservableObject {
    // Variables to temporarily store the genres and books information from the database
    @Published var genres : [String] = []
    // Dictionary to match Genres to an array of Books
    @Published var books : [String: [Book]] = [:]
    
    @Published var statuses : [String] = ["Plan to read", "Reading", "On hold", "Completed"]
    
    // Used to communicate with the Firestore database
    private var db = Firestore.firestore()
    
    init() {
        getGenres()
    }
    
    // TODO: Complete all Firestore functions
    /// Adds a document with auto-genrated ID to the books collection in the Firestore database
    ///
    /// Parameters:
    ///     - book: The book to add to the database
    func addBook(book: Book) {
        do {
            // Uses SwiftUI/ the Codable protocol to quickly add the new document
            let _ = try db.collection("books").addDocument(from: book)
        }
        catch {
            print(error)
        }
    }
    
    /// Deletes a specific book document in the books collection in the Firestore database
    ///
    /// Parameters:
    ///     - book: The book to delete in  the database
    func deleteBook(book: Book) {
        
        // Get the reference of the document to delete
        let bookToDelete = db.collection("books").document(book.id!)
        
        // Delete the book
        bookToDelete.delete()
        
    }
    
    /// Updates a book document's genre, status, and rating fields, in the books collection in the Firestore database
    ///
    /// Parameters:
    ///     - book: The book to update in the database
    func updateBookData(book: Book) {
        // Reference the book we want to change
        let bookToUpdate = db.collection("books").document(book.id!)
        
        // Try to update the book with the new data
        do {
            try bookToUpdate.setData(from: book.self, merge: true)
        }
        catch {
            print("could not successfully update book")
        }
        
    }
    
    /// Queries the books collection in the Firestore database and finds all book documents with the matching "genre" field value. Updates the "books" class field with the queried book documents' data
    ///
    /// Parameters:
    ///     - genre: The genre to match when querying the book documents
    func getBooksByGenre(genre: String) {
        
        let collection = db.collection("books")
    
        // Create a query to only bring the books in this genre
        let query = collection.whereField("genre", in: [genre])
        
        // Execute the query
        query.getDocuments { querySnapshot, error in
            // Make sure documents were returned
            guard let documents = querySnapshot?.documents else {
              print("No documents")
              return
            }
            
            // Assign the returned non-nil books to this genre key in our self.books dictionary
            self.books[genre] = documents.compactMap { queryDocumentSnapshot -> Book? in
              return try? queryDocumentSnapshot.data(as: Book.self)
            }
            
        }
        
    }
    
    /// Adds a genre document with the genre as the document ID to the genres collection
    ///
    /// Parameters:
    ///     - genre: The name of the genre to add to the Firestore database
    func addGenre(genre: String) {
        // Reference the genres collection
        let collection = db.collection("genres")
        
        // Create a new genre with the ID as a lower case string
        collection.document(genre.lowercased()).setData(["name":genre.lowercased()])
                
        // Fetch the latest genres
        getGenres()
        
    }
    
    /// Gets all genre documents in the genres collection in the Firestore database and updates the "genres" class field with the genre document ID names.
    ///
    /// Parameters:
    ///     - genre: The genre to match when querying the book documents
    func getGenres() {
        
        // Define collection
        let collection = db.collection("genres")
        
        // Retrieve all of the genrees from the genres collection
        
        collection.getDocuments { querySnapshot, error in
            // Check for an error and handle it
            if let error = error {
                // Handle the error
                print("Error line 108: \(error)")
            }
            // Else we see if we could get a querySnapshot
            else if let querySnapshot = querySnapshot {
                
                // Replace the current list of genres with a new list
                self.genres = []
                
                // Add the The document ID from each as the String for our genres list
                for doc in querySnapshot.documents {
                                        
                    // Add the document ID as a value in our genres list
                    self.genres.append(doc.documentID.capitalized)
                }

            }
            // Else no data was returned
            else {
                print("No genres returned line 121")

            }
        }
        
    }

}

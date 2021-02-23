//
//  SqliteManager.swift
//  SaharaGo
//
//  Created by Ritesh on 18/12/20.
//

import Foundation
import SQLite
import UIKit

class SqliteManager: NSObject {
    
    let productsTable = Table("products")
    let id = Expression<Int>("id")
    let prodName = Expression<String>("prodName")
    let prodDescription = Expression<String>("prodDescription")
    let productStock = Expression<String>("prodStock")
    let productPrice = Expression<String>("prodPrice")
    let prodCurrency = Expression<String>("prodCurrency")
    let prodDiscountPercent = Expression<String>("prodDiscountPercent")
    let prodDiscountPrice = Expression<String>("prodDiscountPrice")
    let prodCount = Expression<Int>("prodCount")
    let prodId = Expression<String>("prodId")
    
    var database : Connection!
    static let sharedInstance = SqliteManager()
    
    func matchProducts(_ prodIdToCompare: String) -> Bool {
        
        do {
            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let fileUrl = documentDirectory.appendingPathComponent("Sahara").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
            
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
        self.createTable()
        return self.getProducts(prodIdToCompare)
        
    }
    
    func createTable() {
        
        let createNotesTable = productsTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.prodName)
            table.column(self.prodDescription)
            table.column(self.productStock)
            table.column(self.productPrice)
            table.column(self.prodCurrency)
            table.column(self.prodDiscountPercent)
            table.column(self.prodDiscountPrice)
            table.column(self.prodCount)
            table.column(self.prodId)
        }
        
        do {
            try self.database.run(createNotesTable)
            print("notes table created.")
            
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
    }
    
    func getProducts(_ prodIdToCompare: String) -> Bool {
        var isExist: Bool = false
        do {
            let notes = try self.database.prepare(self.productsTable)
            
            for note in notes {
                
                let prodId = note[self.prodId]
//                let prodName = note[self.prodName]
//                let prodDesc = note[self.prodDescription]
//                let prodStock = note[self.productStock]
//                let productPrice = note[self.productPrice]
//                let prodCurrency = note[self.prodCurrency]
//                let prodDiscountPercent = note[self.prodDiscountPercent]
//                let prodDiscountPrice = note[self.prodDiscountPrice]
//                let prodCount = note[self.prodCount]
                
//                cartProducts.append(cartProductListStruct.init(currency: prodCurrency, description: prodDesc, stock: prodStock, productId: prodId, price: productPrice, discountedPrice: prodDiscountPrice, discountPercent: prodDiscountPercent, name: prodName, quantity: "\(prodCount)"))
            
                if prodId == prodIdToCompare {
                    isExist = true
                    break
                }
                
            }
            
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
        return isExist
    }
    
    func fetchDbCount() -> Int {
        do {
            let notes = try self.database.prepare(self.productsTable)
            cartProducts.removeAll()
            for note in notes {
                
                let prodId = note[self.prodId]
                let prodName = note[self.prodName]
                let prodDesc = note[self.prodDescription]
                let prodStock = note[self.productStock]
                let productPrice = note[self.productPrice]
                let prodCurrency = note[self.prodCurrency]
                let prodDiscountPercent = note[self.prodDiscountPercent]
                let prodDiscountPrice = note[self.prodDiscountPrice]
                let prodCount = note[self.prodCount]
                
                cartProducts.append(cartProductListStruct.init(currency: prodCurrency, description: prodDesc, stock: prodStock, productId: prodId, price: productPrice, discountedPrice: prodDiscountPrice, discountPercent: prodDiscountPercent, name: prodName, quantity: "\(prodCount)"))
                
            }
            
            
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
        return cartProducts.count
        
    }
    
}

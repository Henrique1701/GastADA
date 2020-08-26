//
//  Gastos+CoreDataProperties.swift
//  GastADA
//
//  Created by José Henrique Fernandes Silva on 19/08/20.
//  Copyright © 2020 José Henrique Fernandes Silva. All rights reserved.
//
//

import Foundation
import CoreData


extension Gastos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gastos> {
        return NSFetchRequest<Gastos>(entityName: "Gastos")
    }

    @NSManaged public var valor: Double
    @NSManaged public var descricao: String

}

//
//  ModelTree.swift
//  CRMCall092016
//
//  Created by Hanbiro on 10/17/16.
//  Copyright © 2016 xuanvinhtd. All rights reserved.
//

import Cocoa

protocol SourceListItemDisplayable: class {
    var name: String { get }
    var phone: String { get }
    var icon: NSImage? { get }
    func cellID() -> String
    func childAtIndex(index: Int) -> SourceListItemDisplayable?
}

extension SourceListItemDisplayable {
    func cellID() -> String { return "DataCell" }
    func count() -> Int { return 0 }
    func childAtIndex(index: Int) -> SourceListItemDisplayable? { return nil }
}

class Root: NSObject, SourceListItemDisplayable {
    let name: String
    var phone: String = ""
    var rootI: [RootI] = []
    var icon: NSImage?
    
    var rootTree: RootTree
    
    init(icon: NSImage, rootTree: RootTree) {
        self.name = rootTree.title
        self.icon = icon
        self.rootTree = rootTree
        super.init()
    }
    
    func cellID() -> String {
        return "HeaderCell"
    }
    
    func count() -> Int {
        return rootI.count
    }
    
    func childAtIndex(index: Int) -> SourceListItemDisplayable? {
        return rootI[index]
    }
}

class RootI: NSObject, SourceListItemDisplayable {
    let name: String
    var phone: String = ""
    var child: [Child] = []
    let icon: NSImage?
    
    var rootTree: RootChild
    
    init(icon: NSImage, rootTree: RootChild) {
        self.name = rootTree.title
        self.icon = icon
        self.rootTree = rootTree
        super.init()
    }
    
    func count() -> Int {
        return child.count
    }
    
    func childAtIndex(index: Int) -> SourceListItemDisplayable? {
        return child[index]
    }
}

class Child: NSObject, SourceListItemDisplayable {
    let name: String
    var phone: String = ""
    let rootI: RootI
    let icon: NSImage?
    
    var childTree: ChildTree
    
    init(icon: NSImage?, childTree: ChildTree, rootI: RootI) {
        self.phone = childTree.localphone
        self.name = childTree.title
        self.rootI = rootI
        self.icon = icon
        self.childTree = childTree
    
        super.init()
        rootI.child.append(self)
    }
}

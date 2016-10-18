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
    var rootI: [RootI] = []
    var icon: NSImage?
    
    var groupMngId: String
    var isFolder: Bool = true
    var isLazy: Bool = true
    
    init(name: String, icon: NSImage, groupId: String, isFolder: Bool, isLazy: Bool) {
        self.name = name
        self.icon = icon
        self.groupMngId = groupId
        self.isFolder = isFolder
        self.isLazy = isLazy
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
    var child: [Child] = []
    let icon: NSImage?
    
    var groupMngID: String
    var isFolder: Bool = true
    var isLazy: Bool = true
    
    init(name: String, icon: NSImage, groupId: String, isFolder: Bool, isLazy: Bool) {
        self.name = name
        self.icon = icon
        self.groupMngID = groupId
        self.isFolder = isFolder
        self.isLazy = isLazy
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
    let rootI: RootI
    let icon: NSImage?
    
    let nameEng: String?
    let nameJp: String?
    let nameCh: String?
    let nameChSimp: String?
    let userNo: String?
    let userGroupId: String?
    let localPhone: String?
    let groupID: String?
    let isFolder: Bool?
    let isLazy: Bool?
    
    init(name: String, icon: NSImage?, nameEng: String?, nameJp: String?, nameCh: String?, nameChSimp: String?, userNo: String?, userGroupId: String?, localPhone: String?, groupID: String?, isFolder: Bool?, isLazy: Bool?, rootI: RootI) {
        self.name = name
        self.rootI = rootI
        self.icon = icon
        self.nameEng = nameEng
        self.nameJp = nameJp
        self.nameCh = nameCh
        self.nameChSimp = nameChSimp
        self.userNo = userNo
        self.userGroupId = userGroupId
        self.localPhone = localPhone
        self.groupID = groupID
        self.isFolder = isFolder
        self.isLazy = isLazy
    
        super.init()
        rootI.child.append(self)
    }
}

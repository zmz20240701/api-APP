//
//  ModelType.swift
//  YT-Vapor-APP
//
//  Created by 赵康 on 2024/9/26.
//

import Foundation

enum ModelType: Identifiable {
    case add, update(Song)
    
    var id: String {
        switch self {
        case .add:
            return "新增"
        case .update:
            return "更新"
        }
    }
}

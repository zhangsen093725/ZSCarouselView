//
//  ZSMediaPreviewModel.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/4/8.
//

import UIKit

@objc public enum ZSMediaType: Int {
    case Image = 1, Video = 2, Audio = 3
}

@objcMembers open class ZSMediaPreviewModel: NSObject {
    
    /// 媒体文件（URL、UIImage）
    public var mediaFile: Any?
    
    /// 缩略（封面）图片（URL、UIImage）
    public var thumbImage: Any?
    
    /// 媒体类型
    public var mediaType: ZSMediaType = .Image
    
    /// 媒体的文件大小，单位Btye
    public var mediaBtye: Float = 0
}

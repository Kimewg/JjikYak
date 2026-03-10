//
//  Extensions.swift
//  JjikYak
//
//  Created by 김은서 on 2/20/26.
//
import UIKit
import SnapKit

// 취소선 설정
extension String {
    func strikeThrough(color: UIColor) -> NSAttributedString {
        return NSAttributedString(
            string: self,
            attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: color
            ]
        )
    }
}

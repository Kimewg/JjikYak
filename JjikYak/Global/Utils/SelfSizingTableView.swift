//
//  SelfSizingTableView.swift
//  JjikYak
//
//  Created by 김은서 on 2/24/26.
//
import UIKit

// 스크롤 뷰 내부에서 셀 개수에 맞춰 스스로 높이를 결정하는 테이블뷰
final class SelfSizingTableView: UITableView {
    override var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

//
//  HistoryPillCell.swift
//  JjikYak
//
//  Created by 김은서 on 2/24/26.
//
import UIKit
import SnapKit

final class HistoryPillCell: UITableViewCell {
    static let identifier = "HistoryPillCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let pillNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        configureUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        pillNameLabel.text = nil
        pillNameLabel.attributedText = nil
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func configureUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(pillNameLabel)
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        pillNameLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    func configure(with title: String, isTaken: Bool) {
        if isTaken {
            pillNameLabel.attributedText = title.strikeThrough(color: .systemGray)
        } else {
            pillNameLabel.attributedText = NSAttributedString(
                string: title,
                attributes: [
                    .strikethroughStyle: 0,
                    .foregroundColor: UIColor.label
                ]
            )
        }
    }
}

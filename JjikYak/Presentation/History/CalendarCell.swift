//
//  CalendarCell.swift
//  JjikYak
//
//  Created by 김은서 on 2/24/26.
//

import UIKit
import SnapKit

enum DailyPillStatus {
    case none
    case completed
    case incomplete
    case planned
}

final class CalendarCell: UICollectionViewCell {
    static let identifier = "CalendarCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let clipIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        imageView.image = UIImage(systemName: "paperclip", withConfiguration: config)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        containerView.backgroundColor = .clear
        containerView.layer.borderColor = UIColor.clear.cgColor
        dayLabel.textColor = .label
        clipIcon.isHidden = true
    }
    
    private func configureUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(dayLabel)
        containerView.addSubview(clipIcon)
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        dayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.centerX.equalToSuperview()
        }
        
        clipIcon.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }
    }

    func configure(date: Date?, status: DailyPillStatus, isSelected: Bool) {
        guard let date = date else {
            dayLabel.text = ""
            return
        }
        
        // 일(Day)만 추출해서 라벨에 표시
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        dayLabel.text = "\(day)"
        
        // 선택된 상태일 때 (24일 스크린샷처럼)
        if isSelected {
            containerView.backgroundColor = .systemBlue
            containerView.layer.borderColor = UIColor.clear.cgColor
            dayLabel.textColor = .white
            clipIcon.isHidden = true // 선택 시 보통 아이콘 숨기거나 흰색으로 바꿈
            return
        }
        
        // 선택되지 않았을 때 상태별 UI 처리
        switch status {
        case .none:
            containerView.layer.borderColor = UIColor.clear.cgColor
            containerView.backgroundColor = .clear
            clipIcon.isHidden = true
            
        case .completed:
            containerView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.5).cgColor
            containerView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            clipIcon.tintColor = .systemGreen
            clipIcon.isHidden = false
            
        case .incomplete:
            containerView.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.5).cgColor
            containerView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
            clipIcon.tintColor = .systemOrange
            clipIcon.isHidden = false
            
        case .planned:
            containerView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
            containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
            clipIcon.tintColor = .systemBlue
            clipIcon.isHidden = false
        }
    }
}

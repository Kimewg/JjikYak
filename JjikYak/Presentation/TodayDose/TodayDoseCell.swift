import UIKit
import RxSwift

final class TodayDoseCell: UITableViewCell {
    static let identifier = "TodayDoseCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private let pillNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    let checkButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemBlue

        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.configuration = config
        return button
    }()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        pillNameLabel.attributedText = nil
        timeLabel.text = nil
    }
    
    private func configureUI() {

        contentView.addSubview(containerView)
        containerView.addSubview(pillNameLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(checkButton)
        

        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        

        checkButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(44)
        }
        
        pillNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(checkButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(pillNameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(pillNameLabel)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(pillName: String, time: String, isTaken: Bool) {
        
        timeLabel.text = time
        
        let imageName = isTaken ? "checkmark.circle.fill" : "circle"
        checkButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        if isTaken {
            pillNameLabel.attributedText = pillName.strikeThrough(color: .systemGray)
        } else {
            pillNameLabel.attributedText = NSAttributedString(
                string: pillName,
                attributes: [
                    .foregroundColor: UIColor.label
                ]
            )
        }
    }
}

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

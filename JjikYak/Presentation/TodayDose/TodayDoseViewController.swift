//
//  TodayDoseViewController.swift
//  JjikYak
//
//  Created by 김은서 on 2/20/26.
//
import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa

class TodayDoseViewController: UIViewController, UITableViewDelegate {
    
    private var doses = BehaviorRelay<[Pill]>(value: [])
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTodayPills()
    }
    
    private let toDayLabel: UILabel = {
        let label = UILabel()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        
        label.text = formatter.string(from: Date())
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        
        return label
    }()
    
    private let dosePill: UILabel = {
        let label = UILabel()
        label.text = "오늘 먹을 약"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        
        return label
    }()
    
    private let dosePillTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private func configureUI() {
        view.addSubview(toDayLabel)
        view.addSubview(dosePill)
        view.addSubview(dosePillTableView)
        
        toDayLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        dosePill.snp.makeConstraints {
            $0.top.equalTo(toDayLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }
        
        dosePillTableView.snp.makeConstraints {
            $0.top.equalTo(dosePill.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureTableView() {
        dosePillTableView.delegate = self
        
        dosePillTableView.register(
            TodayDoseCell.self,
            forCellReuseIdentifier: TodayDoseCell.identifier
        )
    }
    
    private func fetchTodayPills() {
        let fetchedPills = CoreDataManager.shared.fetchPills(on: Date())
        doses.accept(fetchedPills)
    }
    
    private func bind() {
        doses
            .bind(to: dosePillTableView.rx.items(
                cellIdentifier: TodayDoseCell.identifier,
                cellType: TodayDoseCell.self)
            ) { [weak self] (row, pill, cell) in
                
                // 시간 데이터 포맷 (Date -> String)
                let timeString = self?.formatDate(pill.alarmTime) ?? ""
                
                // 커스텀 셀 내부의 UI 업데이트 함수 호출
                cell.configure(
                    pillName: pill.title ?? "약 이름 없음",
                    time: timeString,
                    isTaken: pill.isTaken
                )
                
                // 체크 버튼 클릭 시 상태 변경 (RxSwift)
                cell.checkButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.togglePillStatus(pill: pill)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    // 토글 상태 저장 함수
    private func togglePillStatus(pill: Pill) {
        pill.isTaken.toggle()
        CoreDataManager.shared.saveContext()
        fetchTodayPills()
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "시간 정보 없음" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm" // "오전 8:00" 형태
        return formatter.string(from: date)
    }
}


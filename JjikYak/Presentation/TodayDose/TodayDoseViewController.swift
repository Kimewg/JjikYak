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
    private var isEditingMode = BehaviorRelay<Bool>(value: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle(main: "찍약", sub: "알약 검색 및 복약 관리", showBackButton: false)
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
    
    private let editButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: imageConfig), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    private func configureUI() {
        view.addSubview(toDayLabel)
        view.addSubview(dosePill)
        view.addSubview(editButton)
        view.addSubview(dosePillTableView)
        
        toDayLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        dosePill.snp.makeConstraints {
            $0.top.equalTo(toDayLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }
        
        editButton.snp.makeConstraints {
            $0.centerY.equalTo(dosePill)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
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
        // 편집 버튼(연필) 클릭 이벤트
        editButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                // 편집 모드 상태 토글 (true <-> false)
                let currentMode = self.isEditingMode.value
                self.isEditingMode.accept(!currentMode)
                
                // 데이터 소스를 다시 방출해서 테이블뷰가 셀들을 다시 그리게 만듦
                self.doses.accept(self.doses.value)
            })
            .disposed(by: disposeBag)
        
        // 테이블뷰 데이터 바인딩
        doses
            .bind(to: dosePillTableView.rx.items(
                cellIdentifier: TodayDoseCell.identifier,
                cellType: TodayDoseCell.self)
            ) { [weak self] (row, pill, cell) in
                
                guard let self = self else { return }
                let timeString = self.formatDate(pill.alarmTime)
                
                // 셀 구성 시 편집 모드(isEditingMode) 상태 전달
                cell.configure(
                    pillName: pill.title ?? "약 이름 없음",
                    time: timeString,
                    isTaken: pill.isTaken,
                    isEditing: self.isEditingMode.value // 추가됨!
                )
                
                // 체크 버튼 클릭 (복약 상태 변경)
                cell.checkButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.togglePillStatus(pill: pill)
                    })
                    .disposed(by: cell.disposeBag)
                
                // 휴지통 버튼 클릭 (약 삭제)
                cell.deleteButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.deletePill(pill)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    // 약 삭제 함수
    private func deletePill(_ pill: Pill) {
        CoreDataManager.shared.deletePill(pill)
        fetchTodayPills()
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


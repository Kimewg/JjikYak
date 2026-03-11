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
import UserNotifications

class TodayDoseViewController: UIViewController, UITableViewDelegate {
    
    private var doses = BehaviorRelay<[Pill]>(value: [])
    private let disposeBag = DisposeBag()
    private var isEditingMode = BehaviorRelay<Bool>(value: false)
    
    private let customNavBar = CustomNavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        customNavBar.configure(
            title: "찍약",
            subTitle: "알약 검색 및 복약 관리",
            showBackButton: false,
            showBellButton: true
        )
        
        configureUI()
        configureTableView()
        bind()
        checkAndUpdateBellState()
        CoreDataManager.shared.addTestPillForOneMinuteLater()
        
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .subscribe(onNext: { [weak self] _ in
                self?.checkAndUpdateBellState()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        fetchTodayPills()
    }
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 복용할 약이 없습니다. \n새로운 약을 등록해보세요!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.isHidden = true
        return label
    }()
    
    private let toDayLabel: UILabel = {
        let label = UILabel()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        
        label.text = formatter.string(from: Date())
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dosePill: UILabel = {
        let label = UILabel()
        label.text = "오늘 먹을 약"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let dosePillTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: imageConfig), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    
    private func configureUI() {
        view.addSubview(customNavBar)
        view.addSubview(toDayLabel)
        view.addSubview(dosePill)
        view.addSubview(editButton)
        view.addSubview(dosePillTableView)
        
        customNavBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
        }
        
        toDayLabel.snp.makeConstraints {
            $0.top.equalTo(customNavBar.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        dosePill.snp.makeConstraints {
            $0.top.equalTo(toDayLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        editButton.snp.makeConstraints {
            $0.centerY.equalTo(dosePill)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }
        
        dosePillTableView.snp.makeConstraints {
            $0.top.equalTo(dosePill.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    // 알림 상태 확인 및 UI 업데이트
        private func checkAndUpdateBellState() {
            NotificationManager.shared.checkNotificationStatus { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .authorized:
                    // 권한 허용 상태: 유저의 UserDefaults 설정값을 따름
                    let isEnabled = UserDefaults.standard.isNotificationEnabled
                    self.updateBellIcon(isEnabled: isEnabled)
                    
                    if isEnabled {
                        NotificationManager.shared.scheduleNotifications(for: self.doses.value)
                    }
                    
                case .denied:
                    // 권한 거부 상태
                    // 유저가 설정 앱에 갔다가 알림을 안 켜고 그냥 돌아왔을 때를 대비해,
                    // 내부 설정값(UserDefaults)도 다시 강제로 꺼버립니다.
                    UserDefaults.standard.isNotificationEnabled = false
                    self.updateBellIcon(isEnabled: false)
                    
                case .notDetermined:
                    // 최초 실행 시
                    NotificationManager.shared.requestPermission { granted in
                        if granted {
                            UserDefaults.standard.isNotificationEnabled = true
                            self.updateBellIcon(isEnabled: true)
                            NotificationManager.shared.scheduleNotifications(for: self.doses.value)
                        } else {
                            UserDefaults.standard.isNotificationEnabled = false
                            self.updateBellIcon(isEnabled: false)
                        }
                    }
                    
                default:
                    break
                }
            }
        }
    // 종아이콘 활성화/비활성화 UI
    private func updateBellIcon(isEnabled: Bool) {
        let imageName = isEnabled ? "bell.fill" : "bell.slash"
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        
        customNavBar.bellButton.setImage(UIImage(systemName: imageName, withConfiguration: imageConfig), for: .normal)
        customNavBar.bellButton.tintColor = isEnabled ? .systemYellow : .darkGray
    }
    // 권한 거부 시 설정 앱 이동 알림
    private func showSettingsAlert() {
        let alert = UIAlertController(
            title: "알림 권한 필요",
            message: "약 복용 시간을 안내받으려면 기기 설정에서 알림 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        
        self.present(alert, animated: true)
    }
    
    private func configureTableView() {
        dosePillTableView.delegate = self
        
        dosePillTableView.register(
            TodayDoseCell.self,
            forCellReuseIdentifier: TodayDoseCell.identifier
        )
        
        dosePillTableView.backgroundView = emptyStateLabel
    }
    
    private func fetchTodayPills() {
        let fetchedPills = CoreDataManager.shared.fetchPills(on: Date())
        doses.accept(fetchedPills)
        
        if UserDefaults.standard.isNotificationEnabled {
            NotificationManager.shared.scheduleNotifications(for: fetchedPills)
        }
    }
    
    private func bind() {
        // 편집 버튼 클릭 이벤트
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
        
        // 커스텀 헤더의 종 버튼(알림) 클릭 이벤트
        customNavBar.bellButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                NotificationManager.shared.checkNotificationStatus { status in
                    switch status {
                    case .authorized:
                        // 이미 허용됨 -> 기존처럼 ON/OFF 토글
                        let newState = !UserDefaults.standard.isNotificationEnabled
                        UserDefaults.standard.isNotificationEnabled = newState
                        self.updateBellIcon(isEnabled: newState)
                        
                        if newState {
                            NotificationManager.shared.scheduleNotifications(for: self.doses.value)
                        } else {
                            NotificationManager.shared.removeAllNotifications()
                        }
                        
                    case .denied:
                        // 거부됨 -> 설정 창으로 유도
                        UserDefaults.standard.isNotificationEnabled = true
                        self.showSettingsAlert()
                        
                    case .notDetermined:
                        // 아직 안 물어봄 -> 권한 요청
                        NotificationManager.shared.requestPermission { granted in
                            if granted {
                                UserDefaults.standard.isNotificationEnabled = true
                                self.updateBellIcon(isEnabled: true)
                                NotificationManager.shared.scheduleNotifications(for: self.doses.value)
                            } else {
                                self.updateBellIcon(isEnabled: false)
                                UserDefaults.standard.isNotificationEnabled = false
                            }
                        }
                        
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 테이블뷰 데이터 바인딩
        doses
            .map { !$0.isEmpty }
            .bind(to: emptyStateLabel.rx.isHidden) // 데이터 있으면 라벨 숨김(hidden = true)
            .disposed(by: disposeBag)
        
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
                    isEditing: self.isEditingMode.value
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


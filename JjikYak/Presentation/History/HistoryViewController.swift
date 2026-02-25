import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa

class HistoryViewController: UIViewController {
    
    let selectedDate = BehaviorRelay<Date?>(value: Date())
    let disposeBag = DisposeBag()
    var calendarDays: [Date?] = []
    var monthlyPillStatus: [String: DailyPillStatus] = [:]
    let currentMonth = BehaviorRelay<Date>(value: Date())
    let selectedDatePills = BehaviorRelay<[Pill]>(value: [])
    var calendarHeightConstraint: Constraint?
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    private let prevButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(weight: .bold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(weight: .bold)
        button.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let weekdayStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        for (index, day) in weekdays.enumerated() {
            let label = UILabel()
            label.text = day
            label.font = .systemFont(ofSize: 14, weight: .bold)
            label.textAlignment = .center
            label.textColor = index == 0 ? .systemRed : (index == 6 ? .systemBlue : .systemGray)
            stack.addArrangedSubview(label)
        }
        return stack
    }()
    
    lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.identifier)
        return cv
    }()
    
    // 화면에 약 목록과 범례가 다 안 들어갈 때를 대비한 스크롤 뷰
    private let bottomScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    // 일정 카드와 범례 카드를 담아 위아래 간격을 자동으로 조절해주는 스택 뷰
    private let bottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 30, right: 16)
        return stack
    }()
    
    // 일정 정보 카드 (파란 박스)
    private let bottomInfoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        return view
    }()
    
    private let infoDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .systemBlue
        return label
    }()
    
    // 셀 높이에 따라 뷰 길이가 늘어나는 커스텀 테이블 뷰 사용
    private let pillTableView: SelfSizingTableView = {
        let tv = SelfSizingTableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.isScrollEnabled = false // 바깥 스크롤 뷰가 있으므로 내부 스크롤은 막음
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 60
        tv.register(HistoryPillCell.self, forCellReuseIdentifier: HistoryPillCell.identifier)
        return tv
    }()
    
    // 범례 카드 (회색 박스)
    private let legendContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let legendTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "범례"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    // 범례의 동그라미 아이콘을 생성하는 헬퍼 함수
    private func createLegendItem(color: UIColor, text: String) -> UIStackView {
        let circle = UIView()
        circle.layer.cornerRadius = 12
        circle.layer.borderWidth = 1.5
        circle.layer.borderColor = color.cgColor
        circle.backgroundColor = color.withAlphaComponent(0.1)
        circle.snp.makeConstraints { $0.width.height.equalTo(24) }
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        
        let stack = UIStackView(arrangedSubviews: [circle, label])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setNavigationTitle(main: "복약 히스토리", sub: "복용 기록과 예정을 확인하세요")
        
        configureUI()
        bind()
        currentMonth.accept(Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMonthlyPillStatus()
        
        if let currentSelected = selectedDate.value {
            updateBottomView(for: currentSelected)
        }
    }
    
    private func loadMonthlyPillStatus() {
        monthlyPillStatus.removeAll()
        
        for case let date? in calendarDays {
            let pills = CoreDataManager.shared.fetchPills(on: date)
            let key = dateFormatter.string(from: date)
            
            if pills.isEmpty {
                monthlyPillStatus[key] = Optional.none
            } else {
                let takenCount = pills.filter { $0.isTaken }.count
                
                if takenCount == pills.count {
                    monthlyPillStatus[key] = .completed
                } else if takenCount == 0 {
                    monthlyPillStatus[key] = .planned
                } else {
                    monthlyPillStatus[key] = .incomplete
                }
            }
        }
        calendarCollectionView.reloadData()
        
        // 달력의 주(4,5,6주)에 맞춰 높이를 조절
        let rowCount = CGFloat(calendarDays.count / 7)
        if rowCount > 0 {
            let dynamicHeight = (rowCount * 50) + ((rowCount - 1) * 10)
            calendarHeightConstraint?.update(offset: dynamicHeight)
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func updateCalendar(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        monthLabel.text = formatter.string(from: date)
        
        calendarDays = CalendarManager.shared.generateDaysInMonth(for: date)
        loadMonthlyPillStatus()
    }
    
    private func changeMonth(by value: Int) {
        let current = currentMonth.value
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: current) {
            currentMonth.accept(newMonth)
            selectedDate.accept(nil)
        }
    }
    
    private func configureUI() {
        // 상단 달력 뷰 추가
        view.addSubview(prevButton)
        view.addSubview(nextButton)
        view.addSubview(monthLabel)
        view.addSubview(weekdayStackView)
        view.addSubview(calendarCollectionView)
        
        // 하단 스크롤 및 스택뷰 추가
        view.addSubview(bottomScrollView)
        bottomScrollView.addSubview(bottomStackView)
        
        // 스택뷰 안에 일정 박스와 범례 박스를 순서대로 삽입
        bottomStackView.addArrangedSubview(bottomInfoContainer)
        bottomStackView.addArrangedSubview(legendContainerView)
        
        // 일정 박스 안쪽 조립
        bottomInfoContainer.addSubview(infoDateLabel)
        bottomInfoContainer.addSubview(pillTableView)
        
        // 범례 박스 안쪽 조립
        legendContainerView.addSubview(legendTitleLabel)
        let completedItem = createLegendItem(color: .systemGreen, text: "복용 완료")
        let incompleteItem = createLegendItem(color: .systemOrange, text: "복용 미완료")
        let plannedItem = createLegendItem(color: .systemBlue, text: "복용 예정")
        
        let legendItemsStackView = UIStackView(arrangedSubviews: [completedItem, incompleteItem, plannedItem])
        legendItemsStackView.axis = .vertical
        legendItemsStackView.spacing = 16
        legendItemsStackView.alignment = .leading
        legendContainerView.addSubview(legendItemsStackView)
        
        monthLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        prevButton.snp.makeConstraints {
            $0.centerY.equalTo(monthLabel)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(30)
        }
        
        nextButton.snp.makeConstraints {
            $0.centerY.equalTo(monthLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }
        
        weekdayStackView.snp.makeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(20)
        }
        
        calendarCollectionView.snp.makeConstraints {
            $0.top.equalTo(weekdayStackView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            self.calendarHeightConstraint = $0.height.equalTo(320).constraint
        }
        
        bottomScrollView.snp.makeConstraints {
            $0.top.equalTo(calendarCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        infoDateLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
        }
        
        pillTableView.snp.makeConstraints {
            $0.top.equalTo(infoDateLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        legendTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
        }
        
        legendItemsStackView.snp.makeConstraints {
            $0.top.equalTo(legendTitleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func bind() {
        prevButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.changeMonth(by: -1)
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.changeMonth(by: 1)
            })
            .disposed(by: disposeBag)
        
        currentMonth
            .subscribe(onNext: { [weak self] date in
                self?.updateCalendar(for: date)
            })
            .disposed(by: disposeBag)
        
        calendarCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self,
                      let date = self.calendarDays[indexPath.row] else { return }
                
                self.selectedDate.accept(date)
                self.calendarCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        selectedDate
            .subscribe(onNext: { [weak self] date in
                if let date = date {
                    self?.updateBottomView(for: date)
                } else {
                    self?.bottomInfoContainer.isHidden = true
                    self?.selectedDatePills.accept([])
                }
            })
            .disposed(by: disposeBag)
        
        selectedDatePills
            .bind(to: pillTableView.rx.items(
                cellIdentifier: HistoryPillCell.identifier,
                cellType: HistoryPillCell.self
            )) { row, pill, cell in
                cell.configure(with: pill.title ?? "이름 없는 약", isTaken: pill.isTaken)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateBottomView(for date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let pills = CoreDataManager.shared.fetchPills(on: date)
        selectedDatePills.accept(pills)
        
        // 일정이 없으면 파란색 박스를 숨김 (범례 박스는 위로 자동으로 올라옴)
        if pills.isEmpty {
            bottomInfoContainer.isHidden = true
        } else {
            bottomInfoContainer.isHidden = false
            
            let takenCount = pills.filter { $0.isTaken }.count
            
            if takenCount == pills.count {
                // 1. 모두 다 먹었을 때 (전체 개수 == 먹은 개수)
                bottomInfoContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                infoDateLabel.text = "\(dateString) 복용 완료"
                infoDateLabel.textColor = .systemGreen
            } else if takenCount == 0 {
                // 2. 하나도 안 먹었을 때 (먹은 개수 == 0)
                bottomInfoContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                infoDateLabel.text = "\(dateString) 복용 예정"
                infoDateLabel.textColor = .systemBlue
            } else {
                // 3. 일부만 먹었을 때 (먹긴 먹었는데 전부 다 먹은 건 아님)
                bottomInfoContainer.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
                infoDateLabel.text = "\(dateString) 복용 중"
                infoDateLabel.textColor = .systemOrange
            }
        }
    }
}

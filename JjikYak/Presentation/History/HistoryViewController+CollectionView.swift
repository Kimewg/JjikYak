//
//  HistoryViewController+CollectionView.swift
//  JjikYak
//
//  Created by 김은서 on 2/24/26.
//
import UIKit

// UICollectionView 설정 (달력)
extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.identifier, for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }
        
        if let date = calendarDays[indexPath.row] {
            let isSelected = isSameDay(date1: date, date2: selectedDate.value)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let key = formatter.string(from: date)
            
            let status = monthlyPillStatus[key] ?? .none
            
            cell.configure(date: date, status: status, isSelected: isSelected)
        } else {
            cell.configure(date: nil, status: .none, isSelected: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.width - 32) / 7
        return CGSize(width: width, height: 50)
    }
    
    private func isSameDay(date1: Date?, date2: Date?) -> Bool {
        guard let d1 = date1, let d2 = date2 else { return false }
        return Calendar.current.isDate(d1, inSameDayAs: d2)
    }
}

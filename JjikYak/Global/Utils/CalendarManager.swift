//
//  CalendarManager.swift
//  JjikYak
//
//  Created by 김은서 on 2/24/26.
//

import Foundation

final class CalendarManager {
    static let shared = CalendarManager()
    
    private let calendar = Calendar.current
    
    private init() {}
    
    // 특정 날짜가 속한 달의 날짜 배열을 생성합니다.
    func generateDaysInMonth(for date: Date) -> [Date?] {
        // 1. 이번 달의 1일 날짜 구하기 (예: 2026-02-01)
        guard let month1st = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        
        // 2. 1일의 요일 구하기 (1: 일요일, 2: 월요일 ... 7: 토요일)
        let firstWeekday = calendar.component(.weekday, from: month1st)
        
        // 3. 이번 달의 총 일수 구하기 (예: 2월이면 28일, 3월이면 31일)
        guard let range = calendar.range(of: .day, in: .month, for: month1st) else {
            return []
        }
        let numberOfDaysInMonth = range.count
        
        // 4. 콜렉션 뷰에 뿌려줄 배열 조립 시작
        var days: [Date?] = []
        
        // 1일 이전의 빈 칸을 nil로 채우기 (달력 첫 줄 여백)
        let emptySpaces = firstWeekday - 1
        for _ in 0..<emptySpaces {
            days.append(nil)
        }
        
        // 실제 날짜 채우기 (1일부터 마지막 날까지)
        for day in 1...numberOfDaysInMonth {
            if let calculatedDate = calendar.date(byAdding: .day, value: day - 1, to: month1st) {
                days.append(calculatedDate)
            }
        }
        
        // 5. 달력 마지막 줄의 남은 빈 칸을 nil로 채우기 (그리드 모양 유지를 위해)
        let remainingSpaces = 7 - (days.count % 7)
        if remainingSpaces < 7 { // 딱 떨어지지 않고 남은 칸이 있다면
            for _ in 0..<remainingSpaces {
                days.append(nil)
            }
        }
        
        return days
    }
}

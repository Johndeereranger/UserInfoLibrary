//
//  MarketingDashboardViewModel.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/26/25.
//

import SwiftUI
import FirebaseFirestore

@MainActor
public class MarketingDashboardViewModel: ObservableObject {
    @Published public var userInfos: [UserInfo] = []
    @Published public var selectedFilter: DateRangeFilter = .last30Days
    @Published public var metrics: DashboardMetrics = DashboardMetrics()

    public init() {
        fetchUsers()
    }

    public func fetchUsers() {
        Task {
            do {
                let users = try await UserInfoManager.shared.fetchAllUsers()
                self.userInfos = users
                computeMetrics()
            } catch {
                print("Failed to fetch users: \(error)")
            }
        }
    }

    public func computeMetrics() {
        let filteredUsers = filterUsersByDateRange(users: userInfos, filter: selectedFilter)

        metrics.newSignups = filteredUsers.count
        metrics.userGrowthRate = calculateUserGrowthRate(users: userInfos, filter: selectedFilter)
        metrics.averageAccessFrequency = calculateAverageAccessFrequency(users: filteredUsers)
        metrics.userRetentionRate = calculateRetentionRate(users: filteredUsers)
    }

    private func filterUsersByDateRange(users: [UserInfo], filter: DateRangeFilter) -> [UserInfo] {
        let now = Date()
        let calendar = Calendar.current
        print("Current Date, \(now)")
        switch filter {
        case .last7Days:
            let cutoffDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return users.filter { user in
                guard let signUpDate = user.signUpDate?.toDate() else {
                    //print("Failed to convert signUpDate to Date")
                    return false }
                let isIncluded = signUpDate >= cutoffDate
                //print("Signup date: \(signUpDate), isIncluded: \(isIncluded)")
                return isIncluded
            
            }

        case .last30Days:
            let cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            return users.filter { user in
                guard let signUpDate = user.signUpDate?.toDate() else { return false }
                return signUpDate >= cutoffDate
            }


        case .yearOverYear:
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let lastYearSameMonthStart = calendar.date(byAdding: .year, value: -1, to: thisMonthStart) ?? oneYearAgo
            let lastYearNextMonthStart = calendar.date(byAdding: .month, value: 1, to: lastYearSameMonthStart) ?? now

            let thisYearUsers = users.filter { user in
                guard let signUpDate = user.signUpDate?.toDate() else { return false }
                return signUpDate >= thisMonthStart && signUpDate < calendar.date(byAdding: .month, value: 1, to: thisMonthStart) ?? now
            }
            
            let lastYearUsers = users.filter { user in
                guard let signUpDate = user.signUpDate?.toDate() else { return false }
                return signUpDate >= lastYearSameMonthStart && signUpDate < lastYearNextMonthStart
            }

            print("Users this year: \(thisYearUsers.count), Users last year: \(lastYearUsers.count)")

            // Returning both current and previous year’s users for comparison
            return thisYearUsers + lastYearUsers


        case .custom(let startDate, let endDate):
            return users.filter { user in
                guard let signUpDate = user.signUpDate?.toDate() else { return false }
                return signUpDate >= startDate && signUpDate <= endDate
            }
        }

        return []
    }


    private func calculateUserGrowthRate(users: [UserInfo], filter: DateRangeFilter) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let (currentRangeStart, previousRangeStart) = getDateRangeForComparison(filter: filter, now: now, calendar: calendar)
        
        let currentPeriodUsers = users.filter { user in
            guard let date = user.signUpDate?.toDate() else { return false }
            return date >= currentRangeStart
        }
        
        let previousPeriodUsers = users.filter { user in
            guard let date = user.signUpDate?.toDate() else { return false }
            return date >= previousRangeStart && date < currentRangeStart
        }

        let previousCount = Double(previousPeriodUsers.count)
        let currentCount = Double(currentPeriodUsers.count)

        if previousCount == 0 {
            return currentCount > 0 ? 100.0 : 0.0
        }

        return ((currentCount - previousCount) / previousCount) * 100
    }

    private func getDateRangeForComparison(filter: DateRangeFilter, now: Date, calendar: Calendar) -> (Date, Date) {
        switch filter {
        case .last7Days:
            let currentStart = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            let previousStart = calendar.date(byAdding: .day, value: -14, to: now) ?? now
            return (currentStart, previousStart)

        case .last30Days:
            let currentStart = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            let previousStart = calendar.date(byAdding: .day, value: -60, to: now) ?? now
            return (currentStart, previousStart)

        case .yearOverYear:
            let currentStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let previousStart = calendar.date(byAdding: .year, value: -1, to: currentStart) ?? now
            return (currentStart, previousStart)

    
        case .custom(let startDate, let endDate):
            let daysBetween = Int(endDate.timeIntervalSince(startDate) / 86400) // Convert Double to Int
            let previousStart = calendar.date(byAdding: .day, value: -daysBetween, to: startDate) ?? startDate
            return (startDate, previousStart)

        }
    }



    private func calculateAverageAccessFrequency(users: [UserInfo]) -> Double {
        let accessCounts = users.compactMap { $0.accessDates?.count }
        guard !accessCounts.isEmpty else { return 0 }
        return Double(accessCounts.reduce(0, +)) / Double(accessCounts.count)
    }

    private func calculateRetentionRate(users: [UserInfo]) -> Double {
        if users.isEmpty { return 0 }

        let retainedUsers = users.filter { $0.accessDates?.count ?? 0 > 1 }
        return (Double(retainedUsers.count) / Double(users.count)) * 100
    }
    
    public func getMetricData(for metric: MetricType) -> [Date: Int] {
        let calendar = Calendar.current
        var metricData: [Date: Int] = [:]

        for user in userInfos {
            guard let date = user.signUpDate?.toDate() else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            metricData[startOfDay, default: 0] += 1
        }

        return metricData
    }
    
    public func getMetricValue(for metric: MetricType) -> String {
        switch metric {
        case .newSignups: return "\(metrics.newSignups)"
        case .retentionRate: return "\(String(format: "%.1f", metrics.userRetentionRate))%"
        case .accessFrequency: return "\(String(format: "%.2f", metrics.averageAccessFrequency))"
        case .growthRate: return "\(String(format: "%.1f", metrics.userGrowthRate))%"
        }
    }

}

public enum MetricType: CaseIterable {
    case newSignups, retentionRate, accessFrequency, growthRate

    var title: String {
        switch self {
        case .newSignups: return "New Signups"
        case .retentionRate: return "Retention Rate"
        case .accessFrequency: return "Avg Access Frequency"
        case .growthRate: return "User Growth Rate"
        }
    }
}

public enum DateRangeFilter: Hashable, Equatable {
    case last7Days
    case last30Days
    case yearOverYear
    case custom(startDate: Date, endDate: Date)

    public static func == (lhs: DateRangeFilter, rhs: DateRangeFilter) -> Bool {
        switch (lhs, rhs) {
        case (.last7Days, .last7Days), (.last30Days, .last30Days), (.yearOverYear, .yearOverYear):
            return true
        case let (.custom(startL, endL), .custom(startR, endR)):
            return startL == startR && endL == endR
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .last7Days:
            hasher.combine("last7Days")
        case .last30Days:
            hasher.combine("last30Days")
        case .yearOverYear:
            hasher.combine("yearOverYear")
        case .custom(let startDate, let endDate):
            hasher.combine(startDate)
            hasher.combine(endDate)
        }
    }
}


public struct DashboardMetrics {
    public var newSignups: Int = 0
    public var userGrowthRate: Double = 0
    public var averageAccessFrequency: Double = 0
    public var userRetentionRate: Double = 0

    public init() {}
}

public extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"  // ✅ Matches "2025-01-11"
        formatter.timeZone = TimeZone(identifier: "UTC") // ✅ Ensures consistent date parsing
        return formatter.date(from: self)
    }
}


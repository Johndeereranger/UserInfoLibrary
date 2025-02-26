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
        metrics.userGrowthRate = calculateUserGrowthRate(users: userInfos)
        metrics.averageAccessFrequency = calculateAverageAccessFrequency(users: filteredUsers)
        metrics.userRetentionRate = calculateRetentionRate(users: filteredUsers)
    }

    private func filterUsersByDateRange(users: [UserInfo], filter: DateRangeFilter) -> [UserInfo] {
        let now = Date()
        let calendar = Calendar.current
        let cutoffDate: Date

        switch filter {
        case .last7Days:
            cutoffDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .last30Days:
            cutoffDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .yearOverYear:
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            let thisYearUsers = users.filter { user in
                guard let signUpDate = user.signUpDate?.toDate() else { return false }
                return calendar.isDate(signUpDate, equalTo: now, toGranularity: .month)
            }
            let lastYearUsers = users.filter { user in
                guard let signUpDate = user.signUpDate?.toDate() else { return false }
                return calendar.isDate(signUpDate, equalTo: oneYearAgo, toGranularity: .month)
            }

            print("Users this year: \(thisYearUsers.count), Users last year: \(lastYearUsers.count)")

            return thisYearUsers
        case .custom(let startDate, let endDate):
            return users.filter { user in
                guard let signUpDate = user.signUpDate?.toDate() else { return false }
                return signUpDate >= startDate && signUpDate <= endDate
            }
        }

        return users.filter { user in
            guard let signUpDate = user.signUpDate?.toDate() else { return false }
            return signUpDate >= cutoffDate
        }
    }

    private func calculateUserGrowthRate(users: [UserInfo]) -> Double {
        let calendar = Calendar.current
        let currentMonthUsers = users.filter { user in
            guard let date = user.signUpDate?.toDate() else { return false }
            return calendar.isDate(date, equalTo: Date(), toGranularity: .month)
        }
        let previousMonthUsers = users.filter { user in
            guard let date = user.signUpDate?.toDate() else { return false }
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return calendar.isDate(date, equalTo: lastMonth, toGranularity: .month)
        }

        let previousCount = Double(previousMonthUsers.count)
        let currentCount = Double(currentMonthUsers.count)

        if previousCount == 0 { return 0 }
        return ((currentCount - previousCount) / previousCount) * 100
    }

    private func calculateAverageAccessFrequency(users: [UserInfo]) -> Double {
        let accessCounts = users.compactMap { $0.accessDates?.count }
        guard !accessCounts.isEmpty else { return 0 }
        return Double(accessCounts.reduce(0, +)) / Double(accessCounts.count)
    }

    private func calculateRetentionRate(users: [UserInfo]) -> Double {
        let retainedUsers = users.filter { $0.accessDates?.count ?? 0 > 1 }
        return Double(retainedUsers.count) / Double(users.count) * 100
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
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self)
    }
}

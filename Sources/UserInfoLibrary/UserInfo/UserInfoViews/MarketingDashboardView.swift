//
//  MarketingDashboardView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/26/25.
//

import SwiftUI

public struct MarketingDashboardView: View {
    @StateObject private var viewModel = MarketingDashboardViewModel()

    public init() {}

    public var body: some View {
        NavigationView {
            VStack {
                Picker("Select Time Frame", selection: $viewModel.selectedFilter) {
                    Text("Last 7 Days").tag(DateRangeFilter.last7Days)
                    Text("Last 30 Days").tag(DateRangeFilter.last30Days)
                    Text("Year-over-Year").tag(DateRangeFilter.yearOverYear)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                MetricsGridView(metrics: viewModel.metrics)
                
                Spacer()
            }
            .navigationTitle("Marketing Dashboard")
            .onChange(of: viewModel.selectedFilter) { _ in
                viewModel.computeMetrics()
            }
        }
    }
}

public struct MetricsGridView: View {
    public let metrics: DashboardMetrics

    public init(metrics: DashboardMetrics) {
        self.metrics = metrics
    }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            MetricCard(title: "New Signups", value: "\(metrics.newSignups)")
            MetricCard(title: "Retention Rate", value: "\(String(format: "%.1f", metrics.userRetentionRate))%")
            MetricCard(title: "Avg Access", value: "\(String(format: "%.2f", metrics.averageAccessFrequency))")
            MetricCard(title: "User Growth", value: "\(String(format: "%.1f", metrics.userGrowthRate))%")
        }
        .padding()
    }
}

public struct MetricCard: View {
    public let title: String
    public let value: String

    public init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    public var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.blue)
        }
        .frame(width: 150, height: 100)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 3))
    }
}

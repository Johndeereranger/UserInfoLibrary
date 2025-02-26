//
//  MarketingDashboardView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/26/25.
//

import SwiftUI

public struct MarketingDashboardView: View {
    @StateObject private var viewModel = MarketingDashboardViewModel()
    @State private var selectedMetric: MetricType?
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
                
                MetricsGridView(metrics: viewModel.metrics) { metric in
                    selectedMetric = metric
                }
                
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
    public var onSelect: (MetricType) -> Void

    public init(metrics: DashboardMetrics, onSelect: @escaping (MetricType) -> Void) {
        self.metrics = metrics
        self.onSelect = onSelect
    }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(MetricType.allCases, id: \.self) { metric in
                Button(action: { onSelect(metric) }) {
                    MetricCard(title: metric.title, value: getMetricValue(for: metric))
                }
            }
        }
        .padding()
    }

    private func getMetricValue(for metric: MetricType) -> String {
        switch metric {
        case .newSignups: return "\(metrics.newSignups)"
        case .retentionRate: return "\(String(format: "%.1f", metrics.userRetentionRate))%"
        case .accessFrequency: return "\(String(format: "%.2f", metrics.averageAccessFrequency))"
        case .growthRate: return "\(String(format: "%.1f", metrics.userGrowthRate))%"
        }
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

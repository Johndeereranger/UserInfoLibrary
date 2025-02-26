//
//  MetricDetailView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/26/25.
//

import SwiftUI
import Charts

import SwiftUI
import Charts
import SwiftUI
import Charts

public struct MetricDetailView: View {
    public let metric: MetricType
    @ObservedObject var viewModel: MarketingDashboardViewModel

    public var body: some View {
        VStack {
            // Title & Summary
            Text(metric.title).font(.largeTitle).bold()
            Text(viewModel.getMetricValue(for: metric)).font(.title2)

            let metricData = viewModel.getMetricData(for: metric)
            let sortedData = metricData.sorted { $0.key < $1.key }
            let movingAvgData = calculateMovingAverage(sortedData, period: 7)

            if #available(iOS 16.0, *) {
                Chart {
                    // Raw Data Line (Daily Values)
                    ForEach(sortedData, id: \.key) { entry in
                        LineMark(
                            x: .value("Date", entry.key),
                            y: .value("Signups", entry.value)
                        )
                        .foregroundStyle(.blue)
                    }

                    let sortedMovingAvgData = movingAvgData.sorted { $0.key < $1.key }

                    ForEach(sortedMovingAvgData, id: \.key) { entry in
                        LineMark(
                            x: .value("Date", entry.key),
                            y: .value("7-Day Avg", entry.value)
                        )
                        .foregroundStyle(.red)
                    }

                }
                .chartXAxis {
                    AxisMarks(position: .bottom, values: .automatic) { value in
                        if let dateValue = value.as(Date.self) {
                            AxisValueLabel(dateValue.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                }
                .frame(height: 250)
            } else {
                Text("Charts require iOS 16+")
            }

            // Raw Data Table
            List(sortedData, id: \.key) { entry in
                let movingAvg = movingAvgData[entry.key] ?? 0
                HStack {
                    Text(entry.key.formatted(date: .abbreviated, time: .omitted))
                    Spacer()
                    Text("\(entry.value)")
                    Spacer()
                    Text("\(movingAvg)") // Show moving average
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
    }
    
    private func calculateMovingAverage(_ data: [(key: Date, value: Int)], period: Int) -> [Date: Double] {
        var movingAverages: [Date: Double] = [:]
        let sortedDates = data.map { $0.key }

        for (index, currentDate) in sortedDates.enumerated() {
            let startIndex = max(0, index - (period - 1)) // Look back 7 days
            let subset = data[startIndex...index].map { $0.value }
            let avg = Double(subset.reduce(0, +)) / Double(subset.count)
            movingAverages[currentDate] = avg
        }

        return movingAverages
    }

}

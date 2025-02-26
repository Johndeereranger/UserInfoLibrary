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

public struct MetricDetailView: View {
    public let metric: MetricType
    @ObservedObject var viewModel: MarketingDashboardViewModel

    public var body: some View {
        VStack {
            Text(metric.title).font(.largeTitle).bold()
            Text(viewModel.getMetricValue(for: metric)).font(.title2)

            if #available(iOS 16.0, *) {
                let sortedData = viewModel.getMetricData(for: metric).sorted { $0.key < $1.key } // Sort by date

                Chart {
                    ForEach(sortedData, id: \.key) { entry in
                        LineMark(
                            x: .value("Date", entry.key),
                            y: .value("Value", entry.value)
                        )
                    }
                }
                .frame(height: 250)
            } else {
                Text("Charts require iOS 16+")
            }


            List(viewModel.getMetricData(for: metric).keys.sorted(), id: \.self) { date in
                HStack {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                    Spacer()
                    Text("\(viewModel.getMetricData(for: metric)[date] ?? 0)")
                }
            }
        }
        .padding()
    }
}

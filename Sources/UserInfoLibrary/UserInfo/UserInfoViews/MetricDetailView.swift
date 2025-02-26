//
//  MetricDetailView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/26/25.
//

import SwiftUI
import Charts

public struct MetricDetailView: View {
    public let metricTitle: String
    public let metricData: [Date: Int] // Date-based trend data
    public let metricValue: String // Summary value (e.g., "15%" growth)
    
    public init(metricTitle: String, metricData: [Date: Int], metricValue: String) {
        self.metricTitle = metricTitle
        self.metricData = metricData
        self.metricValue = metricValue
    }

    public var body: some View {
        VStack {
            Text(metricTitle)
                .font(.largeTitle)
                .bold()

            Text("Current Value: \(metricValue)")
                .font(.headline)
                .padding(.bottom, 10)

            // Line Chart
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(metricData.keys.sorted(), id: \.self) { date in
                        if let value = metricData[date] {
                            LineMark(
                                x: .value("Date", date),
                                y: .value("Value", value)
                            )
                        }
                    }
                }
                .frame(height: 250)
                .padding()
            } else {
                Text("Charts require iOS 16.0 or later.")
            }
            
            // Raw Data List
            List {
                ForEach(metricData.keys.sorted(), id: \.self) { date in
                    if let value = metricData[date] {
                        HStack {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            Text("\(value)")
                        }
                    }
                }
            }
        }
        .padding()
    }
}

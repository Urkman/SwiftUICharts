//
//  BarChartView.swift
//  SleepBot
//
//  Created by Majid Jabrayilov on 6/21/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import SwiftUI

/// Type that defines a bar chart style.
public struct BarChartStyle: ChartStyle {
    
    public enum AxisPosition {
        case leading
        case trailing
        case hidden
    }

    public var showAxis: Bool = true
    public let barMinHeight: CGFloat
    public let axisPosition: AxisPosition
    public let axisPadding: CGFloat
    public let showGrid: Bool
    public let gridColor: Color
    public let showLabels: Bool
    public let labelFont: Font
    public let labelColor: Color
    public let labelCount: Int?
    public let showLegends: Bool
    public let barsCornerRadius: CGFloat
    public let barsCorners: UIRectCorner

    /**
     Creates new bar chart style with the following parameters.

     - Parameters:
        - barMinHeight: The minimal height for the bar that presents the biggest value. Default is 100.
        - axisPosition: AxisPosition the position on the axis
        - axisPadding: CGFloat padding for axis line. Default is 0.
        - showGrid: Bool show the grid
        - gridColor: Clor the color of the grid
        - showLabels: Bool value that controls whenever to show labels.
        - labelFont: Font The Font of the labels
        - labelColor: Color The Color of the labels
        - labelCount: The count of labels that should be shown below the chart. Default is all.
        - showLegends: Bool value that controls whenever to show legends.
        - barsCornerRadius: CGFloat value that controls corner radius of the bars
        - barsCorners: UIRectCorner value that controls what corners should get a radius
     */
    public init(
        barMinHeight: CGFloat = 100,
        axisPosition: AxisPosition = .trailing,
        axisLeadingPadding: CGFloat = 0,
        showGrid: Bool = true,
        gridColor: Color = .accentColor,
        showLabels: Bool = true,
        labelFont: Font = .caption,
        labelColor: Color = .accentColor,
        labelCount: Int? = nil,
        showLegends: Bool = true,
        barsCornerRadius: CGFloat = 5.0,
        barsCorners: UIRectCorner = []
    ) {
        self.barMinHeight = barMinHeight
        self.axisPosition = axisPosition
        self.axisPadding = axisLeadingPadding
        self.showGrid = showGrid
        self.gridColor = gridColor
        self.showLabels = showLabels
        self.labelFont = labelFont
        self.labelColor = labelColor
        self.labelCount = labelCount
        self.showLegends = showLegends
        self.barsCornerRadius = barsCornerRadius
        self.barsCorners = barsCorners
    }
}

/// SwiftUI view that draws bars by placing them into a horizontal container.
public struct BarChartView: View {
    @Environment(\.chartStyle) var chartStyle

    let dataPoints: [DataPoint]
    let limit: DataPoint?

    /**
     Creates new bar chart view with the following parameters.

     - Parameters:
        - dataPoints: The array of data points that will be used to draw the bar chart.
        - limit: The horizontal line that will be drawn over bars. Default is nil.
     */
    public init(dataPoints: [DataPoint], limit: DataPoint? = nil) {
        self.dataPoints = dataPoints
        self.limit = limit
    }

    private var style: BarChartStyle {
        (chartStyle as? BarChartStyle) ?? .init()
    }

    private var grid: some View {
        ChartGrid()
            .stroke(
                style.showGrid ? style.gridColor : .clear,
                style: StrokeStyle(
                    lineWidth: 1,
                    lineCap: .round,
                    lineJoin: .round,
                    miterLimit: 0,
                    dash: [1, 8],
                    dashPhase: 0
                )
            )
    }

    public var body: some View {
        VStack {
            HStack(spacing: 0) {
                if style.axisPosition == .leading {
                    AxisView(dataPoints: dataPoints, labelColor: style.labelColor, labelFont: style.labelFont)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibilityHidden(true)
                        .padding(.trailing, style.axisPadding)
                }

                VStack {
                    BarsView(dataPoints: dataPoints, limit: limit, showAxis: style.axisPosition != .hidden, barsCornerRadius: style.barsCornerRadius, barsCorners: style.barsCorners)
                        .frame(minHeight: style.barMinHeight)
                        .background(grid)

                    if style.showLabels {
                        LabelsView(
                            dataPoints: dataPoints,
                            labelCount: style.labelCount ?? dataPoints.count,
                            labelFont: style.labelFont,
                            labelColor: style.labelColor
                        ).accessibilityHidden(true)
                    }
                }
                if style.axisPosition == .trailing {
                    AxisView(dataPoints: dataPoints, labelColor: style.labelColor, labelFont: style.labelFont)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibilityHidden(true)
                        .padding(.leading, style.axisPadding)
                }
            }

            if style.showLegends {
                LegendView(dataPoints: limit.map { [$0] + dataPoints} ?? dataPoints)
                    .padding()
                    .accessibilityHidden(true)
            }
        }
    }
}

#if DEBUG
struct BarChartView_Previews : PreviewProvider {
    static var previews: some View {
        let limit = Legend(color: .purple, label: "Trend")
        let limitBar = DataPoint(value: 100, label: "Trend", legend: limit)
        return HStack(spacing: 0) {
            BarChartView(dataPoints: DataPoint.mock, limit: limitBar)
            BarChartView(dataPoints: DataPoint.mock, limit: limitBar)
        }.chartStyle(BarChartStyle(showLabels: false, showLegends: false))
    }
}
#endif

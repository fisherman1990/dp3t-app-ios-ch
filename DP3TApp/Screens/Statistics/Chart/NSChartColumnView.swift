/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSChartColumnView: UIView {

    private let configuration: ChartConfiguration

    init(configuration: ChartConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    var borderColor: UIColor = .white {
        didSet {
            layer.sublayers?.forEach {
                $0.borderColor = borderColor.cgColor
            }
        }
    }

    var values: [Double?] = [] {
        didSet {
            updateChart()
        }
    }

    private var bars: [CALayer] {
        layer.sublayers ?? []
    }

    private func updateChart() {
        guard !values.isEmpty else { return }
        
        func getBar(at index: Int) -> CALayer {
            guard index < bars.count else {
                let layer = newBar()
                self.layer.addSublayer(layer)
                return layer
            }
            return bars[index]
        }

        for (index, value) in values.enumerated() {
            let bar = getBar(at: index)
            let value = value ?? 0
            let endFrame =  CGRect(x: CGFloat(index) * (configuration.barWidth + configuration.barBorderWidth),
                                   y: ceil(frame.height * (1.0 - CGFloat(value))),
                                   width: configuration.barWidth + 2 * configuration.barBorderWidth,
                                   height: ceil(frame.height * CGFloat(value)) + 5) //make sure that the bar always extens to to full height

            let animation = CABasicAnimation(keyPath: "bounds.size.height")
            animation.fromValue = bar.frame.height
            animation.toValue = endFrame.height
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            bar.add(animation, forKey: nil)

            bar.frame = endFrame
        }

        while bars.count > values.count {
            _ = self.layer.sublayers?.popLast()
        }
    }

    func newBar() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = tintColor.cgColor
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = configuration.barBorderWidth
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false {
            layer.sublayers?.forEach({ (layer) in
                layer.borderColor = borderColor.cgColor
                layer.backgroundColor = tintColor.cgColor
            })
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateChart()
    }
}

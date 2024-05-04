import UIKit

class BarSortingView: UIView {
    var bars: [UIView] = []
    let gapWidth: CGFloat = 2.0
    
    func setup(with array: [Int]) {
        let maxValue = array.max() ?? 1
        let totalAvailableWidth = frame.width - CGFloat(array.count - 1) * gapWidth
        let barWidth = totalAvailableWidth / CGFloat(array.count)
        
        bars.forEach { $0.removeFromSuperview() }
        bars.removeAll()
        
        for (index, value) in array.enumerated() {
            let barHeight = CGFloat(value) / CGFloat(maxValue) * frame.height
            let barX = CGFloat(index) * (barWidth + gapWidth)
            let barView = UIView(frame: CGRect(x: barX, y: frame.height - barHeight, width: barWidth, height: barHeight))
            barView.backgroundColor = .black
            
            let numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: barWidth, height: 20))
            numberLabel.textAlignment = .center
            numberLabel.textColor = .white
            numberLabel.font = UIFont.systemFont(ofSize: 12)
            numberLabel.text = "\(value)"
            
            barView.addSubview(numberLabel)
            
            addSubview(barView)
            bars.append(barView)
        }
    }
    
    func update(with array: [Int]) {
        let maxValue = array.max() ?? 1
        for (index, value) in array.enumerated() {
            let barHeight = CGFloat(value) / CGFloat(maxValue) * frame.height
            let barView = bars[index]
            barView.frame.origin.y = frame.height - barHeight
            barView.frame.size.height = barHeight
            
            if let numberLabel = barView.subviews.first as? UILabel {
                numberLabel.text = "\(value)"
            }
        }
    }

    func animateSwap(fromIndex: Int, toIndex: Int, completion: @escaping () -> Void) {
        guard fromIndex < bars.count, toIndex < bars.count, fromIndex != toIndex else {
            completion()
            return
        }
        
        let barView1 = bars[fromIndex]
        let barView2 = bars[toIndex]

        let tempX = barView1.frame.origin.x
        UIView.animate(withDuration: 0.3, animations: {
            // Swap the x positions of the bars
            barView1.frame.origin.x = barView2.frame.origin.x
            barView2.frame.origin.x = tempX
        }, completion: { _ in
            // Swap the bars in the array to keep consistency
            self.bars.swapAt(fromIndex, toIndex)
            completion()
        })
    }

}


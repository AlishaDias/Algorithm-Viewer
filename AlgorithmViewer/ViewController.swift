import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var sortingContainerView: UIView!
    @IBOutlet weak var sortingContainerView2: UIView!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var sizeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var algorithmSegmentedControl: UISegmentedControl!
    @IBOutlet weak var algorithmSegmentedControl2: UISegmentedControl!
    
    var sortingView: BarSortingView?
    var sortingView2: BarSortingView?
    var data: [Int] = []
    var data2: [Int] = []
    var arraySize: Int = 16

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSortingViews()
    }
    
    func setupSortingViews() {
        data = generateRandomArray(count: arraySize)
        data2 = Array(data)
        
        sortingView = BarSortingView(frame: sortingContainerView.bounds)
        sortingContainerView.addSubview(sortingView!)
        sortingView?.setup(with: data)
        
        sortingView2 = BarSortingView(frame: sortingContainerView2.bounds)
        sortingContainerView2.addSubview(sortingView2!)
        sortingView2?.setup(with: data2)
    }

    @IBAction func arraySegmentedControl(_ sender: UISegmentedControl) {
        updateArraySize()
        sortingView?.setup(with: data)
        sortingView2?.setup(with: data2)
    }
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false  //disable the button so that user cant select multiple options while sorting is happening

        // Use dispatch groups to manage completion of both sorting processes
        let dispatchGroup = DispatchGroup()

        // Start sorting for the first view
        let selectedIndex1 = algorithmSegmentedControl.selectedSegmentIndex
        dispatchGroup.enter()
        sortData(using: selectedIndex1, data: data, for: sortingView) {
            dispatchGroup.leave()
        }

        // Start sorting for the second view
        let selectedIndex2 = algorithmSegmentedControl2.selectedSegmentIndex
        dispatchGroup.enter()
        sortData(using: selectedIndex2, data: data2, for: sortingView2) {
            dispatchGroup.leave()
        }
    }

    
    func updateArraySize() {
        switch sizeSegmentedControl.selectedSegmentIndex {
        case 0:
            arraySize = 16
        case 1:
            arraySize = 32
        case 2:
            arraySize = 48
        case 3:
            arraySize = 64
        default:
            arraySize = 16
        }
        data = generateRandomArray(count: arraySize)
        data2 = Array(data)
    }
    
    func generateRandomArray(count: Int) -> [Int] {
        var data = Set<Int>()
        while data.count < count {
            data.insert(Int.random(in: 1...100))
        }
        return Array(data)
    }

    func sortData(using selectedIndex: Int, data: [Int], for sortingView: BarSortingView?, completion: @escaping () -> Void) {
        switch selectedIndex {
        case 0:
            insertionSort(data, for: sortingView, completion: completion)
        case 1:
            selectionSort(data, for: sortingView, completion: completion)
        case 2:
                quickSort(data: data, low: 0, high: data.count - 1, sortingView: sortingView) { sortedArray in
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            case 3:
                mergeSort(data: data, low: 0, high: data.count - 1, sortingView: sortingView) { sortedArray in
                    DispatchQueue.main.async {
                        completion()
                    }
                }
        default:
            print("Selected algorithm is not implemented")
            completion()
        }
    }

    // Insertion Sort
    func insertionSort(_ array: [Int], for sortingView: BarSortingView?, completion: @escaping () -> Void) {
        var a = array
        var i = 1

        func sortStep() {
            if i < a.count {
                var j = i
                func innerSortStep() {
                    if j > 0 && a[j] < a[j - 1] {
                        a.swapAt(j, j - 1)
                        DispatchQueue.main.async {
                            sortingView?.animateSwap(fromIndex: j, toIndex: j - 1) {
                                j -= 1
                                innerSortStep()
                            }
                        }
                    } else {
                        i += 1
                        sortStep()
                    }
                }
                innerSortStep()
            } else {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
        sortStep()
    }

    // Selection Sort
    func selectionSort(_ array: [Int], for sortingView: BarSortingView?, completion: @escaping () -> Void) {
        var a = array
        let n = a.count

        func sortStep(index: Int) {
            if index < n - 1 {
                var minIndex = index
                for j in index + 1 ..< n {
                    if a[j] < a[minIndex] {
                        minIndex = j
                    }
                }
                if minIndex != index {
                    a.swapAt(index, minIndex)
                    DispatchQueue.main.async {
                        sortingView?.animateSwap(fromIndex: index, toIndex: minIndex) {
                            sortStep(index: index + 1)
                        }
                    }
                } else {
                    sortStep(index: index + 1)
                }
            } else {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }

        sortStep(index: 0)
    }

    // Quick Sort
    func quickSort(data: [Int], low: Int, high: Int, sortingView: BarSortingView?, completion: @escaping ([Int]) -> Void) {
        let localArray = data
        func quickSortInternal(_ array: [Int], _ low: Int, _ high: Int, _ completion: @escaping ([Int]) -> Void) {
            if low < high {
                partition(array, low: low, high: high, sortingView: sortingView) { modifiedArray, pivotIndex in
                    let newArray = modifiedArray
                    quickSortInternal(newArray, low, pivotIndex - 1) { sortedArray in
                        quickSortInternal(sortedArray, pivotIndex + 1, high, completion)
                    }
                }
            } else {
                completion(array)
            }
        }

        quickSortInternal(localArray, low, high, completion)
    }

    func partition(_ a: [Int], low: Int, high: Int, sortingView: BarSortingView?, completion: @escaping ([Int], Int) -> Void) {
        var localArray = a
        let pivot = localArray[high]
        var i = low - 1

        func partitionStep(_ j: Int) {
            if j < high {
                if localArray[j] <= pivot {
                    i += 1
                    localArray.swapAt(i, j)
                    DispatchQueue.main.async {
                        sortingView?.animateSwap(fromIndex: i, toIndex: j) {
                            partitionStep(j + 1)
                        }
                    }
                } else {
                    partitionStep(j + 1)
                }
            } else {
                localArray.swapAt(i + 1, high)
                DispatchQueue.main.async {
                    sortingView?.animateSwap(fromIndex: i + 1, toIndex: high) {
                        completion(localArray, i + 1)
                    }
                }
            }
        }
        partitionStep(low)
    }
    
    //Merge Sort
    func mergeSort(data: [Int], low: Int, high: Int, sortingView: BarSortingView?, completion: @escaping ([Int]) -> Void) {
        let localArray = data

        func mergeSortInternal(_ array: [Int], low: Int, high: Int, completion: @escaping ([Int]) -> Void) {
            if low < high {
                let mid = (low + high) / 2
                mergeSortInternal(array, low: low, high: mid) { sortedLeftHalf in
                    mergeSortInternal(sortedLeftHalf, low: mid + 1, high: high) { sortedRightHalf in
                        self.merge(sortedRightHalf, low: low, mid: mid, high: high, sortingView: sortingView, completion: completion)
                    }
                }
            } else {
                completion(array)  // Run the current array if further division is not possible
            }
        }

        mergeSortInternal(localArray, low: low, high: high, completion: completion)
    }

    func merge(_ array: [Int], low: Int, mid: Int, high: Int, sortingView: BarSortingView?, completion: @escaping ([Int]) -> Void) {
        var newArray = array
        let leftArray = Array(array[low...mid])
        let rightArray = Array(array[mid+1...high])

        var leftIndex = 0
        var rightIndex = 0
        var mergedIndex = low

        func animateMerge() {
            if leftIndex < leftArray.count && rightIndex < rightArray.count {
                if leftArray[leftIndex] <= rightArray[rightIndex] {
                    newArray[mergedIndex] = leftArray[leftIndex]
                    leftIndex += 1
                } else {
                    newArray[mergedIndex] = rightArray[rightIndex]
                    rightIndex += 1
                }
                sortingView?.animateSwap(fromIndex: mergedIndex, toIndex: mergedIndex) {
                    mergedIndex += 1
                    animateMerge()
                }
            } else {
                finishMerging()
            }
        }

        func finishMerging() {
            while leftIndex < leftArray.count {
                newArray[mergedIndex] = leftArray[leftIndex]
                leftIndex += 1
                mergedIndex += 1
            }
            while rightIndex < rightArray.count {
                newArray[mergedIndex] = rightArray[rightIndex]
                rightIndex += 1
                mergedIndex += 1
            }
            DispatchQueue.main.async {
                sortingView?.update(with: newArray)  // Assume this method updates the whole array
                completion(newArray)
            }
        }
        animateMerge()
    }
}

//
//  Queue.swift
//  diplomaThesis
//
//  Created by Apostolou Orestis on 10/3/21.
//
//  Queue datatype implementation for Swift.

import Foundation


/// A simple implementation of a Queue datatype.
class Queue {
    var size: Int
    var data: [Any]
    
    init(size: Int, data: [Any]) {
        self.size = size
        self.data = data
    }
    
    
    /// Inserts an element to a queue
    /// - Parameter element: The object to be inserted in the queue
    func insertElement(element: Any) {
        let dataSize = data.count
        if dataSize == 0 {
            data.append(element)
        } else if dataSize < size {
            data.append(data.last!)
            for i in stride(from: data.count - 2, to: 0, by: -1) {
                data[i] = data[i - 1]
            }
            data[0] = element
        } else {
            for i in stride(from: dataSize - 1, to: 0, by: -1) {
                data[i] = data[i - 1]
            }
            data[0] = element
        }
    }
    
    
    /// Returns Queue data as [Int].
    /// - Returns: [Int] of data.
    func getDataAsInt() -> [Int] {
        var output: [Int] = []
        for element in data {
            if element is Int {
                output.append(element as! Int)
            } else {
                output.append(0)
            }
        }
        return output
    }
}

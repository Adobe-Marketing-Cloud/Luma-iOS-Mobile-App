/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPServices
import Foundation

/// Thread safe FIFO Queue for Assurance
class ThreadSafeQueue<T> {
    private let limit: Int
    private var array: ThreadSafeArray<T> = ThreadSafeArray()

    /// Initializes the queue with the provide maximum capacity
    init(withLimit  limit: Int) {
        self.limit = limit
    }

    /// Appends the specified element to the end of this queue.
    /// If the queue has reached its limit then the first element of the queue is removed
    func enqueue(newElement: T) {
        self.array.append(newElement)
        if self.limit > 0 && self.array.count > self.limit {
            _ = self.array.removeFirst()
        }
    }

    /// Retrieves and removes the first element of this queue.
    /// Returns nil if this queue is empty.
    func dequeue() -> T? {
        return array.removeFirst()
    }

    /// Returns the current size of the queue
    func size() -> Int {
        return array.count
    }

    /// Removes all of the elements from this queue.
    func clear() {
        self.array.clear()
    }
}

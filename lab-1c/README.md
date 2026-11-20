# Lab 1C — Collections and Enums

## When to Use Array, Set, and Dictionary (R5)

| Collection | Best Use Case | Key Properties |
| :--- | :--- | :--- |
| **`Array`** | Ordered sequences where element position matters and duplicates are allowed (e.g., course lists, task queues). | Preserves order, supports index lookup, allows duplicate values. |
| **`Set`** | Unordered collections requiring unique items and fast membership checks (e.g., deduplicating student IDs). | Automatically removes duplicates, fast $O(1)$ lookup, requires `Hashable` elements. |
| **`Dictionary`** | Key-value mappings where each item is looked up by a unique identifier (e.g., mapping student ID to exam score). | Fast $O(1)$ key-based lookup, unique `Hashable` keys, unordered storage. |

## Program Output

```text
=== R1: Course Catalog (Array) ===
Initial Courses: ["iOS Architecture", "Swift Syntax", "Core Animation", "SwiftUI Essentials", "URLSession Networking"]
Updated Courses: ["iOS Architecture", "Swift Syntax", "SwiftUI Essentials", "URLSession Networking", "Combine Reactive"]
Sorted Courses: ["Combine Reactive", "Swift Syntax", "SwiftUI Essentials", "URLSession Networking", "iOS Architecture"]
Filtered ('Swift' prefix): ["Swift Syntax", "SwiftUI Essentials"]
Search 'URLSession Networking': Found

=== R2: Unique Student IDs (Set) ===
Total Submissions: 8
Unique IDs: [501, 502, 504, 509, 512]
Unique Student Count: 5

=== R3: Student Marks & Topper (Dictionary) ===
Topper -> Student ID 504 scored 95
Students scoring below 70:
- ID 502: 64
- ID 512: 58

=== R4: Task Priority (Enum & Switch) ===
Low Priority - Schedule when free
High Priority - Complete today
Critical - Immediate action required

=== Extension: Enum with Associated Values ===
Success: Retrieved 5 records from /students
Error 503: Server temporarily unavailable

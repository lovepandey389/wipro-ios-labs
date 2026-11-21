# Lab 8A: SwiftUI App Structure and Views

## Component Hierarchy Tree

CourseExplorerHomeView
 └── NavigationStack
      └── VStack
           ├── categoryFilterBar (ScrollView [.horizontal] -> HStack -> Category Filter Buttons)
           ├── List (when visibleCourses is non-empty)
           │    └── NavigationLink -> CourseDetailScreen
           │         │                     └── ScrollView -> VStack -> ZStack Hero Banner + Metadata + Overview
           │         └── CourseSummaryCard (ZStack)
           │              └── VStack
           │                   ├── HStack
           │                   │    ├── CategoryBadgeView
           │                   │    └── StatusPillView
           │                   ├── Title Text
           │                   └── Subtitle Text
           └── EmptyCoursesPlaceholderView (VStack with icon, message, and Restore button when courses is empty)

## Design & Layout Decisions (R1–R5)

- Extracted Reusable Subviews (R2 & R4): Separated `CourseSummaryCard`, `CategoryBadgeView`, `StatusPillView`, `EmptyCoursesPlaceholderView`, and `CourseDetailScreen` into standalone view structs so `CourseExplorerHomeView.body` stays concise and easy to read.
- Layout Containers Used (R2): Combines `VStack` for vertical flow, `HStack` for horizontal badge rows and category chips, `ZStack` for card backgrounds and hero headers, `ScrollView` for horizontal category chips and detail content, and `List` for efficient scrolling navigation.
- Previews & Empty State (R3 & R5): Includes `#Preview` blocks for both the full explorer screen and standalone `CourseSummaryCard`, plus a toolbar Clear/Load toggle to verify `EmptyCoursesPlaceholderView`.

# Test Feature Pages

## Created Pages

### 1. create_test_page.dart
Test creation and editing form with:
- ✅ Title and description fields
- ✅ Subject dropdown (Математика, Русский язык, etc.)
- ✅ Grade level picker (1-11)
- ✅ Difficulty selector (easy/medium/hard)
- ✅ Duration input
- ✅ Cover image picker
- ✅ Questions list with add/edit/delete functionality
- ✅ Question editor dialog with type selector (multiple choice/true-false/short answer)
- ✅ Save as draft / Publish buttons
- ✅ Form validation
- ✅ Riverpod state management

### 2. teacher_tests_page.dart
Teacher's test management dashboard with:
- ✅ Tabs for Draft/Published/Archived tests
- ✅ Search functionality
- ✅ Beautiful test cards with cover images
- ✅ Edit/Delete actions
- ✅ View analytics button (for published tests)
- ✅ Create new test FAB
- ✅ Real-time updates via Firestore streams
- ✅ Status indicators and metadata

### 3. test_analytics_page.dart
Comprehensive analytics dashboard with:
- ✅ Overall statistics (total attempts, average score, completion rate, pass rate)
- ✅ Score distribution bar chart (using fl_chart)
- ✅ Question-by-question performance with visual indicators
- ✅ Student results list with scores
- ✅ Weak topics identification
- ✅ Export to CSV button (placeholder)
- ✅ Clean, modern UI with Montserrat font

## Design Features
- Clean, modern UI similar to Notion
- Uses Google Fonts (Montserrat)
- App colors from `core/theme/app_colors.dart`
- Responsive layout
- Beautiful cards with shadows
- Visual feedback and loading states

## Dependencies Added
- `fl_chart: ^0.68.0` - For charts in analytics
- `uuid: ^4.5.1` - For generating unique IDs

## Usage Example

```dart
// Navigate to create test
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const CreateTestPage()),
);

// Navigate to teacher tests
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const TeacherTestsPage()),
);

// Navigate to analytics
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => TestAnalyticsPage(testId: 'test123'),
  ),
);
```

## State Management
All pages use Riverpod for state management:
- `testRepositoryProvider` - Access to TestRepository
- `teacherTestsProvider` - Stream of teacher's tests
- `testAnalyticsProvider` - Analytics data for a specific test

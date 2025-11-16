# MOODLY - IMPLEMENTATION PLAN
## For AI Agents and LLMs

**Document Purpose**: Track completed work and outline next implementation priorities
**Last Updated**: 2025-11-16
**Status**: Framework Complete, Ready for Phase 1 Implementation

---

## COMPLETED WORK

### Directory Structure
```
MoodTrackerApp/
├── App/
│   ├── MoodTrackerApp.swift          ✅ Created - App entry with SwiftData container
│   └── ContentView.swift             ✅ Created - Main navigation with onboarding check
├── Models/
│   ├── MoodEntry.swift               ✅ Created - SwiftData model for mood logs
│   ├── UserProfile.swift             ✅ Created - SwiftData model for user settings
│   ├── ActivityCorrelation.swift     ✅ Created - SwiftData model for analytics cache
│   └── Trigger.swift                 ✅ Created - SwiftData model for fired alerts
├── Views/
│   ├── Onboarding/
│   │   ├── WelcomeView.swift         ✅ Created - Welcome screen placeholder
│   │   ├── GoalSelectionView.swift   ✅ Created - Goal selection UI
│   │   └── CategorySelectionView.swift ✅ Created - Category selection with profile creation
│   ├── MoodEntry/
│   │   ├── MoodEntryView.swift       ✅ Created - Main entry form with save logic
│   │   ├── MoodPickerView.swift      ✅ Created - 5-point mood selector
│   │   └── ActivitySelectorView.swift ✅ Created - Activity grid selector
│   ├── Calendar/
│   │   └── CalendarView.swift        ✅ Created - Placeholder for calendar grid
│   ├── Analytics/
│   │   ├── InsightsView.swift        ✅ Created - Analytics dashboard with data states
│   │   └── WeeklyReportView.swift    ✅ Created - Placeholder for weekly summary
│   └── Settings/
│       └── SettingsView.swift        ✅ Created - Settings with notification toggle
├── Analytics/
│   ├── CorrelationCalculator.swift   ✅ Created - Activity-mood correlation math
│   ├── PatternDetector.swift         ✅ Created - Streak & pattern detection
│   ├── SuggestionEngine.swift        ✅ Created - Recommendation logic
│   └── TriggerManager.swift          ✅ Created - Proactive alert system
├── Utilities/
│   ├── PromptGenerator.swift         ✅ Created - Context-aware journal prompts
│   ├── NotificationManager.swift     ✅ Created - Local notification handling
│   └── Extensions.swift              ✅ Created - Helper extensions for Date, Array, Int
└── Resources/
    ├── Activities.json               ✅ Created - 25 activities with metadata
    ├── OnboardingTemplates.json      ✅ Created - 5 goal templates
    └── Prompts.json                  ✅ Created - Prompt templates
```

### Models Implementation Details
- **MoodEntry**: Full implementation with mood (1-5), activities array, optional journal/sleep/energy
- **UserProfile**: Goals, tracking categories, onboarding state, notification preferences
- **ActivityCorrelation**: Pre-computed analytics with avgMoodWith/Without, successRate, timesObserved
- **Trigger**: Fired alert tracking with type, message, timestamp, dismissal state

### Views Implementation Status
- **Onboarding Flow**: Basic UI complete, creates UserProfile on completion
- **Mood Entry**: Full form with mood picker, activity selector, journal input, optional details
- **Calendar**: Placeholder only - needs grid implementation
- **Insights**: Data state handling (empty vs populated), placeholder for sections
- **Settings**: Notification toggle, data export stub, onboarding reset

### Analytics Engine
- **CorrelationCalculator**: Complete algorithm for activity-mood correlations
- **PatternDetector**: Streak detection, day-of-week patterns, sleep correlation
- **SuggestionEngine**: Ranking logic, fallback suggestions, feasibility checks
- **TriggerManager**: Four trigger types (missed activity, low mood streak, sleep warning, positive streak)

### Utilities
- **PromptGenerator**: Rule-based prompt selection with activity-specific variants
- **NotificationManager**: Daily reminders, trigger notifications, weekly reports
- **Extensions**: Date helpers, array aggregations, mood emoji/color converters

### Configuration Files
- **Activities.json**: 25 activities across health, social, work, lifestyle, creative, self-care
- **OnboardingTemplates.json**: 5 goal templates with recommended categories and educational tips
- **Prompts.json**: Organized by mood_drop, mood_improved, neutral, activity_specific, streak

---

## NEXT PRIORITIES

### PHASE 1: XCODE PROJECT SETUP [HIGH PRIORITY]
**Blocking**: All subsequent work depends on this

**Tasks**:
1. Create Xcode project with iOS 17.0 minimum deployment
2. Add SwiftData capability
3. Add iCloud CloudKit capability for sync
4. Configure Info.plist for notifications (NSUserNotificationsUsageDescription)
5. Configure app identifier and team
6. Add all Swift files to project targets
7. Add JSON files to bundle resources
8. Test compilation and resolve any import/syntax errors

**Files to Import**:
- All .swift files from MoodTrackerApp/
- All .json files from MoodTrackerApp/Resources/

**Build Settings**:
- iOS Deployment Target: 17.0
- Swift Language Version: 5.9+
- Frameworks: SwiftUI, SwiftData, CloudKit, BackgroundTasks, UserNotifications

---

### PHASE 2: ONBOARDING COMPLETION [HIGH PRIORITY]
**Status**: UI scaffolding complete, needs integration work

**Remaining Work**:
1. Load OnboardingTemplates.json and populate goal recommendations dynamically
2. Map goal selection to recommended categories from JSON
3. Show educational tips during category selection
4. Implement notification permission request (step 4 of onboarding)
5. Create first entry tutorial overlay
6. Add progress indicator (step X of 4)
7. Persist onboarding completion state correctly

**Current Gaps**:
- GoalSelectionView uses hardcoded goals (should load from JSON)
- CategorySelectionView uses placeholder categories (should map from goal)
- No notification permission request step
- No first entry tutorial

**Files to Modify**:
- Views/Onboarding/GoalSelectionView.swift
- Views/Onboarding/CategorySelectionView.swift
- Create: Views/Onboarding/NotificationPermissionView.swift
- Create: Views/Onboarding/FirstEntryTutorialView.swift

---

### PHASE 3: MOOD ENTRY INTEGRATION [MEDIUM PRIORITY]
**Status**: UI complete, needs prompt integration and suggestion display

**Remaining Work**:
1. Integrate PromptGenerator to show context-aware prompts
2. Add suggestion display after logging mood ≤ 2
3. Connect SuggestionEngine to show recommendations
4. Add haptic feedback on mood selection
5. Enable editing past entries (up to 7 days back)
6. Auto-save on field changes (remove explicit save button if desired)

**Current Gaps**:
- MoodEntryView shows static prompt instead of generated prompt
- No suggestion display after bad mood log
- No past entry editing capability
- No haptic feedback

**Files to Modify**:
- Views/MoodEntry/MoodEntryView.swift
- Create: Views/MoodEntry/SuggestionCardView.swift

---

### PHASE 4: CALENDAR VIEW [MEDIUM PRIORITY]
**Status**: Placeholder only, needs full implementation

**Required**:
1. Monthly calendar grid (7 columns x 5-6 rows)
2. Query MoodEntry data and display mood emoji per day
3. Color-code days by mood (use Int.moodColor extension)
4. Tap day to show entry details
5. Highlight current day
6. Show streak indicator
7. Swipe between months
8. Quick add floating button for today

**Implementation Notes**:
- Use LazyVGrid with 7 columns
- Query entries grouped by date
- Present sheet for entry details on tap
- Calculate streak using Array.currentStreak() extension

**Files to Modify**:
- Views/Calendar/CalendarView.swift
- Create: Views/Calendar/DayCell.swift
- Create: Views/Calendar/EntryDetailView.swift

---

### PHASE 5: ANALYTICS INTEGRATION [MEDIUM PRIORITY]
**Status**: Engine complete, needs view integration

**Remaining Work**:
1. Wire CorrelationCalculator to InsightsView
2. Trigger correlation calculation on app open if stale (>24 hours)
3. Display top 3 performers with ActivityCorrelation data
4. Wire PatternDetector and display detected patterns
5. Add loading state during calculation
6. Implement weekly summary calculation
7. Create WeeklyReportView content

**Current Gaps**:
- InsightsView shows placeholder data instead of real correlations
- No calculation trigger mechanism
- No loading states
- WeeklyReportView empty

**Files to Modify**:
- Views/Analytics/InsightsView.swift
- Views/Analytics/WeeklyReportView.swift
- Consider: Create Analytics/AnalyticsCoordinator.swift for orchestration

---

### PHASE 6: BACKGROUND TASKS & NOTIFICATIONS [LOW PRIORITY]
**Status**: NotificationManager complete, needs BackgroundTasks setup

**Required**:
1. Register background task identifiers in Info.plist
2. Implement BGAppRefreshTask for daily trigger check (9am)
3. Implement BGProcessingTask for weekly analytics (Sunday 8pm)
4. Call TriggerManager.checkAllTriggers() in background handler
5. Send notifications via NotificationManager
6. Test background task scheduling in Xcode debugger

**Background Task Identifiers**:
- com.moodtracker.trigger-check (daily at 9am)
- com.moodtracker.analytics-refresh (weekly Sunday 8pm)

**Files to Create**:
- Utilities/BackgroundTaskManager.swift

**Files to Modify**:
- App/MoodTrackerApp.swift (register tasks on app launch)

---

### PHASE 7: DATA EXPORT [LOW PRIORITY]
**Status**: Settings stub exists, needs implementation

**Required**:
1. Query all MoodEntry entities
2. Convert to CSV format: date, mood, activities, journal_text, sleep_hours, energy_level
3. Present UIActivityViewController (share sheet)
4. Allow save to Files or email

**Files to Modify**:
- Views/Settings/SettingsView.swift
- Create: Utilities/DataExporter.swift

---

### PHASE 8: POLISH & TESTING [LOW PRIORITY]
**Status**: Not started

**Tasks**:
1. Add unit tests for CorrelationCalculator
2. Add unit tests for PatternDetector
3. Add unit tests for SuggestionEngine
4. Create sample data generator for testing
5. Dark mode verification
6. Accessibility audit (VoiceOver, Dynamic Type)
7. Performance testing with 1000+ entries
8. Memory profiling
9. Bug fixes

---

## LINGERING QUESTIONS

### Technical Decisions Required
1. **iCloud Sync Strategy**: Spec says use `.automatic` CloudKit config - confirm this handles conflicts properly (last-write-wins acceptable for MVP?)

2. **JSON Loading**: Activities.json, OnboardingTemplates.json, Prompts.json need loading mechanism - use Bundle.main.url or property wrapper? Create JSONLoader utility?

3. **Background Task Testing**: Background tasks are hard to test in simulator - what's the testing strategy? Use Xcode's e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"identifier"]?

4. **Correlation Recalculation Trigger**: Spec says "recalculate on app open if > 24 hours" - where should this logic live? App launch? InsightsView.onAppear? Separate coordinator?

5. **Past Entry Editing**: Spec says allow editing up to 7 days back - should this be a separate view or inline in calendar? How to prevent cheating/retroactive data manipulation?

### UX/Design Questions
1. **Suggestion Display Timing**: Show suggestions immediately after mood ≤ 2 log, or on separate screen after save?

2. **First Entry Tutorial**: Should this be interactive overlays, or full-screen tutorial slides? How intrusive?

3. **Calendar Navigation**: Swipe between months or use date picker header? Which is more intuitive for users?

4. **Notification Timing**: Default daily reminder at 8pm - should this be customizable in MVP or wait for v2?

5. **Empty States**: Spec doesn't define empty state UX for calendar when user has 0 entries - show prompts to log first entry?

### Feature Scope Clarifications
1. **Activity Customization**: Spec mentions user can "add/remove categories" but no UI defined - is this in Settings or during onboarding only?

2. **Photo Attachments**: MoodEntryView has placeholder for "attach photos" in spec section 3.2 but not in models - is this Phase 1 or future?

3. **Streak Celebration Notification**: Spec says fire after 7 consecutive days - should this be in TriggerManager or separate logic?

4. **Weekly Report Content**: WeeklyReportView placeholder exists but spec section 3.4 is vague on exact content - needs clarification

5. **Data Cleanup**: Spec says "clean up Trigger entities older than 90 days" - when/where should this run?

---

## INTEGRATION CHECKLIST

Before claiming "Phase 1 Complete", verify:
- [ ] Xcode project compiles without errors
- [ ] All SwiftData models work with in-memory preview
- [ ] App launches and shows onboarding for new user
- [ ] User can complete onboarding and create profile
- [ ] User can log first mood entry and it persists
- [ ] Tab navigation works between all 4 tabs
- [ ] JSON files load correctly from bundle
- [ ] iCloud sync configured (even if not tested end-to-end)

---

## RECOMMENDED IMPLEMENTATION ORDER

**For next agent/LLM to pick up**:
1. START: Phase 1 (Xcode setup) - blocking for everything else
2. THEN: Phase 2 (onboarding completion) - user's first experience
3. THEN: Phase 3 (mood entry integration) - core functionality
4. THEN: Phase 4 (calendar view) - primary user interface
5. THEN: Phase 5 (analytics integration) - app's key differentiator
6. DEFER: Phase 6 (background tasks) - nice to have
7. DEFER: Phase 7 (data export) - low priority
8. LAST: Phase 8 (polish/testing) - iterative improvements

---

## NOTES FOR AI AGENTS

**Code Style**:
- Use modern Swift concurrency (async/await) per spec
- Prefer structs over classes
- Use SwiftUI property wrappers (@State, @Query, @Environment)
- Add inline comments for business logic

**Testing Strategy**:
- Use .modelContainer(..., inMemory: true) for previews
- Create sample data helpers for testing views
- Test edge cases: 0 entries, 1-9 entries, 1000+ entries

**Performance Considerations**:
- Don't load all entries at once - use pagination where needed
- Cache ActivityCorrelation results per spec
- Keep background task processing under 10 seconds

**Error Handling**:
- Gracefully handle missing JSON files
- Handle SwiftData save failures
- Show user-friendly error messages, not raw errors

**Accessibility**:
- All images need .accessibilityLabel
- Ensure 4.5:1 contrast ratio minimum
- Test with Dynamic Type sizes

---

## REFERENCE FILES

**Authoritative Spec**: /home/user/moodly/implementationdoc.md
**This Plan**: /home/user/moodly/IMPLEMENTATION_PLAN.md
**Code Location**: /home/user/moodly/MoodTrackerApp/

**Key Architecture Decisions** (from spec):
- iOS 17.0+ only
- SwiftUI + SwiftData (no UIKit, no Core Data)
- No backend, no analytics, no third-party frameworks
- All data local + iCloud sync
- Privacy-first (no data leaves device except iCloud)

---

END OF IMPLEMENTATION PLAN

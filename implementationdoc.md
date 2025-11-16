## **Implementation Document for LLM Agent Development**

Here's the structure that works best for Claude Code and other coding agents:

---

# **Mood Tracker App - Implementation Specification**

**Document Version:** 1.0  
**Last Updated:** [Date]  
**Target Platform:** iOS 17.0+  
**Primary Framework:** SwiftUI + SwiftData  
**Development Tool:** Xcode 15+

---

## **1. PROJECT OVERVIEW**

### **1.1 Product Vision**
A mood tracking app that provides actionable insights to help users improve their mental wellbeing. Unlike competitors that only track patterns, our app tells users what to DO about those patterns.

### **1.2 Core Differentiators**
1. **Action Gap Solution:** Provides personalized, actionable suggestions based on user data
2. **Smart Onboarding:** Goal-based setup with curated tracking categories
3. **Intelligent Prompts:** Context-aware journal prompts that adapt to user state
4. **Proactive Alerts:** Catches patterns and intervenes before mood declines

### **1.3 Technical Approach**
- **Pure iOS:** All data storage and processing on-device using SwiftData
- **No Backend:** iCloud sync for backup, no custom servers
- **Rules-Based Analytics:** Simple correlation math, no ML/AI required for MVP
- **Privacy-First:** Zero data leaves device except iCloud backup

---

## **2. APP ARCHITECTURE**

### **2.1 Technology Stack**
```
UI Layer: SwiftUI
Data Layer: SwiftData (Core Data wrapper)
Storage: Local SQLite + iCloud sync via CloudKit
Background: BackgroundTasks framework
Notifications: UserNotifications framework
```

### **2.2 Data Models**

**Primary Entities:**

**MoodEntry**
- Purpose: Stores each mood check-in
- Relationships: None (standalone entries)
- Key Properties:
  - `id`: UUID (primary key)
  - `date`: Date (when logged)
  - `mood`: Int (1-5 scale: 1=terrible, 5=great)
  - `activities`: [String] (array of activity identifiers)
  - `journalText`: String? (optional written reflection)
  - `sleepHours`: Double? (optional sleep tracking)
  - `energyLevel`: Int? (optional 1-5 scale)

**UserProfile**
- Purpose: Stores user preferences and settings
- Relationships: None
- Key Properties:
  - `id`: UUID (primary key)
  - `goals`: [String] (selected during onboarding: "reduce_stress", "better_sleep", etc.)
  - `trackingCategories`: [String] (activities user chose to track)
  - `onboardingCompleted`: Bool
  - `createdAt`: Date
  - `notificationsEnabled`: Bool

**ActivityCorrelation** (cached analytics)
- Purpose: Pre-computed correlations to avoid re-calculating constantly
- Relationships: None
- Key Properties:
  - `id`: UUID (primary key)
  - `activityId`: String (reference to activity)
  - `avgMoodWith`: Double (average mood when doing activity)
  - `avgMoodWithout`: Double (average mood when not doing)
  - `successRate`: Double (% of times mood improved after activity)
  - `timesObserved`: Int (how many entries include this activity)
  - `lastCalculated`: Date (when correlation was last updated)

**Trigger** (fired alerts)
- Purpose: Track which proactive alerts have been shown
- Relationships: None
- Key Properties:
  - `id`: UUID (primary key)
  - `triggerType`: String ("missed_exercise", "mood_streak", etc.)
  - `firedAt`: Date
  - `userDismissed`: Bool (whether user acted on it)
  - `message`: String (what was shown to user)

### **2.3 File Structure**
```
MoodTrackerApp/
├── App/
│   ├── MoodTrackerApp.swift (app entry point)
│   └── ContentView.swift (main navigation)
├── Models/
│   ├── MoodEntry.swift
│   ├── UserProfile.swift
│   ├── ActivityCorrelation.swift
│   └── Trigger.swift
├── Views/
│   ├── Onboarding/
│   │   ├── WelcomeView.swift
│   │   ├── GoalSelectionView.swift
│   │   └── CategorySelectionView.swift
│   ├── MoodEntry/
│   │   ├── MoodEntryView.swift
│   │   ├── MoodPickerView.swift
│   │   └── ActivitySelectorView.swift
│   ├── Calendar/
│   │   └── CalendarView.swift
│   ├── Analytics/
│   │   ├── InsightsView.swift
│   │   └── WeeklyReportView.swift
│   └── Settings/
│       └── SettingsView.swift
├── Analytics/
│   ├── CorrelationCalculator.swift
│   ├── PatternDetector.swift
│   ├── SuggestionEngine.swift
│   └── TriggerManager.swift
├── Utilities/
│   ├── PromptGenerator.swift
│   ├── NotificationManager.swift
│   └── Extensions.swift
└── Resources/
    ├── Activities.json (master activity list)
    ├── OnboardingTemplates.json (goal-based templates)
    └── Prompts.json (prompt templates)
```

---

## **3. FEATURE SPECIFICATIONS**

### **3.1 Onboarding Flow**

**User Journey:**
1. Welcome screen → explains app value
2. Goal selection → pick primary reason for using app
3. Category selection → show recommended tracking categories based on goal
4. Permissions → request notifications
5. First entry → guided mood logging

**Goal Options:**
```
- "reduce_stress": Reduce stress and anxiety
- "better_sleep": Improve sleep quality
- "understand_moods": Understand mood swings
- "more_energy": Increase energy levels
- "manage_condition": Manage chronic condition (anxiety/depression)
```

**Template Logic:**
- Each goal maps to specific tracking categories
- Example: "reduce_stress" suggests: sleep, exercise, work_hours, caffeine, social_time, meditation
- Show 6-8 categories max (avoid overwhelming)
- User can add/remove categories

**Required Elements:**
- Skip button on category selection (let users customize later)
- Clear explanation of WHY each category matters
- Visual progress indicator (step 1 of 4, etc.)

---

### **3.2 Mood Entry View**

**Entry Components (in order):**

1. **Mood Picker**
   - 5-point scale with emoji/face visualization
   - Values: 1 (terrible), 2 (bad), 3 (okay), 4 (good), 5 (great)
   - Tappable faces or slider
   - Required field

2. **Activity Selector**
   - Grid of icons for selected tracking categories
   - Multi-select (can pick multiple activities)
   - User's custom categories appear here
   - Optional field

3. **Context Prompt**
   - Generated by PromptGenerator based on mood + recent history
   - Text field for response (optional)
   - Examples:
     - "You seem down today. What's weighing on you?"
     - "Great mood! What made today special?"

4. **Optional Details**
   - Expandable section for:
     - Sleep hours (number input)
     - Energy level (1-5 scale)
     - Photos (attach images)

**Behavior:**
- Auto-save on field changes (no "save" button needed)
- Show suggestions immediately if mood ≤ 2
- Haptic feedback on mood selection
- Allow editing past entries (up to 7 days back)

---

### **3.3 Calendar View**

**Display:**
- Monthly calendar grid
- Each day shows mood emoji/color
- Tap day → see full entry details
- Current day highlighted
- Streak indicator (consecutive days logged)

**Visual Encoding:**
- Color-code days by mood (1=red, 5=green gradient)
- Empty days = gray/unfilled
- Today = bold border

**Interactions:**
- Tap day → open detailed view
- Swipe between months
- Quick add for today (floating button)

---

### **3.4 Insights/Analytics View**

**Sections:**

**1. Current Week Summary**
- Average mood this week
- Comparison to last week (% change)
- Total entries logged
- Current streak

**2. Top Performers**
- List top 3 activities with highest success rate
- Show: Activity name, success rate %, times observed
- Format: "Exercise: 85% success rate (17/20 times)"

**3. Patterns Detected**
- Show any detected patterns from PatternDetector
- Examples:
  - "Low mood every Monday (3 weeks in a row)"
  - "Mood drops when sleep < 6 hours"
  - "Best days follow exercise"

**4. Activity Breakdown**
- Chart showing frequency of each tracked activity
- Filter by time period (week, month, 3 months)

**Update Frequency:**
- Recalculate on app open if last calculation > 24 hours
- Show loading state during calculation
- Cache results in ActivityCorrelation entities

---

### **3.5 Suggestions System**

**When to Show:**
- Immediately after logging mood ≤ 2 (bad or terrible)
- In weekly report
- When proactive trigger fires

**How Suggestions Are Generated:**

**Step 1: Calculate Correlations**
- For each activity user tracks, calculate:
  - Average mood on days WITH activity
  - Average mood on days WITHOUT activity
  - Difference = correlation score
  - Success rate = % of times mood ≥ 4 after activity

**Step 2: Filter & Rank**
- Exclude activities with < 3 observations (not enough data)
- Rank by success rate
- Consider recency (prefer activities done in last 30 days)

**Step 3: Present Top 3**
- Show as actionable cards
- Format: "[Activity] helped [X]% of the time ([Y]/[Z] times)"
- Include quick action button (e.g., "Schedule walk")

**Fallback Behavior:**
- If < 10 total entries: show generic research-backed suggestions
- Examples: "Try a 10-minute walk", "Call a friend", "Deep breathing (4-7-8 technique)"

---

### **3.6 Proactive Trigger System**

**Trigger Types:**

**1. Missed Helpful Activity**
- Condition: User hasn't done high-success activity in X days
- Threshold: 3+ days for exercise, 5+ days for social activities
- Check: Activity's success rate > 70%
- Message: "Haven't [activity] in [X] days. It usually helps your mood by [Y%]"

**2. Low Mood Streak**
- Condition: Mood ≤ 2 for 3+ consecutive days
- Check: User's baseline is higher
- Message: "Rough few days. Here are 3 things that have helped you before"
- Action: Show top suggestions

**3. Sleep Warning**
- Condition: Average sleep < 6 hours over last 5 days
- Check: User tracks sleep
- Message: "Sleep's been rough. This typically affects mood in 2-3 days"
- Action: Show sleep tips

**4. Positive Streak Recognition**
- Condition: Mood ≥ 4 for 5+ consecutive days
- Message: "Great week! Keep up whatever you're doing"
- Action: Highlight activities that coincided with good streak

**Trigger Firing Rules:**
- Check all triggers once daily (morning, 9am)
- Don't fire same trigger more than once per week
- Max 1 trigger per day (prioritize by severity)
- Log all triggers in Trigger entity

**Implementation:**
- Use BackgroundTasks framework
- Register background task identifier
- Check triggers in background task handler
- Send local notification if trigger fires
- Store trigger in database to avoid duplicates

---

## **4. ANALYTICS ENGINE SPECIFICATIONS**

### **4.1 Correlation Calculator**

**Purpose:** Determine which activities improve/worsen mood

**Algorithm:**
```
For each activity:
  1. Filter entries WITH activity → calculate average mood
  2. Filter entries WITHOUT activity → calculate average mood
  3. Correlation = avgMoodWith - avgMoodWithout
  4. Success rate = count(mood >= 4 after activity) / count(total)
  5. Store in ActivityCorrelation entity
```

**Requirements:**
- Minimum 10 total entries before calculating correlations
- Minimum 3 observations of specific activity
- Recalculate weekly or when new entries added
- Cache results to avoid re-calculating constantly

**Output:**
- ActivityCorrelation entity for each tracked activity
- Sorted list of activities by correlation strength

---

### **4.2 Pattern Detector**

**Purpose:** Find recurring trends in mood data

**Patterns to Detect:**

**Streak Detection:**
- Same mood 3+ days in a row
- Types: low_mood_streak, high_mood_streak, neutral_streak

**Day-of-Week Patterns:**
- Calculate average mood for each day of week
- Flag if one day is significantly different (±1.0 from average)
- Example: "Mondays average 2.3, your overall average is 3.5"

**Sleep Correlation:**
- When sleep < 6 hours, what's average mood next day?
- When sleep > 7.5 hours, what's average mood next day?

**Activity Gaps:**
- Identify high-success activities user hasn't done recently
- Calculate: days_since_last = today - last_occurrence

**Requirements:**
- Run pattern detection on-demand (when user opens Insights)
- Return array of Pattern objects
- Each pattern includes: type, description, confidence_score

**Output Example:**
```
Pattern(
  type: "day_of_week",
  description: "Mood drops on Sundays (avg 2.8 vs 3.5 overall)",
  confidence: 0.85
)
```

---

### **4.3 Suggestion Engine**

**Purpose:** Recommend activities most likely to improve user's current mood

**Input:** Current mood, recent history (last 7 days)

**Process:**
1. Fetch all ActivityCorrelation entities
2. Filter: successRate > 0.6 AND timesObserved >= 3
3. Sort by: successRate (primary), timesObserved (secondary)
4. Return top 3

**Contextual Adjustments:**
- Time of day: Don't suggest "exercise" at 10pm
- Recent activity: Don't suggest if user just did it today
- Feasibility: Prefer quick activities (< 30 min) for immediate suggestions

**Fallback Suggestions (if insufficient data):**
```
[
  "Take a 10-minute walk outside",
  "Call or text a friend",
  "Try 5 minutes of deep breathing",
  "Listen to your favorite music",
  "Do something creative (draw, write, etc.)"
]
```

---

### **4.4 Prompt Generator**

**Purpose:** Create contextual journal prompts based on user state

**Input:** Current mood, selected activities, recent history

**Prompt Selection Logic:**

**Rule 1: Mood Drop**
- Condition: Current mood < (7-day average - 1.0)
- Prompt options:
  - If work activity: "What about work felt especially hard today?"
  - If social activity: "How did social time feel different than usual?"
  - Generic: "Something shifted today. What changed?"

**Rule 2: Mood Improvement**
- Condition: Current mood > (7-day average + 1.0)
- Prompt options:
  - If new activity: "First time trying [activity] - how was it?"
  - Generic: "You seem brighter! What helped today?"

**Rule 3: Pattern Continuation**
- Condition: Same mood 3+ days in a row
- Prompt: "You've felt [mood] for [X] days. What's been on your mind?"

**Rule 4: Activity-Specific**
- Condition: User selected specific activity
- Prompt: "[Activity] today - how did it go?"

**Default Prompts:**
```
[
  "What's the main thing affecting how you feel?",
  "What's on your mind right now?",
  "How are you really doing today?",
  "What's one thing you're grateful for today?",
  "What would make tomorrow better?"
]
```

**Implementation:**
- Apply rules in order (1-4)
- Return first matching prompt
- Fall back to random default if no rules match
- Store prompts in Prompts.json for easy editing

---

## **5. CONFIGURATION FILES**

### **5.1 Activities.json**

**Purpose:** Master list of trackable activities with metadata

**Structure:**
```json
{
  "activities": [
    {
      "id": "exercise",
      "name": "Exercise",
      "icon": "figure.run",
      "category": "health",
      "typical_duration": 30,
      "recommended_for_goals": ["reduce_stress", "more_energy", "better_sleep"]
    },
    {
      "id": "social_time",
      "name": "Social Time",
      "icon": "person.2",
      "category": "social",
      "typical_duration": 60,
      "recommended_for_goals": ["reduce_stress", "understand_moods"]
    }
  ]
}
```

**Required Activities (20-30 total):**
- Health: exercise, sleep, meditation, yoga
- Social: friends, family, partner, colleagues
- Work: work_hours, meetings, deadlines
- Lifestyle: caffeine, alcohol, screen_time, nature
- Creative: reading, music, art, writing
- Self-care: therapy, journaling, hobbies

---

### **5.2 OnboardingTemplates.json**

**Purpose:** Goal-based category recommendations

**Structure:**
```json
{
  "templates": {
    "reduce_stress": {
      "goal_name": "Reduce stress and anxiety",
      "description": "Track factors that influence stress levels",
      "recommended_categories": [
        "sleep",
        "exercise",
        "work_hours",
        "caffeine",
        "social_time",
        "meditation"
      ],
      "educational_tips": [
        {
          "category": "sleep",
          "tip": "Stress hormones increase when you get less than 6 hours"
        },
        {
          "category": "exercise",
          "tip": "Physical activity reduces cortisol by up to 40%"
        }
      ],
      "initial_challenge": "gratitude_week"
    }
  }
}
```

**Required Templates:**
- reduce_stress
- better_sleep
- understand_moods
- more_energy
- manage_condition

---

### **5.3 Prompts.json**

**Purpose:** Template library for context-aware prompts

**Structure:**
```json
{
  "prompts": {
    "mood_drop": [
      "You seem down today. What's weighing on you?",
      "Your energy feels lower. What's draining you?",
      "Something shifted today. Want to talk about it?"
    ],
    "mood_improved": [
      "You seem brighter today! What helped?",
      "Great energy today! What's different?",
      "Nice turnaround! What changed?"
    ],
    "activity_specific": {
      "work": [
        "What about work felt especially challenging?",
        "Work today - what stood out?",
        "How was the work situation today?"
      ],
      "exercise": [
        "How did the workout feel?",
        "Did exercise help or drain you today?",
        "How's your body feeling after that?"
      ]
    }
  }
}
```

---

## **6. UI/UX REQUIREMENTS**

### **6.1 Design Principles**
- **Calm & Non-Judgmental:** Soft colors, no harsh reds/greens
- **Quick Entry:** Log mood in < 30 seconds
- **Celebration:** Positive reinforcement for streaks and progress
- **Clarity:** Always explain WHY something matters

### **6.2 Color Palette**
```
Mood Scale Colors (subtle gradients):
- Terrible (1): Soft muted purple #9B7EBD
- Bad (2): Muted blue #7FA5C9
- Okay (3): Neutral gray #A8A8A8
- Good (4): Soft green #89C9A0
- Great (5): Warm yellow #F4D35E

UI Colors:
- Background: System background (white/black)
- Primary action: Blue #007AFF (system default)
- Text: System primary/secondary
```

### **6.3 Typography**
- Use SF Pro (system font)
- Headers: Bold, 24-28pt
- Body: Regular, 16-17pt
- Captions: Regular, 13-14pt

### **6.4 Accessibility**
- Support Dynamic Type
- Ensure 4.5:1 contrast ratio minimum
- VoiceOver labels on all interactive elements
- Haptic feedback for key actions

---

## **7. BACKGROUND TASKS**

### **7.1 Daily Trigger Check**

**Task Identifier:** `com.moodtracker.trigger-check`

**Schedule:** Once per day at 9am

**Process:**
1. Fetch last 30 days of MoodEntry data
2. Run TriggerManager.checkAllTriggers()
3. For each trigger that fires:
   - Create Trigger entity
   - Send local notification
   - Schedule notification for appropriate time

**Battery Consideration:**
- Set `earliestBeginDate` to next 9am
- Keep processing under 10 seconds
- Use `BGAppRefreshTask` (not `BGProcessingTask`)

---

### **7.2 Weekly Analytics Update**

**Task Identifier:** `com.moodtracker.analytics-refresh`

**Schedule:** Once per week (Sunday 8pm)

**Process:**
1. Recalculate all ActivityCorrelation entities
2. Run pattern detection
3. Generate weekly report data
4. Send weekly summary notification

---

## **8. NOTIFICATIONS**

### **8.1 Notification Types**

**Daily Reminder**
- Time: User-selected (default 8pm)
- Message: "How was your day?" or rotate through variations
- Action: Deep link to mood entry

**Proactive Trigger**
- Time: When trigger fires (9am check)
- Message: Custom based on trigger type
- Actions: "View suggestions" or "Dismiss"

**Weekly Report**
- Time: Sunday 8pm
- Message: "Your week in review is ready"
- Action: Deep link to weekly report view

**Streak Celebration**
- Time: After logging 7th consecutive day
- Message: "7 day streak! You're building a great habit"
- Action: Deep link to calendar view

### **8.2 Notification Permissions**
- Request on onboarding (step 4)
- Explain value: "Get daily reminders and helpful nudges"
- Allow user to disable in settings
- Respect system notification settings

---

## **9. DATA MIGRATION & EXPORT**

### **9.1 iCloud Sync**
- Enable automatic CloudKit sync for all SwiftData models
- Use `.automatic` cloud database configuration
- Handle sync conflicts (last-write-wins for MVP)

### **9.2 Data Export**
- Settings option: "Export Data"
- Format: CSV file with columns:
  - date, mood, activities, journal_text, sleep_hours, energy_level
- Share sheet to save/email file

### **9.3 Data Import**
- Not required for MVP
- Future: Import from CSV

---

## **10. TESTING REQUIREMENTS**

### **10.1 Unit Tests**
- CorrelationCalculator: Test calculation accuracy
- PatternDetector: Test pattern identification
- SuggestionEngine: Test ranking logic
- PromptGenerator: Test rule application

### **10.2 Sample Data**
- Create mock data generator for testing
- Generate 30-90 days of realistic entries
- Include various patterns (streaks, correlations, etc.)

### **10.3 Edge Cases to Test**
- User with 0 entries (show onboarding)
- User with 1-9 entries (show "need more data" state)
- User who never journals (only logs mood/activities)
- User who logs same mood every day (detect lack of variance)
- User with deleted activity (handle gracefully)

---

## **11. PERFORMANCE REQUIREMENTS**

### **11.1 Response Times**
- Mood entry save: < 100ms
- Calendar view load: < 200ms
- Analytics calculation (1000 entries): < 500ms
- App cold start: < 1.5 seconds

### **11.2 Memory**
- Max memory usage: 100 MB
- Don't load all entries at once (use pagination)

### **11.3 Storage**
- Estimated: 2-5 MB per year of daily use
- Clean up Trigger entities older than 90 days

---

## **12. DEVELOPMENT PHASES**

### **Phase 1: Core Infrastructure**
✅ Set up Xcode project  
✅ Create SwiftData models  
✅ Build basic navigation structure  
✅ Implement iCloud sync  
✅ Create sample data generator  

**Deliverable:** App shell with data models and sync working

---

### **Phase 2: Mood Entry Flow**
✅ Mood entry view with mood picker  
✅ Activity selector (grid of icons)  
✅ Save functionality  
✅ Calendar view displaying entries  
✅ Edit past entries  

**Deliverable:** Users can log moods and view history

---

### **Phase 3: Onboarding**
✅ Welcome screen  
✅ Goal selection  
✅ Category selection with templates  
✅ Notification permissions  
✅ First entry tutorial  

**Deliverable:** Smooth first-time user experience

---

### **Phase 4: Analytics Engine**
✅ CorrelationCalculator implementation  
✅ PatternDetector implementation  
✅ ActivityCorrelation caching  
✅ Insights view showing correlations  
✅ Activity success scoring  

**Deliverable:** Users see which activities help them

---

### **Phase 5: Smart Features**
✅ SuggestionEngine implementation  
✅ Show suggestions after bad mood log  
✅ PromptGenerator implementation  
✅ Context-aware journal prompts  

**Deliverable:** App provides personalized help

---

### **Phase 6: Proactive System**
✅ TriggerManager implementation  
✅ Background task setup  
✅ Local notification sending  
✅ Trigger logging and deduplication  

**Deliverable:** App catches patterns and intervenes

---

### **Phase 7: Polish & Testing**
✅ Weekly report view  
✅ Settings screen  
✅ Data export  
✅ Accessibility improvements  
✅ Dark mode support  
✅ Unit tests  
✅ Bug fixes  

---

## **15. TECHNICAL CONSTRAINTS**

### **15.1 iOS Requirements**
- Minimum iOS version: 17.0
- Targets: iPhone only (iPad support in v2)
- Orientation: Portrait only

### **15.2 Dependencies**
- Zero third-party frameworks for MVP
- Use only Apple frameworks:
  - SwiftUI
  - SwiftData
  - CloudKit
  - BackgroundTasks
  - UserNotifications

### **15.3 Privacy**
- No analytics tracking for MVP
- No user accounts/authentication
- All data local + iCloud
- Privacy manifest required (describe data collection = none)

---

## **16. HANDOFF TO AI AGENT**

**When starting implementation:**

1. **Begin with Phase 1** (Core Infrastructure)
2. **Read Activities.json** structure and populate with 20-30 activities
3. **Read OnboardingTemplates.json** and create templates for 5 goals
4. **Create SwiftData models** exactly as specified in section 2.2
5. **Follow file structure** from section 2.3
6. **Implement features in phase order** - don't skip ahead
7. **Use sample data generator** to test with realistic data
8. **Test each phase** before moving to next

**Questions during implementation:**
- Refer back to this document for specifications
- If ambiguous, choose simplest approach first
- Flag unclear requirements for human review

**Code style preferences:**
- Use modern Swift concurrency (async/await)
- Prefer structs over classes
- Use SwiftUI property wrappers (@State, @Query, etc.)
- Add inline comments for business logic

---

**END OF SPECIFICATION**

This document should be treated as the source of truth for MVP development. Update as decisions are made.

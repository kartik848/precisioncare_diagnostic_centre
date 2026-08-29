# PrecisionCare Diagnostic Centre (Flutter + Firebase + Admin Panel)

A modern, production-grade Flutter healthcare & diagnostic mobile application with a real-time **Admin Operations Portal** and **ImgBB Image Cloud API** integration (`f1a3270cf5397a26e0b147cf3faae781`).

---

## 🌟 Complete End-to-End Parallel Workflow

```
[ PATIENT APP ]                                          [ ADMIN PANEL ]
      │                                                        │
1. Patient Selects Tests ───────────────────────────────► 1. Real-Time Alert in
   (Blood Test, X-Ray, ECG, Physio, PFT, etc.)               "Pending Requests" Queue
      │                                                        │
2. Chooses Date, Time Slot & Address                           │
   (Status: "Waiting for Admin Approval")                      │
      │                                                        │
      │                                                   2. Admin Reviews Request
      │                                                      & Clicks "Accept & Assign Staff"
      │                                                      (Phlebotomist / Radiographer / Physio)
      │                                                        │
3. Instant Notification Arrives in App ◄───────────────────────┘
   "Staff Vikram Singh assigned for your visit!"
   (Live Stepper: Confirmed ➔ Dispatched)
      │                                                        │
      │                                                   3. Admin Updates Status:
      │                                                      ➔ "Sample Collected / Test Done"
      │                                                      ➔ "In Lab Processing"
      │                                                        │
4. Stepper updates live in Patient App ◄───────────────────────┘
      │                                                        │
      │                                                   4. Admin Enters Lab Parameters &
      │                                                      Uploads Scans via ImgBB API
      │                                                      & Clicks "Sign & Release Lab Report"
      │                                                        │
5. Patient receives "📄 Report Ready" Alert ◄──────────────────┘
   & Downloads / Prints Verified PDF Report!
      │                                                        │
      │                                                   5. Admin Pushes "Next Test Due Reminder"
      │                                                      (e.g., 3-Month Diabetes HbA1c Review)
      │                                                        │
6. Patient receives Follow-Up Alert & books next visit! ◄──────┘
```

---

## 🛠️ ImgBB API Integration
- **ImgBB API Key**: `f1a3270cf5397a26e0b147cf3faae781`
- **Service File**: [lib/services/imgbb_service.dart](file:///Users/kartikkale/precisioncare_diagnostic_centre/lib/services/imgbb_service.dart)
- Automatically handles diagnostic scan uploads, digital radiography film hosting, and report attachment generation.

---

## 🖥️ Admin Operations Portal Features
- **Live Queue**: Real-time incoming bookings from the Patient App.
- **Accept & Assign Staff Modal**: Assign certified Phlebotomists, Portable DR Radiographers, Cardiac ECG Technicians, and Physiotherapists.
- **Upload Lab Report Modal**: Fill investigation values (Hb, Sugar, FVC, Cholesterol), attach ImgBB scans, and release signed reports.
- **Push Next Test Reminders**: Select patient and send custom clinical reminders (3-month Diabetes HbA1c, 6-month Cardiac Lipid follow-up, weekly Physio rehab, annual checkups).
- **Dual Mode Switcher**: Easily switch between Patient App and Admin Portal from the top navigation bar with a single tap.

---

## 🚀 How to Run the Parallel System

Terminal me navigate karein:
```bash
cd /Users/kartikkale/precisioncare_diagnostic_centre

# Chrome Web par run karein:
flutter run -d chrome

# macOS Desktop par run karein:
flutter run -d macos
```

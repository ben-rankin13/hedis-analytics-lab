# HEDIS Analytics Lab – Query Library

## Query: Hypertension Compliance by Insurance Provider

### Overview
This SQL query calculates the **Controlling High Blood Pressure (CBP)** HEDIS measure for hypertensive patients using 2019 clinical data. It identifies the most recent blood pressure reading for each patient and determines whether they are in compliance with the HEDIS target: systolic < 140 mmHg and diastolic < 90 mmHg.

### Key Features
- Identifies patients diagnosed with **hypertension** in 2019
- Pulls the most recent **systolic and diastolic blood pressure** readings for each patient
- Joins encounters and payer data to report compliance by **insurance provider**
- Calculates:
  - Total eligible patients per insurer
  - Number of compliant patients
  - Compliance rate per insurer

### Tables Used
- `patients`
- `conditions`
- `observations`
- `encounters`
- `payers`

### Output Columns
| Column                | Description                                  |
|-----------------------|----------------------------------------------|
| insurance_provider    | Name of payer associated with patient visit  |
| rate_compliance       | % of patients with controlled BP             |
| cnt_patients          | Total hypertensive patients per payer        |
| cnt_compliant_patients| Count of compliant patients per payer        |

### Notes
- Only the latest 2019 blood pressure reading is used per patient.
- Uses `TRY_CAST()` to handle BP values stored as strings or floats.
- Patient-level data is anonymized; this query is for demonstration purposes.

---

## File
- `hypertension_compliance_ins.sql` – Main query

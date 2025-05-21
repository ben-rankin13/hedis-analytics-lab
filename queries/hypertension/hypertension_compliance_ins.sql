-- Step 1: Identify hypertensive patients with BP readings in 2019
WITH cbp_patients AS (
    SELECT 
        p.id AS patient_id,
        pay.name AS insurance_provider,
        TRY_CAST(o1.value AS FLOAT) AS sbp,  -- systolic BP
        TRY_CAST(o2.value AS FLOAT) AS dbp,  -- diastolic BP
        o1.date AS obs_date,
        ROW_NUMBER() OVER (
            PARTITION BY p.id 
            ORDER BY o1.date DESC
        ) AS rn  -- get most recent BP reading in 2019 per patient
    FROM dbo.conditions c
    JOIN dbo.patients p 
        ON p.id = c.patient
    JOIN dbo.observations o1 
        ON o1.patient = p.id 
       AND o1.description = 'Systolic Blood Pressure'
    JOIN dbo.observations o2 
        ON o2.patient = p.id 
       AND o2.description = 'Diastolic Blood Pressure' 
       AND o2.date = o1.date
    LEFT JOIN dbo.encounters e 
        ON e.id = o1.encounter
    LEFT JOIN dbo.payers pay 
        ON pay.id = e.payer
    WHERE c.description = 'Hypertension'
      AND o1.date >= '2019-01-01' 
      AND o1.date < '2020-01-01'
),

-- Step 2: Assess compliance based on BP reading thresholds
compliance AS (
    SELECT 
        insurance_provider,
        patient_id,
        sbp,
        dbp,
        CASE 
            WHEN sbp < 140 AND dbp < 90 THEN 'yes' 
            ELSE 'no' 
        END AS compliant
    FROM cbp_patients
    WHERE rn = 1  -- only use most recent 2019 reading per patient
)

-- Step 3: Aggregate compliance rates by insurance provider
SELECT 
    insurance_provider,
    CAST(
        1.0 * COUNT(DISTINCT CASE WHEN compliant = 'yes' THEN patient_id END) 
        / COUNT(DISTINCT patient_id) 
        AS DECIMAL(5,3)
    ) AS rate_compliance,
    COUNT(DISTINCT patient_id) AS cnt_patients,
    COUNT(DISTINCT CASE WHEN compliant = 'yes' THEN patient_id END) AS cnt_compliant_patients
FROM compliance
GROUP BY insurance_provider
ORDER BY rate_compliance DESC;

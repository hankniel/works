SELECT *
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
WHERE user_pseudo_id = '415C84BA01B443C6898F6946DAB6379A'
ORDER BY event_timestamp
LIMIT 100

SELECT MIN(event_date), MAX(event_date)
FROM `royal-hexa-in-house.pixon_data_science.001_mock`


WITH user_level_timeline AS (
-- Track when users reach each level
SELECT 
	user_pseudo_id,
	event_timestamp,
	(SELECT value.int_value FROM UNNEST(event_params) WHERE key = "level") as level
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
WHERE (SELECT value.int_value FROM UNNEST(event_params) WHERE key = "level") IS NOT NULL
),
user_current_level AS (
  -- Get the current level for each user at any timestamp
SELECT 
	user_pseudo_id,
	event_timestamp,
	LEAD(event_timestamp) OVER (
		PARTITION BY user_pseudo_id 
		ORDER BY event_timestamp
	) as next_event_timestamp,
	LAST_VALUE(level IGNORE NULLS) OVER (
	PARTITION BY user_pseudo_id 
	ORDER BY event_timestamp
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) as current_level
FROM user_level_timeline
)
-- Attribute revenue to levels
SELECT 
	r.user_pseudo_id,
	r.event_timestamp,
	l.current_level,
	CASE 
		WHEN r.event_name = 'in_app_purchase' THEN r.event_value_in_usd
		WHEN r.event_name = 'ad_impression' THEN (
		SELECT value.double_value 
		FROM UNNEST(r.event_params) 
		WHERE key = 'value'
		)
		ELSE 0 
	END as revenue,
	r.event_name as revenue_source
FROM `royal-hexa-in-house.pixon_data_science.001_mock` r
LEFT JOIN user_current_level l
ON r.user_pseudo_id = l.user_pseudo_id
	AND r.event_timestamp BETWEEN l.event_timestamp AND l.next_event_timestamp
WHERE r.event_name IN ('in_app_purchase', 'ad_impression')
LIMIT 100 


SELECT * 
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
WHERE country = 'New Zealand'

SELECT event_params.key, event_params.value.string_value, *
FROM `royal-hexa-in-house.pixon_data_science.001_mock`, UNNEST(event_params) as event_params
WHERE event_params.key = 'currency'
	AND event_name = 'in_app_purchase'

SELECT event_params.key, event_params.value.string_value, event_params.value.int_value, event_params.value.double_value, *
FROM `royal-hexa-in-house.pixon_data_science.001_mock`, UNNEST(event_params) as event_params
WHERE event_name = 'in_app_purchase'
LIMIT 100

SELECT DISTINCT event_name
FROM `royal-hexa-in-house.pixon_data_science.001_mock`,
	UNNEST(event_params) as event_params
WHERE event_params.key = 'value'

SELECT COUNT(*)
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
LIMIT 100

-- Retention Rate
WITH cohort AS (
    SELECT 
        user_pseudo_id,
        PARSE_DATE('%Y%m%d', event_date) as cohort_date
    FROM `royal-hexa-in-house.pixon_data_science.001_mock`
    WHERE event_name = 'first_open'
        AND event_date = '20250102'
),
daily_retention AS (
    SELECT 
        cohort_date,
        DATE_DIFF(PARSE_DATE('%Y%m%d', e.event_date), cohort_date, DAY) as days_since_first_open,
        COUNT(DISTINCT CASE WHEN (event_name = 'open_app' OR event_name ='first_open') THEN e.user_pseudo_id END) as retained_users,
        (SELECT COUNT(DISTINCT user_pseudo_id) FROM cohort) as total_users
    FROM cohort
    LEFT JOIN `royal-hexa-in-house.pixon_data_science.001_mock` e
        ON cohort.user_pseudo_id = e.user_pseudo_id
            AND PARSE_DATE('%Y%m%d', e.event_date) BETWEEN cohort.cohort_date AND DATE_ADD(cohort.cohort_date, INTERVAL 14 DAY)
    GROUP BY cohort_date, days_since_first_open
)
SELECT 
    cohort_date,
    days_since_first_open,
    retained_users,
    total_users,
    ROUND(retained_users * 100.0 / total_users, 2) as retention_rate
FROM daily_retention
WHERE days_since_first_open BETWEEN 0 AND 14
ORDER BY cohort_date, days_since_first_open;

-- Ads, IAP Rev
SELECT 
	event_params.key as event_key,
	event_params.value.string_value as event_string_value,
	event_params.value.int_value as event_int_value,
	event_params.value.float_value as event_float_value,
	event_params.value.double_value as event_double_value,
	event_timestamp,
	event_name,
	user_pseudo_id,
	event_date,
	platform,
	CASE WHEN event_params.key = 'value' THEN event_params.value.double_value END AS revenue
FROM `royal-hexa-in-house.pixon_data_science.001_mock`, UNNEST(event_params) as event_params
WHERE 1 = 1
	-- AND (event_name LIKE 'ad_impression' OR event_name = 'in_app_purchase')
	AND event_name = 'ad_impression'
	AND (event_date BETWEEN '20250110' AND '20250115')
    -- AND event_timestamp = 1737873697394710
-- GROUP BY event_name, platform
LIMIT 100


WITH revenue AS (SELECT 
	event_name, 
	platform,
	CASE WHEN event_name = 'in_app_purchase' 
		THEN (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'quantity')
	WHEN event_name = 'ad_impression'
		THEN 1
		END AS quantity,
	CASE WHEN event_name = 'ad_impression' 
		THEN (SELECT value.double_value FROM UNNEST(event_params) WHERE key = 'value')
	WHEN event_name = 'in_app_purchase'
		THEN event_value_in_usd
		-- THEN (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'value')
		END AS unit_price
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
WHERE (event_name IN ('ad_impression', 'in_app_purchase'))
	AND (event_date BETWEEN '20250110' AND '20250115')
	)
SELECT 
	platform,
	event_name,
	SUM(unit_price) AS revenue
	-- SUM(quantity * unit_price) AS revenue
FROM revenue
GROUP BY platform, event_name

-- User
SELECT 
	event_name,
	user_properties.key, 
	user_properties.value.string_value, 
	user_properties.value.int_value, 
	user_properties.value.double_value, 
	user_properties.value.float_value,
	user_properties.value.set_timestamp_micros,
	*
FROM `royal-hexa-in-house.pixon_data_science.001_mock`, UNNEST(user_properties) as user_properties
WHERE user_properties.key = '_ltv_USD'
LIMIT 100

-- Query 1: User Base Overview
SELECT 
  platform,
  country,
  COUNT(DISTINCT user_pseudo_id) as total_users,
  COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN user_pseudo_id END) as active_users,
  COUNT(DISTINCT CASE WHEN event_name = 'in_app_purchase' THEN user_pseudo_id END) as paying_users,
  SUM(CASE WHEN event_name = 'in_app_purchase' THEN event_value_in_usd ELSE 0 END) as total_revenue
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
GROUP BY platform, country
ORDER BY total_revenue DESC;


SELECT 
	event_name,
	platform,
	(SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'quantity') as quantity,
	SUM(
		CASE WHEN event_params.key = 'value' AND event_name = 'ad_impression'
			THEN event_params.value.double_value 
		WHEN event_params.key = 'value' AND event_name = 'in_app_purchase' 
		END
		) AS revenue
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
WHERE (event_name IN ('ad_impression', 'in_app_purchase'))
	AND (event_date BETWEEN '20250110' AND '20250115')
    -- AND event_timestamp = 1737873697394710
GROUP BY event_name, platform
LIMIT 100


WHERE event_name LIKE '%ad%' OR event_name = 'in_app_purchase'
LIMIT 100
SELECT event_params.
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
LIMIT 100



SELECT *
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
WHERE user_pseudo_id = '8af1c33611a0c46417855a11ec9810b0'
ORDER BY event_timestamp
LIMIT 100
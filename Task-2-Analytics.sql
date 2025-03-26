SELECT DISTINCT event_name
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
ORDER BY event_name 

-- Error based on ad_exception, app_update, os_update
-- CX based, items purchased to win a level, win rate and lose rate, time to complete a level
-- Churn from game trigger point? Survival curve
-- Differences between users continue to stay vs users left


-- Ad-related events
"ad_impression" -- When an ad is shown to user
"ad_reward" -- When user gets reward from watching ad
"ads_inter_click" -- User clicks on interstitial ad
"ads_inter_fail" -- Interstitial ad failed to load
"ads_inter_load" -- Interstitial ad loaded successfully
"ads_inter_show" -- Interstitial ad is displayed
-- "ads_revenue_0_02" -- Ad revenue of $0.02 generated
"ads_reward_click" -- User clicks on rewarded ad
"ads_reward_complete" -- User completes watching rewarded ad
"ads_reward_fail" -- Rewarded ad failed to load
"ads_reward_load" -- Rewarded ad loaded successfully
"af_inters" -- AppsFlyer interstitial ad tracking
"af_rewarded" -- AppsFlyer rewarded ad tracking

-- App lifecycle events
"app_clear_data" -- User cleared app data
"app_exception" -- App encountered an error
"app_remove" -- App was uninstalled
"app_update" -- App was updated
"first_open" -- First time app opened
"open_app" -- App opened
"os_update" -- Operating system updated
"remote_config_load_failed" -- Failed to load remote config
"remote_config_load_success" -- Successfully loaded remote config
"screen_view" -- User viewed a screen
"session_start" -- New game session started
"user_engagement" -- User engaged with app

-- Gameplay events
"booster_buy" -- User purchased a booster
"booster_use" -- User used a booster
"lose_level" -- User failed a level
"lucky_spin" -- User spun lucky wheel
"refill_heart" -- User refilled lives/hearts
"revive" -- User revived after dying
"start_level" -- User started a level
-- "start_level_10" -- Started level 10
-- "start_level_15" -- Started level 15  
-- "start_level_20" -- Started level 20
-- "start_level_25" -- Started level 25
-- "start_level_30" -- Started level 30
-- "start_level_5" -- Started level 5
-- "start_level_7" -- Started level 7
"start_level_phase" -- Started a level phase
"win_level" -- User completed a level
"winstreak_claim" -- Claimed winstreak reward
"winstreak_start" -- Started a winstreak

-- Reward/IAP events
"campaign_first_open" -- First open during campaign
"chain_offer_claim" -- Claimed chain offer reward
"daily_chest_claim" -- Claimed daily chest
"daily_login_claim" -- Claimed daily login reward
"daily_task_claim" -- Claimed daily task reward
"firebase_campaign" -- Firebase campaign event
"free_pass_claim" -- Claimed free pass reward
"free_pass_claim_all" -- Claimed all free pass rewards
"gold_pass_claim" -- Claimed gold pass reward
"gold_pass_claim_all" -- Claimed all gold pass rewards
"in_app_purchase" -- Made in-app purchase
"inter_attempt" -- Attempted interaction
"reward_attempt" -- Attempted to claim reward

-- -- Video ad watch events
-- "watch_inter_10" -- Watched 10s interstitial
-- "watch_inter_12" -- Watched 12s interstitial
-- "watch_inter_15" -- Watched 15s interstitial
-- "watch_inter_3" -- Watched 3s interstitial
-- "watch_inter_5" -- Watched 5s interstitial
-- "watch_inter_7" -- Watched 7s interstitial
-- "watch_rw_10" -- Watched 10s rewarded video
-- "watch_rw_3" -- Watched 3s rewarded video
-- "watch_rw_5" -- Watched 5s rewarded video
-- "watch_rw_7" -- Watched 7s rewarded video


SELECT 
    event_name,
    event_param.key,
    CAST(COALESCE(
        event_param.value.string_value,
        CAST(event_param.value.int_value AS STRING),
        CAST(event_param.value.float_value AS STRING),
        CAST(event_param.value.double_value AS STRING)
    ) AS STRING) AS value,
    -- item_params,
    *
FROM `royal-hexa-in-house.pixon_data_science.001_mock`,
    UNNEST(event_params) AS event_param
WHERE 1 = 1
    AND user_pseudo_id = '8af1c33611a0c46417855a11ec9810b0'
    -- AND event_name = 'user_engagement'
    -- AND event_value_in_usd IS NOT NULL
ORDER BY event_timestamp
LIMIT 1000

SELECT 
    *
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
WHERE 1 = 1
    AND user_pseudo_id = '8af1c33611a0c46417855a11ec9810b0'
    -- AND event_name = 'user_engagement'
    -- AND event_value_in_usd IS NOT NULL
ORDER BY event_timestamp
LIMIT 1000



SELECT
    TIMESTAMP_MICROS(event_timestamp) as event_datetime,
    TIMESTAMP_DIFF(
        TIMESTAMP_MICROS(event_timestamp),
        LAG(TIMESTAMP_MICROS(event_timestamp)) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp),
        SECOND
    ) as seconds_since_last_event,
    TIMESTAMP_DIFF(
        TIMESTAMP_MICROS(event_timestamp),
        TIMESTAMP_MICROS(user_first_touch_timestamp),
        SECOND
    ) as seconds_since_first_touch,
    *
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
ORDER BY user_pseudo_id, event_timestamp
limit 100 

--* Level-related events
SELECT
    TIMESTAMP_DIFF(
        TIMESTAMP_MICROS(event_timestamp),
        LAG(TIMESTAMP_MICROS(event_timestamp)) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp),
        SECOND
    ) as seconds_since_last_event,
    CASE 
        WHEN event_name = 'start_level' THEN (
            SELECT value.string_value 
            FROM UNNEST(event_params) 
            WHERE key = 'level'
        )
        WHEN event_name = 'start_level_phase' THEN (
            SELECT value.string_value 
            FROM UNNEST(event_params) 
            WHERE key = 'phase'
        )
        WHEN event_name = 'win_level' THEN CAST((
            SELECT value.int_value 
            FROM UNNEST(event_params) 
            WHERE key = 'level'
        ) AS STRING)
        WHEN event_name = 'lose_level' THEN (
            SELECT value.string_value 
            FROM UNNEST(event_params) 
            WHERE key = 'level'
        )
        ELSE NULL 
    END AS level_phase,
    CASE 
        WHEN event_name = 'win_level' THEN (
            SELECT value.int_value 
            FROM UNNEST(event_params) 
            WHERE key = 'coin'
        )
    END AS coin,
    *
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
WHERE event_name IN ('start_level', 'start_level_phase', 'win_level', 'lose_level', 'revive')
ORDER BY user_pseudo_id, event_timestamp
LIMIT 100

--* In-app purchase events
SELECT 
    (SELECT )
    *
FROM `royal-hexa-in-house.pixon_data_science.001_mock`
WHERE event_name = 'in_app_purchase'
ORDER BY user_pseudo_id, event_timestamp
LIMIT 100


select 
    TIMESTAMP_MICROS(event_timestamp) as event_datetime,
    TIMESTAMP_DIFF(
        TIMESTAMP_MICROS(event_timestamp),
        LAG(TIMESTAMP_MICROS(event_timestamp)) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp),
        SECOND
    ) as seconds_since_last_event,
    * 
    
from `royal-hexa-in-house.pixon_data_science.001_mock`
where event_timestamp between 1735977575586717 and 1735977689629681
    and user_pseudo_id = '0006c547bcc14ede54f71fb9f8a5d7d6'
order by event_timestamp
limit 100


select 
    event_param.key,
    event_param.value.string_value as value,
    event_param.value.int_value as int_value,
    event_param.value.float_value as float_value,
    event_param.value.double_value as double_value
FROM `royal-hexa-in-house.pixon_data_science.001_mock`,
    unnest(event_params) as event_param
where event_name = 'in_app_purchase'
limit 100

--* Ad-related events

-- Ad-related events
"ad_impression" -- When an ad is shown to user
"ad_reward" -- When user gets reward from watching ad
"ads_inter_click" -- User clicks on interstitial ad
"ads_inter_fail" -- Interstitial ad failed to load
"ads_inter_load" -- Interstitial ad loaded successfully
"ads_inter_show" -- Interstitial ad is displayed
-- "ads_revenue_0_02" -- Ad revenue of $0.02 generated
"ads_reward_click" -- User clicks on rewarded ad
"ads_reward_complete" -- User completes watching rewarded ad
"ads_reward_fail" -- Rewarded ad failed to load
"ads_reward_load" -- Rewarded ad loaded successfully
"af_inters" -- AppsFlyer interstitial ad tracking
"af_rewarded" -- AppsFlyer rewarded ad tracking

-- App lifecycle events
"app_clear_data" -- User cleared app data
"app_exception" -- App encountered an error
"app_remove" -- App was uninstalled
"app_update" -- App was updated
"first_open" -- First time app opened
"open_app" -- App opened
"os_update" -- Operating system updated
"remote_config_load_failed" -- Failed to load remote config
"remote_config_load_success" -- Successfully loaded remote config
"screen_view" -- User viewed a screen
"session_start" -- New game session started
"user_engagement" -- User engaged with app

-- Gameplay events
"booster_buy" -- User purchased a booster
"booster_use" -- User used a booster
"lose_level" -- User failed a level
"lucky_spin" -- User spun lucky wheel
"refill_heart" -- User refilled lives/hearts
"revive" -- User revived after dying
"start_level" -- User started a level
-- "start_level_10" -- Started level 10
-- "start_level_15" -- Started level 15  
-- "start_level_20" -- Started level 20
-- "start_level_25" -- Started level 25
-- "start_level_30" -- Started level 30
-- "start_level_5" -- Started level 5
-- "start_level_7" -- Started level 7
"start_level_phase" -- Started a level phase
"win_level" -- User completed a level
"winstreak_claim" -- Claimed winstreak reward
"winstreak_start" -- Started a winstreak

-- Reward/IAP events
"campaign_first_open" -- First open during campaign
"chain_offer_claim" -- Claimed chain offer reward
"daily_chest_claim" -- Claimed daily chest
"daily_login_claim" -- Claimed daily login reward
"daily_task_claim" -- Claimed daily task reward
"firebase_campaign" -- Firebase campaign event
"free_pass_claim" -- Claimed free pass reward
"free_pass_claim_all" -- Claimed all free pass rewards
"gold_pass_claim" -- Claimed gold pass reward
"gold_pass_claim_all" -- Claimed all gold pass rewards
"in_app_purchase" -- Made in-app purchase
"inter_attempt" -- Attempted interaction
"reward_attempt" -- Attempted to claim reward
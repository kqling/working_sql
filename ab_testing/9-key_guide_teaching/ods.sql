SELECT
    date,
    ab_group,
    SUM(finish_guide_users) as finish_guide_users,
    SUM(first_round_end_users) as first_round_end_users,
    SUM(first_round_time_cost) as first_round_time_cost
FROM
    (SELECT
        guide.date,
        guide.ab_group,
        guide.finish_guide_users,
        first.first_round_end_users,
        first.first_round_time_cost
    FROM
        (SELECT
            parse_Date('%Y%m%d',_table_suffix) as date,
            CASE when abtest_tag like '%Mb0%' then 'control' 
                 when abtest_tag like '%Mb1%' then 'test' end as ab_group,
            COUNT(distinct user_pseudo_id) as finish_guide_users
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_ods_action_basicEvents_di_*`,
        UNNEST(event_params) as evt
        WHERE _table_suffix >= '20201002'
        AND app_version >= '001010000000000'
        AND abtest_tag like '%Ix1%'
        AND (abtest_tag like '%Mb0%' or abtest_tag like '%Mb1%')
        AND living_days = 0
        AND event_name in ('src_new_guide','src_guide_update')
        AND evt.key = 'finish'
        GROUP BY 1,2) guide
    LEFT JOIN
        (SELECT
            parse_Date('%Y%m%d',_table_suffix) as date,
            CASE when abtest_tag like '%Mb0%' then 'control' 
                 when abtest_tag like '%Mb1%' then 'test' end as ab_group,
            count(distinct user_pseudo_id) as first_round_end_users,
            SUM(cast(cost.value.string_value as float64)) as first_round_time_cost
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_ods_action_basicEvents_di_*`,
        UNNEST(event_params) as play_count,
        UNNEST(event_params) as cost
        WHERE _table_suffix >= '20201002'
        AND app_version >= '001010000000000'
        AND abtest_tag like '%Ix1%'
        AND (abtest_tag like '%Mb0%' or abtest_tag like '%Mb1%')
        AND living_days = 0
        AND event_name = 'scr_ending'
        AND play_count.key = 'play_count'
        AND play_count.value.string_value = '1'
        AND cost.key = 'true_time_cost' 
        GROUP BY 1,2) first
    ON guide.date = first.date
    AND guide.ab_group = first.ab_group
    UNION ALL
    SELECT
        guide.date,
        guide.ab_group,
        guide.finish_guide_users,
        first.first_round_end_users,
        first.first_round_time_cost
    FROM
        (SELECT
            parse_Date('%Y%m%d',_table_suffix) as date,
            CASE when abtest_tag like '%Aa0%' then 'control' 
                 when abtest_tag like '%Aa1%' then 'test' end as ab_group,
            COUNT(distinct user_pseudo_id) as finish_guide_users
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.fact_ods_action_basicEvents_di_*`,
        UNNEST(event_params) as evt
        WHERE _table_suffix >= '20201002'
        AND app_version >= '001010000000000'
        AND abtest_tag like '%Yv1%'
        AND (abtest_tag like '%Aa0%' or abtest_tag like '%Aa1%')
        AND living_days = 0
        AND event_name in ('src_new_guide','src_guide_update')
        AND evt.key = 'finish'
        GROUP BY 1,2) guide
    LEFT JOIN
        (SELECT
            parse_Date('%Y%m%d',_table_suffix) as date,
            CASE when abtest_tag like '%Aa0%' then 'control' 
                 when abtest_tag like '%Aa1%' then 'test' end as ab_group,
            count(distinct user_pseudo_id) as first_round_end_users,
            SUM(cast(SPLIT(SPLIT(cost.value.string_value,",")[OFFSET(0)],"/")[OFFSET(0)] as float64)) as first_round_time_cost
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.fact_ods_action_basicEvents_di_*`,
        UNNEST(event_params) as play_count,
        UNNEST(event_params) as cost
        WHERE _table_suffix >= '20201002'
        AND app_version >= '001010000000000'
        AND abtest_tag like '%Yv1%'
        AND (abtest_tag like '%Aa0%' or abtest_tag like '%Aa1%')
        AND living_days = 0
        AND event_name = 'scr_ending'
        AND play_count.key = 'play_count'
        AND play_count.value.string_value = '1'
        AND cost.key = 'true_time_cost' 
        GROUP BY 1,2) first
    ON guide.date = first.date
    AND guide.ab_group = first.ab_group)
GROUP BY 1,2
ORDER BY 1,2
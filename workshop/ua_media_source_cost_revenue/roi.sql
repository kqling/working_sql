SELECT
    platform,
    date_trunc(create_date, month) as create_month,
    media_source,
    SUM(CASE when date = create_date then ua_cost else 0 end) as ua_cost,
    SUM(CASE when date <= DATE_ADD(create_date, interval 1 day) then ad_revenue else 0 end) as revenue_1,
    SUM(CASE when date <= DATE_ADD(create_date, interval 3 day) then ad_revenue else 0 end) as revenue_3,
    SUM(CASE when date <=  DATE_ADD(create_date, interval 7 day) then ad_revenue else 0 end) as revenue_7,
    SUM(CASE when date <=  DATE_ADD(create_date, interval 15 day) then ad_revenue else 0 end) as revenue_15,
    SUM(CASE when date <=  DATE_ADD(create_date, interval 30 day) then ad_revenue else 0 end) as revenue_30,
    SUM(CASE when date <=  DATE_ADD(create_date, interval 60 day) then ad_revenue else 0 end) as revenue_60
FROM `blockpuzzle-f21e1.warehouse.campaign_cost_revenue_cohort_di`
WHERE create_date >= '2020-03-01'
AND first_day_country = 'United States'
GROUP BY 1,2,3
ORDER BY 1,2,3
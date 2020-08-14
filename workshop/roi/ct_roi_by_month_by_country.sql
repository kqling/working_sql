create table if not exists `blockpuzzle-f21e1.roi_analytics.xinyao_roi_review_by_country`
options
    (description = '180 roi review by country first attempt from 2019/11 to 2019/12')
as
select
    r.month,
    r.country,
    r.revenue,
    c.cost
from
    (select 
        date_trunc(cast(s1.first_open_date as date),month) as month,
        s1.country,  
        sum(retain * arpu) as revenue
    from 
        (select 
            first_open_date,
            format_date('%Y-%m-%d', date_add(parse_date('%Y-%m-%d', first_open_date), INTERVAL living_days day)) as current_date,
            country,
            living_days,
            sum(retain) as retain
        from `blockpuzzle-f21e1.roi_analytics.daily_retention_android`
        group by 1, 2, 3, 4
        ) s1 
    left join `blockpuzzle-f21e1.roi_analytics.daily_country_arpu_android` s2 
    on s1.current_date = s2.date 
    and s1.country = s2.country
    where s1.first_open_date between '2019-11-01' and '2019-12-31'
    and s1.living_days between 0 and 180
    group by 1,2
    ) r 
LEFT JOIN `blockpuzzle-f21e1.roi_analytics.xinyao_country_code_mapping` mapping
on r.country = mapping.en_name
LEFT JOIN
    (select
        distinct month, country, cost
    from `blockpuzzle-f21e1.roi_analytics.xinyao_roi_ua_cost_201911_to_201912`) c 
ON c.country = mapping.code
AND c.month = r.month
select
    month,
    country,
    revenue,
    cost,
    revenue/cast(cost as float64) as roi
from `blockpuzzle-f21e1.roi_analytics.xinyao_roi_review_by_country` 
where country in ('United States','Japan','Germany')
order by country,month;
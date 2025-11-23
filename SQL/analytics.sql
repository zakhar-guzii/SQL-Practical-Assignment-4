select
    reviews_summary.appid,
    name_from_applist,
    total_reviews
from reviews_summary
join games on reviews_summary.appid = games.appid
order by total_reviews desc
limit 20;


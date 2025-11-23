select reviews_summary.appid,
       name_from_applist,
       total_reviews
from reviews_summary
         join games on reviews_summary.appid = games.appid
order by total_reviews desc limit 20;

select count(games.release_date) as games_released, year (TRY_STRPTIME(games.release_date, '%b %d, %Y')) as release_year
from games
where TRY_STRPTIME(games.release_date, '%b %d, %Y') is not null
group by year (TRY_STRPTIME(games.release_date, '%b %d, %Y'))
order by release_year;

select game_genres.genre_description,
       count(game_genres.appid) as games_count,
       count(case when games.price_currency = 'USD' then 1 end) as games_with_usd_price,
       cast(avg(case when games.price_currency = 'USD' 
                     then games.price_final_cents/100 
                     end) as decimal) as avg_price_usd
from game_genres
join games on game_genres.appid = games.appid
group by game_genres.genre_id, game_genres.genre_description
order by games_count desc;


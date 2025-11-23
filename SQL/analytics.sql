--1
select reviews_summary.appid,
       name_from_applist,
       total_reviews
from reviews_summary
         join games on reviews_summary.appid = games.appid
order by total_reviews desc limit 20;


--2
select count(games.release_date) as games_released, year (TRY_STRPTIME(games.release_date, '%b %d, %Y')) as release_year
from games
where TRY_STRPTIME(games.release_date, '%b %d, %Y') is not null
group by year (TRY_STRPTIME(games.release_date, '%b %d, %Y'))
order by release_year;


--3
select game_genres.genre_description,
       count(game_genres.appid)                                 as games_count,
       count(case when games.price_currency = 'USD' then 1 end) as games_with_usd_price,
       cast(avg(case
                    when games.price_currency = 'USD'
                        then games.price_final_cents / 100
           end) as decimal)                                     as avg_price_usd
from game_genres
         join games on game_genres.appid = games.appid
group by game_genres.genre_id, game_genres.genre_description
order by games_count desc;


--4
select gg.genre_description,
       round(sum(rd.author_playtime_forever) / 60.0, 2) as total_playtime_hours,
       count(distinct rd.author_steamid)                as unique_players,
       round(avg(rd.author_playtime_forever) / 60.0, 2) as avg_playtime_hours_per_review
from reviews_detailed rd
         join game_genres gg on rd.appid = gg.appid
group by gg.genre_description
order by total_playtime_hours desc;


--5
select
    gg.genre_description,
    count(distinct g.appid) as games_count,
    avg(rs.total_positive::FLOAT / nullif(rs.total_reviews, 0)) AS avg_positive_ratio
from game_genres gg
join games g on gg.appid = g.appid
join reviews_summary rs on g.appid = rs.appid
where rs.total_reviews > 0
group by gg.genre_description
having count(distinct g.appid) > 100
order by avg_positive_ratio
LIMIT 10;
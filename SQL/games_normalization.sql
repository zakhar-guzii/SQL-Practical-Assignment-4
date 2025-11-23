DROP TABLE IF EXISTS raw_games;
CREATE TABLE raw_games AS
SELECT *
FROM read_json_auto(
        'https://github.com/vintagedon/steam-dataset-2025/raw/refs/heads/main/data/01_raw/steam_2025_5k-dataset-games_20250831.json.gz',
        maximum_object_size = 268435456
     );


create table stg_games as
select unnest(raw_games.games) as games_json
from raw_games;


select data_type
from information_schema.columns
where table_name = 'stg_games';

DROP TABLE IF EXISTS games;
CREATE TABLE games AS
SELECT g.games_json.appid,
       g.games_json.name_from_applist,
       g.games_json.app_details.success,
       g.games_json.app_details.fetched_at,
       g.games_json.app_details.data.type,
       COALESCE(g.games_json.app_details.data.required_age, 0)                    AS required_age,
       COALESCE(g.games_json.app_details.data.is_free, false)                     AS is_free,
       g.games_json.app_details.data.pc_requirements.minimum                      AS pc_min,
       g.games_json.app_details.data.pc_requirements.recommended                  AS pc_rec,
       g.games_json.app_details.data.mac_requirements.minimum                     AS mac_min,
       g.games_json.app_details.data.mac_requirements.recommended                 AS mac_rec,
       g.games_json.app_details.data.linux_requirements.minimum                   AS linux_min,
       g.games_json.app_details.data.linux_requirements.recommended               AS linux_rec,
       COALESCE(g.games_json.app_details.data.developers[1], 'Unknown')           AS developer,
       COALESCE(g.games_json.app_details.data.publishers[1], 'Unknown')           AS publisher,
       COALESCE(g.games_json.app_details.data.platforms.windows, false)           AS platform_windows,
       COALESCE(g.games_json.app_details.data.platforms.mac, false)               AS platform_mac,
       COALESCE(g.games_json.app_details.data.platforms.linux, false)             AS platform_linux,
       g.games_json.app_details.data.release_date.date                            AS release_date,
       COALESCE(g.games_json.app_details.data.controller_support, 'None')         as controller_support,
       COALESCE(g.games_json.app_details.data.supported_languages, 'Unknown')     as supported_languages,
       COALESCE(g.games_json.app_details.data.price_overview.currency, 'USD')     as price_currency,
       COALESCE(g.games_json.app_details.data.price_overview.initial, 0)          AS price_initial_cents,
       COALESCE(g.games_json.app_details.data.price_overview.final, 0)            AS price_final_cents,
       COALESCE(g.games_json.app_details.data.price_overview.discount_percent, 0) AS discount_percent,
       g.games_json.app_details.data.price_overview.initial_formatted,
       g.games_json.app_details.data.price_overview.final_formatted,
       COALESCE(g.games_json.app_details.data.achievements.total, 0)              AS achievements_total,
       COALESCE(g.games_json.app_details.data.recommendations.total, 0)           AS recommendations_total,
       COALESCE(g.games_json.app_details.data.metacritic.score, 0)                AS metacritic_score,
       COALESCE(array_length(g.games_json.app_details.data.dlc), 0)               AS dlc_count

FROM stg_games g
WHERE g.games_json.app_details.success = true;



create table game_categories as
select g.games_json.appid,
       unnest(g.games_json.app_details.data.categories).id          as category_id,
       unnest(g.games_json.app_details.data.categories).description as category_description
from stg_games g
where g.games_json.app_details.data.categories is not null
  and array_length(g.games_json.app_details.data.categories) > 0
  and g.games_json.app_details.success = true;

drop table game_genres;

create table game_genres as
select g.games_json.appid,
       unnest(g.games_json.app_details.data.genres).id          as genre_id,
       unnest(g.games_json.app_details.data.genres).description as genre_description_original,
       CASE unnest(g.games_json.app_details.data.genres).description
           WHEN 'Инди' THEN 'Indie'
           WHEN 'Indépendant' THEN 'Indie'
           WHEN 'Acción' THEN 'Action'
           WHEN 'Ação' THEN 'Action'
           WHEN 'Aksiyon' THEN 'Action'
           WHEN 'Экшены' THEN 'Action'
           WHEN 'Aventura' THEN 'Adventure'
           WHEN 'Simulação' THEN 'Simulation'
           WHEN 'Simülasyon' THEN 'Simulation'
           WHEN 'Симуляторы' THEN 'Simulation'
           WHEN 'Strateji' THEN 'Strategy'
           WHEN 'Deportes' THEN 'Sports'
           WHEN 'Carreras' THEN 'Racing'
           WHEN 'Multijogador Massivo' THEN 'Massively Multiplayer'
           ELSE unnest(g.games_json.app_details.data.genres).description
           END                                                  as genre_description
from stg_games g
where g.games_json.app_details.data.genres is not null
  and array_length(g.games_json.app_details.data.genres) > 0
  and g.games_json.app_details.success = true;


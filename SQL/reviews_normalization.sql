drop table if exists raw_reviews;
create table raw_reviews as
select *
from read_json_auto(
        'https://github.com/vintagedon/steam-dataset-2025/raw/refs/heads/main/data/01_raw/steam_2025_5k-dataset-reviews_20250901.json.gz',
        maximum_object_size = 268435456);

create table stg_reviews as
select unnest(raw_reviews.reviews) as reviews_json
from raw_reviews;

select data_type
from information_schema.columns
where table_name = 'stg_reviews';

DROP TABLE IF EXISTS reviews_summary;
create table reviews_summary as
select
    r.reviews_json.appid,
    COALESCE(r.reviews_json.review_data.query_summary.num_reviews, 0) as num_reviews,
    COALESCE(r.reviews_json.review_data.query_summary.review_score, 0) as review_score,
    COALESCE(r.reviews_json.review_data.query_summary.review_score_desc, 'No Reviews') AS review_score_desc,
    COALESCE(r.reviews_json.review_data.query_summary.total_positive, 0) as total_positive,
    COALESCE(r.reviews_json.review_data.query_summary.total_negative, 0) as total_negative,
    COALESCE(r.reviews_json.review_data.query_summary.total_reviews, 0) as total_reviews,
from stg_reviews r
where r.reviews_json.review_data.success = 1;

drop table if exists reviews_detailed;
create table reviews_detailed as
select r.reviews_json.appid,
       unnest(r.reviews_json.review_data.reviews).recommendationid as recommendation_id,
       unnest(r.reviews_json.review_data.reviews).language as language,
       to_timestamp(unnest(r.reviews_json.review_data.reviews).timestamp_created) as created_at,
       to_timestamp(unnest(r.reviews_json.review_data.reviews).timestamp_updated) as updated_at,
       coalesce(unnest(r.reviews_json.review_data.reviews).voted_up, false) as is_positive,
       coalesce(unnest(r.reviews_json.review_data.reviews).votes_up, 0) as votes_up,
       coalesce(unnest(r.reviews_json.review_data.reviews).votes_funny, 0) as votes_funny,
       coalesce(unnest(r.reviews_json.review_data.reviews).comment_count, 0) as comment_count,
       coalesce(unnest(r.reviews_json.review_data.reviews).steam_purchase, false) as steam_purchase,
       coalesce(unnest(r.reviews_json.review_data.reviews).received_for_free, false) as received_for_free,
       coalesce(unnest(r.reviews_json.review_data.reviews).written_during_early_access, false) as written_during_early_access,
       coalesce(unnest(r.reviews_json.review_data.reviews).primarily_steam_deck, false) as primarily_steam_deck,
       case 
           when unnest(r.reviews_json.review_data.reviews).timestamp_dev_responded > 0 
           then to_timestamp(unnest(r.reviews_json.review_data.reviews).timestamp_dev_responded)
           else null
       end as dev_responded_at,
       unnest(r.reviews_json.review_data.reviews).developer_response as developer_response,
       unnest(r.reviews_json.review_data.reviews).author.steamid as author_steamid,
       coalesce(unnest(r.reviews_json.review_data.reviews).author.num_games_owned, 0) as author_games_owned,
       coalesce(unnest(r.reviews_json.review_data.reviews).author.num_reviews, 0) as author_num_reviews,
       coalesce(unnest(r.reviews_json.review_data.reviews).author.playtime_forever, 0) as author_playtime_forever,
       coalesce(unnest(r.reviews_json.review_data.reviews).author.playtime_last_two_weeks, 0) as author_playtime_last_two_weeks,
       coalesce(unnest(r.reviews_json.review_data.reviews).author.playtime_at_review, 0) as author_playtime_at_review,
       case 
           when unnest(r.reviews_json.review_data.reviews).author.last_played > 0 
           then to_timestamp(unnest(r.reviews_json.review_data.reviews).author.last_played)
           else null
       end as author_last_played,
       coalesce(unnest(r.reviews_json.review_data.reviews).author.deck_playtime_at_review, 0) as author_deck_playtime_at_review
from stg_reviews r
where r.reviews_json.review_data.success = 1
  and r.reviews_json.review_data.reviews is not null
  and array_length(r.reviews_json.review_data.reviews) > 0;


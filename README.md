# Steam Data ETL & Analytics Pipeline

ETL pipeline and analytics for Steam 2025 dataset using DuckDB and Python.

## Tech Stack

- **DB:** DuckDB 
- **Visualization:** Python 3.x (Pandas, Seaborn, Matplotlib)  

## ETL Process

1. **Ingestion**: Load `.json.gz` using `read_json_auto` → `raw_games`, `raw_reviews`.  
2. **Staging**: `unnest` JSON arrays → `stg_games`, `stg_reviews`.  
3. **Normalization**:  
   - `games`: types, NULL handling, date parsing  
   - `game_genres`, `game_categories`: multi-value attributes, unified names  
   - `reviews_detailed`, `reviews_summary`

## Analytics

- Top Games: top 20 by review count  
- Release Dynamics: games per year  
- Genre Economics: avg price and count per genre  
- User Engagement: total and avg playtime per genre  
- Satisfaction Ratio: genre vs positive review % (sample > 100 games)  

## Visualization

- Barplot: top 15 games  
- Barplot: release timeline  
- Scatterplot: price vs satisfaction (bubble size = genre count)  

## Usage

1. Run SQL scripts in order:  
   `games_normalization.sql` → `reviews_normalization.sql` → `analytics.sql`  

2. Export results to CSV for Python:  

| Query | CSV | Usage |
|-------|-----|-------|
| Top Games | Result_9.csv | Barplot |
| Releases | games_released_integer.csv | Timeline |
| Prices | Result_12.csv | Scatterplot (`df_price`) |
| Playtime | Result_13.csv | Analysis (`df_playtime`) |
| Ratio | Result_14.csv | Scatterplot |

3. Run Python visualization:

```bash
pip install pandas seaborn matplotlib
python visualization.py

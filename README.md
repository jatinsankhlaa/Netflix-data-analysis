# Netflix Data Analysis

End-to-end analysis of a Netflix titles dataset using **MySQL** for data cleaning and querying, and **Power BI** for an interactive dashboard.

## Dashboard Preview

![Netflix Dashboard](dashboard.png)

## Objective

To explore the Netflix catalog and answer business questions about content mix, genres, countries, languages, ratings, and viewer reception (IMDb score and votes).

## Dataset

The cleaned table (`netflix_clean`) contains these fields:

| Column | Description |
|---|---|
| show_id | Unique title ID |
| title | Name of the movie or TV show |
| type | Movie or TV Show |
| genre | Content genre |
| country | Country of origin |
| release_year | Year of release |
| rating | Content rating |
| language | Language of the title |
| duration_minutes | Movie duration |
| seasons | Number of seasons (TV shows) |
| imdb_score | IMDb rating (0-10) |
| votes | Number of IMDb votes |

## Project Workflow

1. **Data validation:** checked row counts, duplicate `show_id` values, missing values by column, and invalid IMDb scores and vote counts
2. **Data cleaning:** trimmed text fields and converted blank country values to NULL, saved as the `netflix_clean` table
3. **SQL analysis:** answered 35 business questions, from basic counts to advanced ranking
4. **Visualization:** built an interactive Power BI dashboard on the cleaned data

## SQL Analysis (35 Queries)

| Level | Concepts | Example questions |
|---|---|---|
| Basic | COUNT, GROUP BY, ORDER BY | Titles per type, top genres, top countries |
| Intermediate | HAVING, subqueries | Genres with average score above 7.5 and at least 100 titles |
| Advanced | CTEs, DENSE_RANK, ROW_NUMBER, correlated subqueries | Top 3 movies per genre, titles above their type's average score |

**Sample query: top 3 highest-rated movies in each genre (including ties)**

```sql
WITH movie_rank AS (
    SELECT title, genre, imdb_score,
           DENSE_RANK() OVER (PARTITION BY genre ORDER BY imdb_score DESC) AS rnk
    FROM netflix_clean
    WHERE type = 'movie'
      AND genre IS NOT NULL
      AND imdb_score IS NOT NULL
)
SELECT title, genre, imdb_score, rnk
FROM movie_rank
WHERE rnk <= 3
ORDER BY genre, rnk;
```

## Power BI Dashboard

- **KPI cards:** total titles (about 3.6K), countries (13), movies, TV shows, average votes, average IMDb score (6.52)
- **Donut chart:** Movies vs TV Shows split
- **Area chart:** movies and TV shows released each year
- **Treemap:** number of titles by country
- **Table:** title, genre, and IMDb score
- **Slicers:** genre filter and year timeline (2000-2024)

## Key Insights

- About 68% of the catalog is Movies and 32% is TV Shows
- The average IMDb score across all titles is 6.52
- The catalog covers titles from 13 countries, with several markets (such as South Korea, India, and the United Kingdom) well represented

## Tools Used

MySQL Workbench | Power BI | SQL (CTEs, window functions, subqueries)

## Repository Files

- `netflix_data_analysis.sql`: data validation, cleaning, and all 35 queries
- `netflixs_dashboard.pbix`: Power BI dashboard file
- `dashboard.png`: dashboard screenshot

## How to Use

1. Load the dataset into MySQL as `netflix_data`
2. Run `netflix_data_analysis.sql` to create `netflix_clean` and execute the queries
3. Open `netflixs_dashboard.pbix` in Power BI Desktop to explore the dashboard

## Author

**Jatin Sankhla**
Aspiring Data Analyst | BCA student, GLA University
Email: jatinsankhla980@gmail.com
LinkedIn: [https://www.linkedin.com/in/jatin-sankhla-073b25441/]

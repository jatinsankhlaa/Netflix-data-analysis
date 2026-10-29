create database netflixs;
use netflixs;

select*from netflix_data;

SELECT *
FROM netflix_data
LIMIT 10;

DESCRIBE netflix_data;

SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT show_id) AS unique_ids
FROM netflix_data;

SELECT
type,
COUNT(*) AS total_records,
    SUM(duration_minutes IS NULL) AS missing_duration,
    SUM(seasons IS NULL) AS missing_seasons
FROM netflix_data
GROUP BY type;

SELECT
    SUM(show_id IS NULL) AS missing_ids,
    SUM(title IS NULL) AS missing_titles,
    SUM(country IS NULL) AS missing_country,
    SUM(imdb_score IS NULL) AS missing_scores,
    SUM(votes IS NULL) AS missing_votes
FROM netflix_data;

SELECT *
FROM netflix_data
WHERE imdb_score < 0
   OR imdb_score > 10
   OR votes < 0;
   
CREATE TABLE netflix_clean AS
SELECT
show_id,
TRIM(title) AS title,
TRIM(type) AS type,
TRIM(genre) AS genre,
NULLIF(TRIM(country), '') AS country,
release_year,
TRIM(rating) AS rating,
TRIM(language) AS language,
duration_minutes,
seasons,
imdb_score,
votes
FROM netflix_data;

-- Q1. Calculate the total number of titles available in each content type.
select type,count(title) as title from netflix_clean
group by type ;

-- Q2. Identify the top 10 genres with the highest number of titles.
select genre , count(title) as title from netflix_clean
group by genre
order by title desc
limit 10;

-- Q3. Find the top 10 countries with the largest number of titles.
select country, count(title) as title from netflix_clean
where country is not null
group by country
order by title desc
limit 10;

-- Q4. Calculate the total number of titles released in each year.
select release_year, count(title) as title from netflix_clean
where release_year is not null
group by release_year
order by title desc;

-- Q5. Find the total number of titles available in each language.
select language, count(title) as title from netflix_clean
where language is not null
group by language
order by title desc;

-- Q6. Calculate the number of titles in each content rating category.
select rating, count(title) as title from netflix_clean
group by rating
order by title desc;

-- Q7. Calculate the average, minimum, and maximum duration of movies.
select type,round(avg(duration_minutes),2) as avg_duration_minutes,
min(duration_minutes) as min_duration_minutes,
max(duration_minutes) as max_duration_minutes from netflix_clean
where type = 'movie';

-- Q8. Find the TV Show with the highest number of seasons.
select title,type,max(seasons) as seasons from netflix_clean
where type='tv show'
group by  title 
limit 1;

-- Q9. Find the 20 highest-rated titles.
select title, type, genre, imdb_score, votes from netflix_clean
order by imdb_score desc , votes desc 
limit 20;

-- Q10. Identify records with missing or invalid data.
select * from netflix_clean
where show_id is null
or title is null
or TRIM(title) = ''
or imdb_score < 0
or imdb_score > 10
or votes < 0;

-- Q11. Find titles whose IMDb score is higher than the overall average IMDb score.
select title,type,imdb_score from netflix_clean
where imdb_score>(select avg(imdb_score) from netflix_clean)
order by imdb_score desc;

-- Q12. Identify genres with an average IMDb score above 7.5 and at least 100 titles.
select genre, round(avg(imdb_score),2) as avg_score,count(title) as title
from netflix_clean 
group by genre
having avg(imdb_score)>7.5 and count(title)>100
order by  avg_score desc;


-- Q13. Find countries with more than 500 titles.
select country,count(title) as title from netflix_clean 
group by country
having count(title)>500 
order by title desc;

-- Q14. Find movies whose duration exceeds the average movie duration.
select type,duration_minutes from netflix_clean 
where type='movie'and 
duration_minutes>(select avg(duration_minutes) from netflix_clean
where type='movie')
order by duration_minutes desc;

-- Q15. Find titles with an IMDb score of at least 8 and above-average votes.
select title,imdb_score,votes from netflix_clean
where imdb_score>=8 and
votes>(select avg(votes) from netflix_clean
where votes is not null)
order by votes desc;

-- Q16. Identify genres whose total votes exceed the average total votes per genre.
select genre,sum(votes) as total_vote from netflix_clean
group by genre
having sum(votes)>(select avg(votes) from (select sum(votes) as votes from netflix_clean
group by genre) as g)
order by total_vote desc;

-- Q17. Find languages whose average IMDb score exceeds the overall average score.
select language, avg(imdb_score) as avg_imdb from netflix_clean 
group by language
having avg(imdb_score) > (select avg(imdb_score) from netflix_clean)
order by avg_imdb;

-- Q18. Compare the average IMDb score of Movies and TV Shows.
select type,count(title) as total_title , round(avg(imdb_score),2) as avg_imdb_score
from netflix_clean
group by type;

-- Q19. Find countries with an average IMDb score above the global average and at least 50 titles.
select country,count(title) as total_title , round(avg(imdb_score),2) as avg_imdb_score
from netflix_clean
where country is not null
group by country
having count(title)>50 and
round(avg(imdb_score),2)>(select avg(imdb_score) from netflix_clean)
order by avg_imdb_score;

--  Q20. Find the top 3 highest-rated movies in each genre, including ties.
with movie_rank as( 
select title, genre ,imdb_score,dense_rank() over(partition by genre order by imdb_score desc) as rnk
from netflix_clean
where type = 'movie'
and genre is not null 
and imdb_score is not null)
select title, genre ,imdb_score, rnk from movie_rank 
where rnk <= 3 
order by genre, rnk;

-- Q21. Rank genres within each country by average IMDb score, using at least 10 titles per country-genre combination.
with genre_stats as (
select country, genre ,avg(imdb_score) as avg_score , count(title) as titles
 from netflix_clean
where genre is not null 
and imdb_score is not null
and country is not null
group by country, genre
having count(title)>=10), ranked as(
select*,dense_rank() 
over(partition by country order by avg_score desc) as rnk 
from genre_stats)
select country , genre, titles ,round(avg_score,2), rnk from ranked
order by  country , rnk;

-- Q22. Find the top 3 highest-rated titles in each language, including ties.
with language_rank as( 
select title, language,type ,imdb_score,dense_rank() over(partition by language order by imdb_score desc) as rnk
from netflix_clean
where genre is not null 
and imdb_score is not null)
select title, language ,imdb_score, rnk from language_rank 
where rnk <= 3 
order by language, rnk;

-- Q23. Rank release years by the number of titles released.

with yearly as (select release_year,count(*) as total_titles
from netflix_clean
where release_year is not null
group by release_year)
select release_year,total_titles,
dense_rank() over (order by total_titles desc) as year_rank
from yearly;

-- Q24. Find the top 10 titles by vote count within each content type.
with title_rank as (
select title,type,votes,
row_number() over(partition by type order by votes desc) as rnk
from netflix_clean
where votes is not null )
select title, type, votes
from title_rank
where rnk<= 10
order by type, rnk;

-- Q25. Count movies and TV shows released each year.
with yearly_data as (
select release_year, type 
from netflix_clean
where release_year is not null)
select release_year, sum(type = 'Movie') as movies,sum(type = 'TV Show') as tv_show 
from yearly_data
group by release_year;

-- Q26. Find titles with an IMDb score higher than the average score of their content type.
select title,type,imdb_score from netflix_clean n
where imdb_score>(select avg(imdb_score) from netflix_clean
where type=n.type);

-- Q27. Find the second-highest distinct IMDb score.
select title , imdb_score
from netflix_clean
where imdb_score =(select max(imdb_score)
from netflix_clean
where imdb_score<(select max(imdb_score)
from netflix_clean));

-- Q28. Find titles with the highest IMDb score in each content type.
select title,type,imdb_score 
from netflix_clean n
where imdb_score=(select max(imdb_score) 
from netflix_clean 
where type=n.type);

-- Q29. Find genres whose average IMDb score is greater than the overall average score.
select genre,round(avg(imdb_score),2) as score
from netflix_clean 
where genre is not null
group by genre
having round(avg(imdb_score),2) >(select avg(imdb_score) from netflix_clean);

-- Q30. Find titles with more votes than the average votes of their content type.
select title, type, votes
from netflix_clean n
where votes > (select avg(votes)
from netflix_clean
where type = n.type);

-- Q31. Find countries that have more titles than the average number of titles per country.
select country, count(title) as total_title
from netflix_clean 
where country is not null
group by country
having count(title)>(select avg(total_title) 
from(select country, count(title) as total_title
from netflix_clean 
where country is not null
group by country) c);

-- Q32. Find titles released after the latest release year of any title rated below 5.
select title, release_year, imdb_score
from netflix_clean
where release_year > (select max(release_year)
from netflix_clean
where imdb_score < 5);

-- Q33. Find titles belonging to genres that have at least 50 titles.
select genre , count(title) as title from netflix_clean 
where genre is not null
group by genre 
having count(title)>= 50;

-- Q34. Find countries whose average IMDb score is higher than the average IMDb score of the United States.
select country,round(avg(imdb_score),2) as imdb_score
from netflix_clean
where country is not null
group by country
having avg(imdb_score)>(select avg(imdb_score) 
from netflix_clean
where country='United States');

-- Q35. Find countries whose average IMDb score is higher than the overall average IMDb score, 
-- and whose total number of titles is greater than the average number of titles per country.
select country,count(title) as total_title,round(avg(imdb_score),2) as avg_imdb_score 
from netflix_clean
where country is not null 
group by country
having avg(imdb_score)>(select avg(imdb_score) from netflix_clean)
and count(title)>(select avg(title) from(select count(title) as title
from netflix_clean 
where country is not null
group by country) c);









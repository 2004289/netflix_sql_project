-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
   show_id VARCHAR(6),
   type    VARCHAR(10),
   title   VARCHAR(150),
   director  VARCHAR(208),
   casts    VARCHAR(1000),
   country VARCHAR(150),
   date_added VARCHAR(50),
   release_year INT,
   rating  VARCHAR(10),
   duration	 VARCHAR(15),
   listed_in VARCHAR(100),
   description VARCHAR(250)
 );
 
SELECT * FROM netflix;

SELECT COUNT (*) AS Total_Content
from netflix;

SELECT 
  DISTINCT type
FROM netflix;

-- counting number of movies and shows
SELECT 
  type,
  COUNT(*) as total_content
FROM netflix
GROUP BY type

--most common rating for movies and tv shows
SELECT
  type,
  rating
FROM

(SELECT
  type,
  rating,
  COUNT(*),
  RANK() OVER(PARTITION BY type ORDER BY COUNT(*)DESC) as ranking
FROM netflix
Group by 1, 2
) as t1
WHERE
  ranking=1

--List all movies released in a specific year
SELECT * from netflix
WHERE
 type = 'Movie'
 AND
 release_year=2020

--top 5 countries with the most content on Netflix
SELECT 
  UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
  COUNT(show_id) as total_content
from netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--Identifying the longest movie

SELECT * FROM netflix
WHERE
  type = 'Movie'
  AND
  duration = (SELECT MAX(duration) FROM netflix)

--Finding content added in the last 5 years

SELECT * FROM netflix
WHERE
  TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--Findings movies\tv shows by director 'Rajiv chilaka'

SELECT * FROM netflix
WHERE director ILIKE 'Rajiv chilaka%'

--List all tv shows with more than 5 seasons

SELECT * FROM netflix
WHERE 
      type = 'TV Show'
      AND
	  SPLIT_PART(duration, ' ', 1)::numeric > 5


--counting the number of items in each genere

SELECT 
     listed_in,
	 show_id,
	 UNNEST(STRING_TO_ARRAY(listed_in, ',')) 
	 FROM netflix

--Finding each year and the average numbers of content release in India on Netflix.
--return top 5 year with highest avg content release:

--total_content = 333/972

SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100
	,2)as avg_content_per_year
FROM netflix
WHERE country = 'India'
Group by 1


--List all the movies that are documentries

SELECT * FROM netflix
WHERE 
   listed_in ILIKE '%documentaries%'

--Finding all content without a director

SELECT * FROM netflix
WHERE
   director IS NULL

--Finding how many movies actor 'salman khan' appeared in the last 10 years

SELECT * FROM netflix
WHERE
  casts ILIKE '%salman Khan%'
  AND
  release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

--Finding the top 10 actors who have appeared in the highest number of movies produced in India

SELECT 
--show_id,
--casts,
UNNEST(STRING_TO_ARRAY(casts, ','))as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--Categorize the content based on the presence of the keywords 'kill' and 'violence' in
the description field. Lable content containing these keywords as 'Bad' and all other
content as 'Good'. count how many items fall into each category

WITH new_table
AS
(
SELECT
*, 
  CASE
  WHEN description ILIKE '%kill%' OR
       description ILIKE '%violence%' THEN 'Bad_content'
	   ELSE 'Good Content'
	  END category
FROM netflix
)
SELECT
   category,
   COUNT(*) as total_content
FROM new_table
GROUP BY 1

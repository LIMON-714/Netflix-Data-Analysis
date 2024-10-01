CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);


SELECT * FROM netflix;
-- toital content count
SELECT COUNT(*) AS total_content
from netflix;

-- see all unique value no double 
SELECT DISTINCT  type
FROM netflix;

-- Count the number of Movies vs TV Shows
SELECT type, count(*) as total_show
FROM netflix
 GROUP BY type;


 -- Find the most common rating for movies and TV shows
SELECT type,rating, COUNT(*) AS count
FROM netflix
GROUP BY type, rating
ORDER BY count DESC;

WITH RankedRatings AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS count,
        ROW_NUMBER() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
    FROM netflix
    GROUP BY type, rating
)
SELECT 
    type,
    rating,
    count
FROM RankedRatings
WHERE rank = 1;
--List all movies title Dorasaani (e.g., Dorasaani)
SELECT type, title
FROM netflix
where type ='Movie' AND title = 'Dorasaani';

--Find the top 5 countries with the most content on Netflix
SELECT TOP 5 country, COUNT(*) AS total_content
FROM (
    SELECT 
        TRIM(value) AS country
    FROM netflix
    CROSS APPLY STRING_SPLIT(country, ',')
) AS t1
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC;


-- Identify the longest movie
SELECT TOP 1 
    title,
    duration
FROM netflix
WHERE type = 'Movie'
AND CHARINDEX(' ', duration) > 0  -- Ensure there is a space in the duration
AND ISNUMERIC(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1)) = 1  -- Only numeric durations
ORDER BY CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) DESC;

--Find content added in the last 5 years
SELECT date_added
FROM netflix
WHERE TRY_CONVERT(DATE, date_added, 100) IS NULL
AND date_added IS NOT NULL;  -- To exclude NULLs

SELECT TOP 10 *
FROM netflix
WHERE TRY_CONVERT(DATE, date_added, 100) >= DATEADD(YEAR, -5, GETDATE());

--Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix
CROSS APPLY STRING_SPLIT(director, ',') AS director_split
WHERE TRIM(director_split.value) = 'Rajiv Chilaka';

-- List all TV shows with more than 5 seasons
SELECT *,
       LEFT(duration, CHARINDEX(' ', duration) - 1) AS numeric_duration,
       TRY_CONVERT(INT, LEFT(duration, CHARINDEX(' ', duration) - 1)) AS converted_duration
FROM netflix
WHERE 
    type = 'TV Show'
    AND 
    CHARINDEX(' ', duration) > 0;  

	--Count the number of content items in each genre
;WITH GenreCounts AS (
    SELECT 
        TRIM(value) AS genre,  -- Trim any whitespace from genre names
        COUNT(*) AS total_content
    FROM (
        SELECT 
            value
        FROM netflix
        CROSS APPLY STRING_SPLIT(listed_in, ',') AS value  -- Split the genres by comma
    ) AS split_genres
    GROUP BY TRIM(value)  -- Group by trimmed genre names
)
SELECT 
    genre,
    total_content
FROM GenreCounts
ORDER BY total_content DESC;  -- Order by count in descending order


--Find each year and the average numbers of content release by India on netflix. return top 5 year with highest avg content release !
SELECT 
    release_year,
    COUNT(*) * 1.0 / COUNT(DISTINCT release_year) AS avg_content_release  -- Calculate average content releases
FROM netflix
WHERE country = 'India'  
GROUP BY release_year  
ORDER BY avg_content_release DESC  
OFFSET 0 ROWS  
FETCH NEXT 5 ROWS ONLY; 

--List all movies that are documentaries
SELECT *
FROM netflix
WHERE 
    type = 'Movie'  -- Filter for movies
    AND listed_in LIKE '%Documentary%'; 

--Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL

--Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT COUNT(*) AS total_movies
FROM netflix
WHERE 
    casts LIKE '%Salman Khan%'  
    AND release_year >= YEAR(GETDATE()) - 10;
--Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
    TRIM(value) AS actor,  -- Use TRIM to remove any leading/trailing spaces
    COUNT(*) AS total_appearances
FROM 
    netflix
CROSS APPLY 
    STRING_SPLIT(casts, ',')  
WHERE 
    country = 'India'  
GROUP BY 
    TRIM(value)  
ORDER BY 
    total_appearances DESC  
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY; 

--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.


SELECT 
    CASE 
        WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS content_category,
    COUNT(*) AS total_items
FROM 
    netflix
GROUP BY 
    CASE 
        WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END;















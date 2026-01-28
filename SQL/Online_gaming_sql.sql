/*
Questions  

1) Find distinct game genres.
2) Get average playtime per player.
3) Show top 10 players with the highest playtime.
4) Which location has the highest average playtime?
5) Average PlayerLevel per GameGenre.
6) Gender-wise average playtime and session duration.
7) Most popular GameGenre by player count
8) Rank players by PlayTimeHours
9) Which players spend more time but unlock fewer achievements.
10) Get players whose playtime is above the global average.
11) Find each player’s playtime compared to the average playtime in their genre.
12) Find players who are in the top 10% of purchases.
13) Categorize players into “Low”, “Medium”, “High” engagement based on PlayTimeHours.
14)Top 3 genre in every location

*/



#Distint Game Genres
SELECT DISTINCT(GameGenre) 
FROM online_gaming_dataset;

#Average Playtime Per player
SELECT AVG(PlayTimeHours) as Average_playtime
FROM online_gaming_dataset;

#Top Players With highest Playtime
SELECT PlayerID, PlayTimeHours
FROM online_gaming_dataset
ORDER BY PlayTimeHours DESC
LIMIT 10;

#Location Has the highest average playtime
SELECT Location, Avg(PlayTimeHours) as Avg_Playtime
FROM online_gaming_dataset
GROUP BY Location
ORDER BY Avg_Playtime DESC
LIMIT 1;

#Average PlayLevel Per Genre
SELECT GameGenre, AVG(PlayerLevel) as AVG_playlevel
FROM online_gaming_dataset
GROUP BY GameGenre;

#Gender-wise average playtime and session duration.
SELECT Gender, AVG(PlayTimeHours) as AVg_PlayTime, AVG(AvgSessionDurationMinutes) as Avg_session
FROM online_Gaming_dataset
GROUP BY Gender;

#Popular GameGenre by playerCount
SELECT GameGenre, Count(PlayerID)as Num_of_Player
FROM online_gaming_dataset
GROUP By GameGenre
ORDER BY Num_of_Player DESC
LIMIT 1;

#Rank players by PlayTimeHours
SELECT PlayerID, PlayTimeHours, 
RANK() OVER(ORDER BY PlayTimeHours DESC) as Rank_playtime
FROM online_gaming_dataset;

#Which players spend more time but unlock fewer achievements
SELECT PlayerID, PLayTimeHours, AchievementsUnlocked
FROM online_gaming_dataset
WHERE PlayTimeHours > (SELECT Avg(PlayTimeHours) FROM online_gaming_dataset)
AND AchievementsUnlocked < (SELECT Avg(AchievementsUnlocked) FROM online_gaming_dataset);

#players whose playtime is above the global average
WITH Avg_playtime as (
	SELECT AVG(PlayTimeHours) as Global_avg
    FROM online_gaming_dataset
)
SELECT PlayerId, PlayTimeHours
FROM online_gaming_dataset, Avg_playtime
WHERE PlayTimeHours > Global_avg;

#player’s playtime compared to the average playtime in their genre.
SELECT PlayerID, GameGenre, PlayTimeHours,
AVG(PlayTimeHours) OVER (PARTITION BY GameGenre) as avg_genre_playtime
FROM online_gaming_dataset;

 #players who are in the top 10% of purchases
 SELECT PlayerID, InGamePurchases
FROM (
  SELECT
    PlayerID,
    InGamePurchases,
    CUME_DIST() OVER (ORDER BY InGamePurchases) AS cume
  FROM online_gaming_dataset
) t
WHERE cume >= 0.9;



#Categorize players into “Low”, “Medium”, “High” engagement based on PlayTimeHours.
SELECT PlayerID, PlayTimeHours,
	CASE 
		WHEN PlayTimeHours < 10 THEN 'Low'
        WHEN PlayTimeHours BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'High'
	END as PlayTimeCategory
FROM online_gaming_dataset;

# Top 3 genres per location
SELECT Location, GameGenre, Player_count
FROM (
	SELECT Location, GameGenre, Count(*) as player_count, 
    RANK() OVER(PARTITION BY Location ORDER BY Count(*) DESC) as Genre_rank
    FROM online_gaming_dataset
    Group By Location, GameGenre
) ranked
WHERE Genre_rank <= 3;

#Detecting Whales (High Purchase , low PlayTime)
SELECT PlayerID, PlayTimeHours, InGamePurchases
FROM online_gaming_dataset
WHERE InGamePurchases > (SElECT Avg(InGamePurchases)*3 FROM online_gaming_dataset)
AND PlayTimeHours < (SELECT Avg(PlayTimeHours) from online_gaming_dataset);

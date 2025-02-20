USE MessiPortfolioProject;

--Overview of the dataset
SELECT * 
FROM MessiPortfolioProject.dbo.MessiGoals

--Total goals
SELECT COUNT(*) as total_goals
FROM MessiPortfolioProject.dbo.MessiGoals

--Goals by year
SELECT YEAR([date]) AS [year], COUNT(*) AS total_goals
FROM MessiPortfolioProject.dbo.MessiGoals
GROUP BY YEAR(date)
ORDER BY YEAR(date);

--Ranking Messi's best years by goals
WITH MessiBestYears AS
(
	SELECT YEAR([date]) AS [year], COUNT(*) AS total_goals
	FROM MessiPortfolioProject.dbo.MessiGoals
	GROUP BY YEAR(date)
)
SELECT DENSE_RANK() OVER(ORDER BY total_goals desc) [Rank], [year], [total_goals]
FROM MessiBestYears;

--MAX Yearly Goals
WITH MaxYearlyGoals AS
(
	SELECT YEAR([date]) AS [year], COUNT(*) AS total_goals
	FROM MessiPortfolioProject.dbo.MessiGoals
	GROUP BY YEAR(date)
)
SELECT TOP 1 [year], total_goals AS max_yearly_goals
FROM MaxYearlyGoals
ORDER BY total_goals DESC;

--MIN Yearly Goals
WITH MinYearlyGoals AS
(
	SELECT YEAR([date]) AS [year], COUNT(*) AS total_goals
	FROM MessiPortfolioProject.dbo.MessiGoals
	GROUP BY YEAR(date)
)
SELECT TOP 1 [year], total_goals AS min_yearly_goals
FROM MinYearlyGoals
ORDER BY total_goals ASC


--Goals by year, month
SELECT YEAR([date]) AS [year], MONTH([date]) AS [month], COUNT(*) AS total_goals
FROM MessiPortfolioProject.dbo.MessiGoals
GROUP BY YEAR(date), MONTH(date)
ORDER BY YEAR(date), MONTH(date)

--Goals by year, month, day
SELECT YEAR([date]) AS [year], MONTH([date]) AS [month], DAY([date]) AS [day],
	COUNT(*) AS total_goals
FROM MessiPortfolioProject.dbo.MessiGoals
GROUP BY YEAR(date), MONTH(date), DAY([date])
ORDER BY YEAR(date), MONTH(date), DAY([date])

--Average yearly goals
SELECT (CAST(COUNT(*) AS FLOAT)/COUNT(DISTINCT YEAR([date]))) AS average_yearly_goals
FROM MessiPortfolioProject.dbo.MessiGoals


--Average monthly goals
SELECT (COUNT(*)/COUNT(DISTINCT YEAR([date])))/12.0 AS average_monthly_goals
FROM MessiPortfolioProject.dbo.MessiGoals

--Average weekly goals
SELECT ROUND((COUNT(*)/COUNT(DISTINCT YEAR([date])))/52.0, 2) AS average_weekly_goals
FROM MessiPortfolioProject.dbo.MessiGoals


--Total goals by type
SELECT [type], COUNT(*) AS total_goals
FROM MessiPortfolioProject.dbo.MessiGoals
GROUP BY [type]
ORDER BY total_goals DESC

--Weak-Foot Goals
SELECT [type], COUNT(*) AS total_goals
FROM MessiPortfolioProject.dbo.MessiGoals
WHERE type = 'Left-footed shot'
GROUP BY [type]

--Free-Kick Goals
SELECT [type], COUNT(*) AS total_goals
FROM MessiPortfolioProject.dbo.MessiGoals
WHERE type = 'Direct free kick'
GROUP BY [type]

--Solo Goals
SELECT [type], COUNT(*) AS total_goals
FROM MessiPortfolioProject.dbo.MessiGoals
WHERE type = 'Solo run'
GROUP BY [type]


--Penalty Goals
SELECT [type], COUNT(*) AS total_goals
FROM MessiPortfolioProject.dbo.MessiGoals
WHERE type = 'Penalty'
GROUP BY [type]

--Total goals by competition 
SELECT competition, COUNT(*) AS total_goals
FROM MessiPortfolioProject.dbo.MessiGoals
GROUP BY competition
ORDER BY total_goals DESC

GO
--Total different games scored
DECLARE @total_games_scored INT = (SELECT COUNT(DISTINCT CAST([date] AS DATE)) FROM MessiPortfolioProject.dbo.MessiGoals);
SELECT @total_games_scored AS total_games_scored;

--Percentage of games won when CR7 scored
WITH percentage_won_when_scored AS
(
	SELECT COUNT(DISTINCT CAST([date] AS DATE)) AS games_won_when_scored
	FROM MessiPortfolioProject.dbo.MessiGoals
	WHERE CAST(team_score AS INT) > CAST(opponent_score AS INT)
)
SELECT ROUND((CAST(games_won_when_scored AS FLOAT)/@total_games_scored), 2) * 100 AS percentage_won_when_scored
FROM percentage_won_when_scored


--Average minute Messi scored in regular time.
SELECT ROUND(AVG(CAST([minute] AS FLOAT)), 2) AS average_goal_minute_rt
FROM MessiPortfolioProject.dbo.MessiGoals
WHERE [minute] NOT LIKE '%+%'

--Average minute Messi scored in stoppage time.
SELECT CAST(AVG(CAST(SUBSTRING([minute], 4,1) AS FLOAT)) AS DECIMAL(10, 2)) AS average_goal_minute_st
FROM MessiPortfolioProject.dbo.MessiGoals
WHERE [minute] LIKE '%+%';

--Calculates percentage of games scored in regular time vs stoppage time.
WITH RegularVsStoppage AS
(
	SELECT
		CASE
			WHEN [minute] LIKE '%+%' THEN 'Yes'
			WHEN [minute] NOT LIKE '%+%' THEN 'No'
		END AS 'is_stoppage'
	FROM MessiPortfolioProject.dbo.MessiGoals
)
SELECT 
	ROUND((SELECT COUNT(*) FROM RegularVsStoppage WHERE [is_stoppage] = 'Yes')/(CAST(COUNT(*) AS FLOAT)) * 100, 2) AS percent_stoppage,
	ROUND((SELECT COUNT(*) FROM RegularVsStoppage WHERE [is_stoppage] = 'No')/(CAST(COUNT(*) AS FLOAT)) * 100, 2) AS percent_regular
FROM RegularVsStoppage

--Percentage of goals scored in knock-out rounds.
SELECT ROUND(CAST(COUNT(*) AS FLOAT)/ (SELECT COUNT(*) FROM MessiPortfolioProject.dbo.MessiGoals), 2) * 100 AS percent_knockout
FROM MessiPortfolioProject.dbo.MessiGoals
WHERE TRY_CAST([matchday] AS INT) IS NULL
AND	[matchday] <> 'Group Stage'

--Main assister to CR7
SELECT goal_assist AS Assister, COUNT(*) AS no_assists
FROM MessiPortfolioProject.dbo.MessiGoals
GROUP BY goal_assist
ORDER BY no_assists DESC;

--Main assister percentage
WITH MainAssisterPercentage AS
(
	SELECT TOP 1 goal_assist AS assister, COUNT(*) AS no_assists
	FROM MessiPortfolioProject.dbo.MessiGoals
	WHERE goal_assist <> 'None'
	GROUP BY goal_assist
	ORDER BY no_assists DESC

) 
SELECT assister, CAST(no_assists AS FLOAT)/(SELECT COUNT(*) FROM MessiPortfolioProject.dbo.MessiGoals) * 100 AS assist_percentage
FROM MainAssisterPercentage

--CR7 goals per match
SELECT CAST([date] as DATE) [match_date], COUNT(*) [no_goals]
FROM MessiPortfolioProject.dbo.MessiGoals
GROUP BY CAST([date] as DATE)
ORDER BY CAST([date] as DATE) ASC

--CR7 not assisted goals
DECLARE @not_assisted_goals INT
=
(
	SELECT COUNT(*) AS no_assists
	FROM MessiPortfolioProject.dbo.MessiGoals
	WHERE goal_assist = 'None'
	GROUP BY goal_assist
)

SELECT @not_assisted_goals AS not_assisted_goals

--CR7 not assisted goals (excluding penalties)
DECLARE @penalty_goals INT
=
(
	SELECT COUNT(*) AS total_goals
	FROM MessiPortfolioProject.dbo.MessiGoals
	WHERE type = 'Penalty'
	GROUP BY [type]
)

SELECT @not_assisted_goals - @penalty_goals not_assisted_goals_exc_pens
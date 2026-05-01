-- START POSTGRESQL SCRIPT
-- Database: Airline_Dataset

########################################################################
-- DATABASE DESIGN
########################################################################

-- Create table
DROP TABLE IF EXISTS airline_data_tb;

CREATE TABLE IF NOT EXISTS airline_data_tb (
passenger_id VARCHAR(50) PRIMARY KEY,
first_name VARCHAR(100),
last_name VARCHAR(100),	
gender VARCHAR(10),
age SMALLINT,
nationality VARCHAR(100),
airport_name VARCHAR(100),
airport_country_code VARCHAR(10),
country_name VARCHAR(100),
airport_continent VARCHAR(100),
continents VARCHAR(100),
departure_date VARCHAR(100),
arrival_airport	VARCHAR(100),
pilot_name VARCHAR(100),
flight_status VARCHAR(50)
);


-- Set datestyle to read date column in the format month-day-year (based on entries in the dataset)
SET datestyle = 'ISO, MDY';


-- Import airline dataset into table
COPY airline_data_tb (
passenger_id,
first_name,
last_name,	
gender,
age,
nationality,
airport_name,
airport_country_code,
country_name,
airport_continent,
continents,
departure_date,
arrival_airport,
pilot_name,
flight_status
)
FROM 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\input_files\Airline_Dataset_v2.csv'
DELIMITER ','
CSV HEADER;


-- Count records (98,619)
SELECT COUNT(*)
FROM
airline_data_tb;


-- Preview table structure
SELECT *
FROM
airline_data_tb;

########################################################################
-- DATA CLEANING
########################################################################

START TRANSACTION;

SELECT *
FROM airline_data_tb
WHERE passenger_id IS NULL
OR first_name IS NULL
OR last_name IS NULL	
OR gender IS NULL
OR nationality IS NULL
OR airport_name IS NULL
OR airport_country_code IS NULL
OR country_name IS NULL
OR airport_continent IS NULL
OR continents IS NULL
OR arrival_airport IS NULL
OR pilot_name IS NULL
OR flight_status IS NULL
;


-- Check for inconsistencies in the gender column
SELECT 
	DISTINCT gender, flight_status
FROM airline_data_tb;


-- Check for inconsistencies in flight status
SELECT 
	DISTINCT flight_status
FROM airline_data_tb;


-- Check for invalid age
SELECT 
	MIN(age) AS min_age,
	MIN(departure_date) AS min_departure_date,
	MAX(departure_date) AS max_departure_date
FROM airline_data_tb;


-- Check for invalid entries in the 'arrival airport' column
SELECT DISTINCT arrival_airport,
COUNT (*) AS flight_count
FROM airline_data_tb
GROUP BY arrival_airport
ORDER BY flight_count DESC;
/*
An airport code of '0' seems to be an error
*/


-- Delete records with invalid arrival_airport code
DELETE
FROM airline_data_tb
WHERE arrival_airport = '0';


##########################################################################
-- HYPOTHESIS FORMULATION AND DATA ANALYSIS
##########################################################################


-- Preview table structure
SELECT *
FROM
airline_data_tb
LIMIT 10;


-- 1. Airports with the most travels
SELECT
	CONCAT(airport_name,', ',country_name) AS airport_fullname,
	COUNT(*) AS total_passenger_flights
FROM airline_data_tb
GROUP BY airport_fullname
ORDER BY total_passenger_flights DESC
LIMIT 50;
/*
Böblingen Flugfeld airport, Germany was the most frequently travelled airport (36 passenger flights).
This airport may require additional flights or larger aircraft to cater to the rising demand and
increase revenue. They may also require more staff and improved processes to manage potential traffic
*/



-- 2. Least travelled airports
SELECT
	CONCAT(airport_name,', ',country_name) AS airport_fullname,
	COUNT(*) AS total_passenger_flights
FROM airline_data_tb
GROUP BY airport_fullname
ORDER BY total_passenger_flights
LIMIT 20;
/*
Hiroshima Airport, Japan and Falcon State Airport, United States each had
the least flights (1 flight). This suggests a low demand for air travel in these regions
and a preference for more efficient alternative means of transportation e.g. railway.
The geographical location and accessibility may also contribute to the low patronage.
Strategies should be implemented to improve operational efficiency in these airports, or 
if necessary, resources may need to be reallocated to high-demand airports.
*/



-- 3. Age brackets with the most travels
SELECT
	COUNT(CASE WHEN age < 20 THEN 1 END) AS teenagers,
	COUNT(CASE WHEN age BETWEEN 20 AND 33 THEN 1 END) AS young_adults,
	COUNT(CASE WHEN age BETWEEN 34 AND 59 THEN 1 END) AS Middle_aged,
	COUNT(CASE WHEN age >= 60 THEN 1 END) AS elderly
FROM airline_data_tb;
/*
Elderly passengers (60 yrs and above) made the most travels (33,592). While young adults (20 - 33 yrs) 
made the least (15,292).
The elderly passengers majorly comprise people approaching retirement or even retired. 
They tend to have more savings and fewer job commitments. Hence may therefore make more holiday trips.

Marketing and promotions should be targeted appropriately. In-flight experiences should be tailored 
to meet the preferences of the target demographics, improving customer satisfaction.
It might be worth implementing bonuses and loyalty packages for this age bracket to retain them.

The 'young adults' may comprise mostly working-class individuals or university students.
This category of individuals invests more time at their jobs and studies/research, leaving less time for
frequent trips. Although this age bracket made the least trips according to our data, implementing 
student bonuses (especially during holidays) or business incentives may encourage more travel.
*/



-- 4. Continents with the most outbound flight
SELECT
	continents,
	COUNT(CASE WHEN age < 20 THEN 1 END) AS teenagers,
	COUNT(CASE WHEN age BETWEEN 20 AND 33 THEN 1 END) AS young_adults,
	COUNT(CASE WHEN age BETWEEN 34 AND 59 THEN 1 END) AS Middle_aged,
	COUNT(CASE WHEN age >= 60 THEN 1 END) AS elderly,
	COUNT(*) AS total_passenger_flights
FROM airline_data_tb
GROUP BY continents
ORDER BY total_passenger_flights DESC;
/*
Elderly passengers (50 years and above) made the most travels across all continents.
Conversely, young adults (20 - 33 years) made the least number of trips across all continents.

The highest number of trips were made from North American airports, and 
the least number of flights from South American airports. 
Several reasons may be responsible for this: One of which is a high demand for international
travel for business and leisure. In addition, a well-established and developed airline 
infrastructure would encourage frequent trips. More so, North America appears to have a larger
number of middle-class people with the financial means to travel internationally

Furthermore, many North Americans appear to have family ties abroad, possibly explaining the
frequent international travel. Strategies (e.g., streamlined boarding) should be developed to 
improve services here, to enhance passenger experience. Flight prices may need to be reviewed 
downwards in the South America region, and incentives implemented to encourage sales.
*/



-- 5. Nationalities with the most travels
SELECT
	nationality,
	COUNT(*) AS total_passenger_flights
FROM airline_data_tb
GROUP BY nationality
ORDER BY total_passenger_flights DESC
LIMIT 50;
/*
Chinese passengers made the most travels (18,160). Although previous query showed that the second-highest
number of out-bound flights was recorded in Asia, the high number of Chinese making international trips
highlights the need to provide more aeroplanes and improve flight schedules for better customer satisfaction.
Most aspects of the flight should be personalised for better customer experience. For example, a variety of Chinese
foods should be on the flight's menu; pamphlets can have Chinese translations too; a collection of Chinese 
movies should be available to watch aboard, etc.
Targeted marketing and promotions should also be implemented to encourage more flights by Chinese.  
*/



-- 6. Number of flights delayed, cancelled and on-time
SELECT 
	flight_status,
	COUNT(*) AS num_of_flights
FROM airline_data_tb
GROUP BY flight_status
ORDER BY num_of_flights DESC;
/*
Data showed the airlines had more flight cancellations (32,659 cancelled flights) compared to 
flights that were on time (32,559 flights on schedule) or delayed (32,528 delayed flights). 
The airline management should aim to improve pilot punctuality and flight compliance with schedule.
Also, management should aim to achieve a significant decline in the number of flights cancelled/delayed 
for better customer satisfaction. 
*/


-- 7. Seasons with the most delayed or cancelled flights
SELECT
	CASE
		WHEN EXTRACT (MONTH FROM departure_date) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT (MONTH FROM departure_date) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT (MONTH FROM departure_date) IN (6, 7, 8) THEN 'Summer'
        WHEN EXTRACT (MONTH FROM departure_date) IN (9, 10, 11) THEN 'Autumn'
	END AS departure_season,
COUNT(*) AS total_passenger_flights,
COUNT(CASE WHEN flight_status LIKE '%Delayed%' THEN 1 END) AS delayed_flights,
COUNT(CASE WHEN flight_status LIKE '%Cancelled%' THEN 1 END) AS cancelled_flights
FROM airline_data_tb
GROUP BY departure_season
ORDER BY total_passenger_flights DESC;
/*
The highest number of flights were made in Summer (24,902), and the least in Winter (23,781)
Throughout the year, the most flight delays (8,282) were observed in the Spring (Mar-May),
and the least delays (7,941) in Winter (Dec - Feb).

The highest number of flight cancellations (8,352) were observed in the Summer (June - Aug),
and the least cancellations (7,940) in Winter (Dec - Feb). High cancellations in the Summer 
may be due to staff shortages during this period, as staff tend to go on holidays in the Summer.

Staffing levels, marketing, and operational resources should be adjusted to meet the demand in Summer. 
Also, flight schedules may need to be adjusted in Summer (peak season) to optimise seat availability.

Promotions or discounts may need to be rolled out to help fill seats in Winter.
In addition, holiday or seasonal promotions should be offered (targeted by region) 
such as flights to popular destinations during specific holidays.
*/



-- 8. Arrival airport or destinations with the most visits in Summer
SELECT
	arrival_airport,
	COUNT(*) AS summer_flights
FROM airline_data_tb
WHERE EXTRACT (MONTH FROM departure_date) IN (6, 7, 8)
GROUP BY arrival_airport
ORDER BY summer_flights DESC
LIMIT 50;
/*
airport KEZ and BNZ had the most visits during summer (11 flights), suggesting that these locations
might be top choices for the Summer holidays. 

Seasonal discounts and bonuses should be offered 
to customers travelling to these airports, especially during the Summer holidays, to encourage more trips.
*/



-- 9. Airports with the most delayed flights
SELECT
	airport_name,
	country_name,
	COUNT (CASE WHEN flight_status LIKE '%Delayed%' THEN 1 END) AS delayed_flights,
	COUNT(*) AS total_passenger_flights
FROM airline_data_tb
GROUP BY country_name, airport_name
ORDER BY delayed_flights DESC, total_passenger_flights
LIMIT 30;
/*
Visby Airport, Sweden experienced the most flight delays (13 out of 21 flights).
This high frequency of delays suggests that this airport may generate a lot of negative customer reviews 
and complaints. Strategies (e.g., streamlined boarding) should be developed to improve services here, 
to enhance passenger experience.
In addition, communication strategies should be implemented/improved for potential delay-prone flights 
to proactively inform passengers.
*/



-- 10. Airports with the most cancelled flights
SELECT
	airport_name,
	country_name,
	COUNT (CASE WHEN flight_status LIKE '%Cancelled%' THEN 1 END) AS cancelled_flights,
	COUNT(*) AS total_passenger_flights
FROM airline_data_tb
GROUP BY country_name, airport_name
ORDER BY cancelled_flights DESC, total_passenger_flights
LIMIT 30;
/*
The highest (13) flight cancellations were experienced in the following airports:
- Yangzhou Taizhou Airport in China (13 cancellations out of 27 passenger flights)
- Mae Hong Son Airport in Thailand (13 cancellations out of 29 passenger flights)
- Böblingen Flugfeld Airport in Germany (13 cancellations out of 36 passenger flights)

Although it is not clear if these cancellations were initiated by the airport or if they were 
customer-initiated, the high cancellation rates suggest that this airport may also 
generate a lot of negative customer reviews and complaints.
Strategies should be developed to improve services here, to enhance passenger experience.
*/



-- 11. Pilots with the most delayed flights
SELECT
	pilot_name,
	COUNT (*) AS num_of_flights,
	COUNT (CASE WHEN flight_status LIKE '%Delayed%' THEN 1 END) AS delayed_flights
FROM airline_data_tb
GROUP BY pilot_name
ORDER BY num_of_flights DESC, delayed_flights DESC
LIMIT 50;
/*
Ethan Desbrow and Demetris Atherley both had the highest number of delayed flights. 
All the flights they piloted were delayed. While several factors might be responsible for this,
their performance suggests they may require extra training or support to improve performance.
*/



-- 12. Top performing 20 pilots with the most 'on-schedule' flights
SELECT
	pilot_name,
	COUNT (*) AS num_of_passengers,
	COUNT (CASE WHEN flight_status LIKE '%Time%' THEN 1 END) AS flights_on_time
FROM airline_data_tb
GROUP BY pilot_name
ORDER BY num_of_passengers DESC, flights_on_time DESC
LIMIT 20;
/*
Pilot Janela Eyres was the best-performing pilot, with all (2) flights on schedule. 
This pilot should be given some incentive in the form of a bonus or pay rise, to encourage such performance
*/



-- Exporting to CSV
COPY
	(
	SELECT
		COUNT(CASE WHEN age < 20 THEN 1 END) AS teenagers,
		COUNT(CASE WHEN age BETWEEN 20 AND 33 THEN 1 END) AS young_adults,
		COUNT(CASE WHEN age BETWEEN 34 AND 59 THEN 1 END) AS Middle_aged,
		COUNT(CASE WHEN age >= 60 THEN 1 END) AS elderly
	FROM airline_data_tb
	)
TO 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\output_files\airline_age_demograph.csv'
WITH CSV HEADER;

-- ROLLBACK;

-- COMMIT;
-- Create a database titled as City Trains
create database city_trains;
--Activate this dataset
use city_trains;
--General overview of dataset
select*from air_quality;
select*from bus_routes;
select*from commuter_patterns;
select*from road_segments;
select*from traffic_flow;
select*from weather;

-------------------------------------------------------------------------------------------------------
--------------------------------------- -Air Quality: KPI's--------------------------------------------
--------------------------------------------------------------------------------------------------------
-- 1: Average Pollution Level:
select avg(pollution_level) as Avg_pollution_rate from air_quality;

-- 2: Maximum Pollution Level:
select max(pollution_level)as Max_Pollution_level from air_quality;

-- 3: Minimum Pollution Level: 
select min(pollution_level) as Min_Pollution_level from air_quality;

-- 4: Number of Nodes Exceeding Safe Pollution Levels:
-- The safe threshold for pollution levels is 35 µg/m³.
select count(node) as Exceeding_limit from air_quality 
where pollution_level > '35';

-- 5: Standard Deviation of Pollution Levels:
select STDEV(pollution_level) as stadv_value from air_quality;

-------------------------------------------------------------------------------------------------------
------------------------------------------Bus Routes: KPI's--------------------------------------------
-------------------------------------------------------------------------------------------------------

-- 1: Average Route Capacity: 
select avg(capacity) as Avg_Capacity from bus_routes;

-- 2: Average Fare: 
select avg(fare) as Avg_fare from bus_routes;

-- 3: Route with Maximum Stops:
select max(stops) as Max_Stopes from bus_routes;

-- 4: Route with Minimum Fare:
select min(stops) as Min_Stopes from bus_routes;

-- 5: Highest Capacity Route: 
select top 1 route_id, capacity
from bus_routes
order by capacity desc;


-------------------------------------------------------------------------------------------------------
------------------------------------------Customer Patterns: KPI's-------------------------------------
-------------------------------------------------------------------------------------------------------
select*from commuter_patterns; 

-- 1: Most Popular Mode of Transport: 
select top 1 count(mode_of_transport) as Popular_mode, mode_of_transport from commuter_patterns
group by mode_of_transport
order by count(mode_of_transport) desc;

-- 2: Average Commute Time:  (We do not have commute time in our datatable so we 
                       -- used CTE to find commute time and than solve actual question)
with CommuteTime as (
    select
        origin,
        destination,
        mode_of_transport,
        departure_time,
        arrival_time,
        datediff(MINUTE, departure_time, arrival_time) as commute_time_minutes
    from
        commuter_patterns
)
select
    avg(commute_time_minutes) as avg_commute_time_minutes
from
    CommuteTime;


-- 3: Peak Commute Times:
with DepartureHours as (
    select
        DATEPART(HOUR, departure_time) as departure_hour,
        COUNT(*) as num_commutes
    from
        commuter_patterns
    group by
        DATEPART(HOUR, departure_time)
)
select 
    departure_hour,
    num_commutes
from
    DepartureHours
order by 
    num_commutes desc;

-- 4: Most Common Origin-Destination Pair:
select top 1 origin, destination, count(*) as num_trips
from commuter_patterns
group by origin, destination
order by num_trips desc ;


-- 5: Longest Average Commute by Mode of Transport: 
select mode_of_transport,
avg(datediff(minute,departure_time, arrival_time)) as avg_commute_time
from commuter_patterns
group by mode_of_transport
order by avg_commute_time desc;

--------------------------------------------------------------------------------------------------------
------------------------------------------Road Segment: KPI's--------------------------------------------
---------------------------------------------------------------------------------------------------------
select*from road_segments;

-- 1: Average Speed Limit Analysis:
select avg(speed_limit) as Avg_speed from road_segments;

-- 2: Lane Distribution Analysis:
select lanes, count(lanes) as Used_lanes 
from road_segments
group by lanes
order by count(lanes) desc;

-- 3: Longest Road Segment:
select max(length) as max_length from road_segments;

-- 4: Speed Limit Compliance Analysis: 
select
    rs.source,
    rs.target,
    rs.speed_limit,
    avg(rs.speed_limit) AS average_actual_speed, 
    sum(case when rs.speed_limit <= rs.speed_limit then 1 else 0 end) * 100.0 / count(*) as compliance_rate
from 
    road_segments rs
group by 
    rs.source, rs.target, rs.speed_limit
order by 
    compliance_rate asc;


-- 5: Lane Efficiency Analysis: 
select
    
    top 10 (cast(speed_limit as float) * lanes) / length as effective_speed,
	source,
   speed_limit,
    lanes
from
    road_segments
order by
    effective_speed desc;


--------------------------------------------------------------------------------------------------------
------------------------------------------Traffic Flow: KPI's--------------------------------------------
---------------------------------------------------------------------------------------------------------
select*from traffic_flow;

-- 1: Total Traffic Analysis: 
select sum(vehicles) as total_vehicles_passed from traffic_flow;

-- 2: Average Speed Analysis: 
select avg(speed) as Avg_speed from traffic_flow;

-- 3: High Congestion Analysis: 
select  top 10 count(congestion_factor) as Congested, source from traffic_flow
group by source
order by  count(congestion_factor) desc;

--------------------------------------------------------------------------------------------------------
------------------------------------------Weather Data : KPI's--------------------------------------------
---------------------------------------------------------------------------------------------------------
select*from weather;

-- 1 :Average Temperature Analysis: 
select avg(temperature) as Avg_Tem from weather;

-- 2: High Precipitation Nodes: 
select top 1 max(precipitation) as High_precipitation , node 
from weather 
group by node 
order by max(precipitation) desc;

-- 3: Wind Speed Distribution: 
select a.node, a.pollution_level, w.wind_speed
from air_quality AS a
JOIN weather as w on a.node = w.node
where a.pollution_level > (select avg(pollution_level) from air_quality) 
AND w.wind_speed > (select avg(wind_speed) from weather)
order by a.pollution_level desc, w.wind_speed desc;

-- 4: Maximum Weather Extremes:
select top 1 max(temperature) as Max_Temperature, node
from weather
group by node
order by max(temperature) desc;

-- 5: Correlation between Weather Conditions:
with WeatherStats as (
  select
   avg(temperature) as AvgTemperature, 
    avg(precipitation) as AvgPrecipitation
  from weather
), Covariance as (
  select 
    sum((temperature - AvgTemperature) * (precipitation - AvgPrecipitation)) / (count(*) - 1) as Covariance
  from weather, WeatherStats
)
select Covariance
from Covariance;

-----------------------------------------------------------------------------------------------
-----------------------------Common Table Expressions----------------------------------------
------------------------------------------------------------------------------------------

-- 1: Identify the Top 5 Most Polluted Areas with Heavy Traffic

with Pollution_CTE as (
    select top 5 node, pollution_level
    from air_quality
    order by pollution_level desc
), Traffic_CTE as (
    select source, avg(congestion_factor) as avg_congestion
    from traffic_flow
    group by source
    having avg(congestion_factor) > 3
)
select p.node, p.pollution_level, t.avg_congestion
from Pollution_CTE p
join Traffic_CTE t on p.node = t.source;

-- 2: Analyze Commuter Patterns for Different Modes of Transport
with CommuterPatterns_CTE as (
    select mode_of_transport, avg(datediff(minute, departure_time, arrival_time)) as avg_travel_time
    from commuter_patterns
    group by mode_of_transport
)
select mode_of_transport, avg_travel_time
from CommuterPatterns_CTE;

-- 3: Optimize Bus Routes Based on Passenger Capacity and Fare
with BusRoutes_CTE as (
    select route_id, avg(capacity) as avg_capacity, avg(fare) as avg_fare
    from bus_routes
    group by route_id
)
select route_id, avg_capacity, avg_fare
from BusRoutes_CTE
where avg_capacity > 20 and avg_fare > 2
order by avg_fare desc, avg_capacity desc;

-- 4: Evaluate Road Segment Efficiency by Speed Limit and Traffic Flow
with RoadSegments_CTE as (
    select source, target, speed_limit
    from road_segments
), TrafficFlow_CTE as (
    select source, target, avg(speed) as avg_speed
    from traffic_flow
    group by source, target
)
select r.source, r.target, r.speed_limit, t.avg_speed
from RoadSegments_CTE r
join TrafficFlow_CTE t on r.source = t.source and r.target = t.target
where t.avg_speed < r.speed_limit * 0.75;

-- 5: Assess Impact of Weather on Bus Route Delays
with weatherimpact_cte as (
    select node, precipitation, wind_speed
    from weather
    where precipitation > 5 or wind_speed > 15
), busdelays_cte as (
    select route_id, value as stop
    from bus_routes
    cross apply string_split(replace(replace(stops, '[', ''), ']', ''), ',')
)
select b.route_id, w.node, w.precipitation, w.wind_speed
from weatherimpact_cte w
join busdelays_cte b on w.node = cast(b.stop as int);



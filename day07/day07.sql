-- part 1
with median as (
    select percentile_cont(0.5) within group (order by position) median
    from day07
)
select sum(abs(position - median))
from day07,
     median;

-- part 2
with average as (
    select round(avg(position)) average
    from day07
),
 distances as (
         select abs(position - average) distance
from day07, average
)
select sum(distance*(distance + 1) / 2) from distances;

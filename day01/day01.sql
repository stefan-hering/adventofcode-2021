-- part 1
select count(diff) from (select depths - lag(depths, 1) over () as diff from day01) d where diff > 0;

-- part 2
select count(diff)
from (
         select sum(depths) over (ROWS 2 PRECEDING)  -
                (lag(depths, 1) over() +
                 lag(depths, 2) over() +
                 lag(depths, 3) over()) as diff
         from day01) d
where diff > 0;

-- part 1
with directions as (
    select *,case when x1 < x2 then 1 when x1 > x2 then -1 else 0 end xdir,
           case when y1 < y2 then 1000 when y1 > y2 then -1000 else 0 end ydir
    from day05 where x1 = x2 or y1 = y2),
     coordinates as (
         select generate_series(x1 + y1 * 1000, x2 + y2 * 1000, xdir+ydir) coordinate from directions
     ),
     summedCoordinates as (
         select coordinate, count(coordinate) count
         from coordinates
         group by coordinate)
select count(0)
from summedCoordinates
where count > 1;


-- part 2
with directions as (
    select *,case when x1 < x2 then 1 when x1 > x2 then -1 else 0 end xdir,
           case when y1 < y2 then 1000 when y1 > y2 then -1000 else 0 end ydir
    from day05),
     coordinates as (
    select generate_series(x1 + y1 * 1000, x2 + y2 * 1000, xdir+ydir) coordinate from directions
),
    summedCoordinates as (
    select coordinate, count(coordinate) count
    from coordinates
    group by coordinate)
select count(0)
from summedCoordinates
where count > 1;

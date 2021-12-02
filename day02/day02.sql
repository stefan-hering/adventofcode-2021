select *
from day02;

-- part 1
with movements as (
    select case
               when direction = 'forward' then value
               end as forward,
           case
               when direction = 'up' then value * - 1
               when direction = 'down' then value
               end as height
    from day02)
select sum(height) * sum(forward)
from movements;


-- part 2
with angles as (
    with movements as (
        select case
                   when direction = 'forward' then value
                   end                        as forward,
               case
                   when direction = 'up' then value * - 1
                   when direction = 'down' then value
                   end                        as height,
               row_number() over (order by 1) as rownum
        from day02)
    select forward,
           coalesce(sum(height) over (order by rownum), 0) as angle
    from movements)
select sum(forward) * sum(forward * angle)
from angles;

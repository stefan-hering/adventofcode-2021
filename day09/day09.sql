drop table if exists matrix cascade;
create table matrix as (
    select id as x, ordinality as y, height::int
    from day09
             left join lateral unnest(regexp_split_to_array(line, '')) with ordinality as height on true
);
create index on matrix (x, y);

-- part 1
create view low_points as
(
select *
from matrix m1
where height < coalesce((select height from matrix m2 where m2.x = m1.x - 1 and m2.y = m1.y), 10)
  and height < coalesce((select height from matrix m2 where m2.x = m1.x + 1 and m2.y = m1.y), 10)
  and height < coalesce((select height from matrix m2 where m2.y = m1.y - 1 and m2.x = m1.x), 10)
  and height < coalesce((select height from matrix m2 where m2.y = m1.y + 1 and m2.x = m1.x), 10));

select sum(height + 1)
from low_points;

-- part 2
drop aggregate if exists product(bigint);
create aggregate product(bigint) (sfunc = int8mul, stype =bigint);

with recursive
    basins as (
        select *, row_number() over () as id
        from low_points
        union
        select m.*, b.id
        from matrix m,
             basins b
        where m.height <> 9
          and m.height > b.height
          and (b.x - 1 = m.x and b.y = m.y
            or b.x + 1 = m.x and b.y = m.y
            or b.y - 1 = m.y and b.x = m.x
            or b.y + 1 = m.y and b.x = m.x)
    ),
    basin_sizes as (
        select id, count(id) size
        from basins
        group by id),
    biggest3 as (
        select size
        from basin_sizes
        order by size desc fetch first 3 rows only)
select product(size)
from biggest3;

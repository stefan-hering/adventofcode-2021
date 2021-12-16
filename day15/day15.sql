drop table if exists grid cascade;
create table grid as (
    select id as x, ordinality as y, risk::int
    from day15
             left join lateral unnest(regexp_split_to_array(line, '')) with ordinality as risk on true
);
create index on grid (x, y);

create or replace function paths(size int) returns void
as
$$
declare
    x int;
    y int;
    i int;
    j int;
begin
    x := 1;
    y := 1;

    drop table if exists minrisks;
    create table minrisks
    (
        x       int,
        y       int,
        minrisk int
    );
    insert into minrisks values (1, 1, 0);

    for i in 1..size
        loop
            for j in 1..size
                loop
                    insert into minrisks (x, y, minrisk)
                        (select i,
                                j,
                                grid.risk + (select min(minrisk)
                                             from minrisks m
                                             where (m.x = i - 1 and m.y = j)
                                                or (m.x = i and m.y = j - 1)
                                )
                         from grid
                         where grid.x = i
                           and grid.y = j);
                end loop;

        end loop;
end
$$
    language plpgsql;

select paths(100, grid);

select *
from minrisks
where x = 100
  and y = 100;


-- attempt at part 2, doesn't work
-- probably due to the assumption of only beedubg ti go down and right

drop table if exists biggrid;
create table biggrid as (
    select x, y, risk
    from grid
    union all
    select x + 100, y, (risk % 9) + 1
    from grid
    union all
    select x + 200, y, ((risk + 1) % 9) + 1
    from grid
    union all
    select x + 300, y, ((risk + 2) % 9) + 1
    from grid
    union all
    select x + 400, y, ((risk + 3) % 9) + 1
    from grid
    union all
    select x, y + 100, (risk % 9) + 1
    from grid
    union all
    select x + 100, y + 100, ((risk + 1) % 9) + 1
    from grid
    union all
    select x + 200, y + 100, ((risk + 2) % 9) + 1
    from grid
    union all
    select x + 300, y + 100, ((risk + 3) % 9) + 1
    from grid
    union all
    select x + 400, y + 100, ((risk + 4) % 9) + 1
    from grid
    union all
    select x, y + 200, ((risk + 1) % 9) + 1
    from grid
    union all
    select x + 100, y + 200, ((risk + 2) % 9) + 1
    from grid
    union all
    select x + 200, y + 200, ((risk + 3) % 9) + 1
    from grid
    union all
    select x + 300, y + 200, ((risk + 4) % 9) + 1
    from grid
    union all
    select x + 400, y + 200, ((risk + 5) % 9) + 1
    from grid
    union all
    select x, y + 300, ((risk + 2) % 9) + 1
    from grid
    union all
    select x + 100, y + 300, ((risk + 3) % 9) + 1
    from grid
    union all
    select x + 200, y + 300, ((risk + 4) % 9) + 1
    from grid
    union all
    select x + 300, y + 300, ((risk + 5) % 9) + 1
    from grid
    union all
    select x + 400, y + 300, ((risk + 6) % 9) + 1
    from grid
    union all
    select x, y + 400, ((risk + 3) % 9) + 1
    from grid
    union all
    select x + 100, y + 400, ((risk + 4) % 9) + 1
    from grid
    union all
    select x + 200, y + 400, ((risk + 5) % 9) + 1
    from grid
    union all
    select x + 300, y + 400, ((risk + 6) % 9) + 1
    from grid
    union all
    select x + 400, y + 400, ((risk + 7) % 9) + 1
    from grid
);
create unique index on biggrid (x, y);

create or replace function bigPaths(size int) returns void
as
$$
declare
    x int;
    y int;
    i int;
    j int;
begin
    x := 1;
    y := 1;

    drop table if exists minrisks;
    create table minrisks
    (
        x       int,
        y       int,
        minrisk int
    );
    insert into minrisks values (1, 1, 0);
    create unique index on minrisks (x, y);

    for i in 1..size
        loop
            for j in 1..size
                loop
                    insert into minrisks (x, y, minrisk)
                        (select i,
                                j,
                                grid.risk + (select min(minrisk)
                                             from minrisks m
                                             where (m.x = i - 1 and m.y = j)
                                                or (m.x = i and m.y = j - 1)
                                )
                         from biggrid grid
                         where grid.x = i
                           and grid.y = j)
                    on conflict do nothing;
                end loop;

        end loop;
end
$$
    language plpgsql;

-- runs for about 2 hours ...
select bigPaths(500);
select *
from minrisks
where x = 500
  and y = 500;


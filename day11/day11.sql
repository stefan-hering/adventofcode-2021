create or replace function flash(out result bigint)
as
$$
declare
    changes int;
    flash   record;
begin
    drop table if exists grid cascade;
    create table grid as (
        select id as x, ordinality as y, energy::int, 'charging'::status as status
        from day11
                 left join lateral unnest(regexp_split_to_array(line, '')) with ordinality as energy on true
    );
    create index on grid (x, y);

    result := 0;
    changes := 0;
    for i in 1..100
        loop
            update grid
            set energy = energy + 1;

            while (select count(0) from grid where energy > 9 and status = 'charging') > 0
                loop
                    update grid set status = 'flashing' where energy > 9 and status = 'charging';
                    result := result + (select count(0) from grid where status = 'flashing');

                    -- need this loop, because neighbors can overlap, needing to be incremented twice
                    for flash in (select x, y
                                  from grid
                                  where energy > 9
                                    and status = 'flashing')
                        loop
                            update grid
                            set energy = energy + 1
                            where (grid.x = flash.x and grid.y = flash.y - 1
                                or grid.x = flash.x and grid.y = flash.y + 1
                                or grid.y = flash.y and grid.x = flash.x - 1
                                or grid.y = flash.y and grid.x = flash.x + 1
                                or grid.x = flash.x + 1 and grid.y = flash.y - 1
                                or grid.x = flash.x + 1 and grid.y = flash.y + 1
                                or grid.x = flash.x - 1 and grid.y = flash.y - 1
                                or grid.x = flash.x - 1 and grid.y = flash.y + 1);
                        end loop;

                    update grid set status = 'flashed' where status = 'flashing';
                end loop;
            update grid set status = 'charging', energy = 0 where status = 'flashed';
        end loop;
end
$$
    language plpgsql;

select flash();


-- part 2
create or replace function synchronizedFlash() returns int
as
$$
declare
    flash record;
begin
    drop table if exists grid cascade;
    create table grid as (
        select id as x, ordinality as y, energy::int, 'charging'::status as status
        from day11
                 left join lateral unnest(regexp_split_to_array(line, '')) with ordinality as energy on true
    );
    create index on grid (x, y);

    for i in 1..100000
        loop
            update grid
            set energy = energy + 1;

            while (select count(0) from grid where energy > 9 and status = 'charging') > 0
                loop
                    update grid set status = 'flashing' where energy > 9 and status = 'charging';

                    for flash in (select x, y
                                  from grid
                                  where energy > 9
                                    and status = 'flashing')
                        loop
                            update grid
                            set energy = energy + 1
                            where (grid.x = flash.x and grid.y = flash.y - 1
                                or grid.x = flash.x and grid.y = flash.y + 1
                                or grid.y = flash.y and grid.x = flash.x - 1
                                or grid.y = flash.y and grid.x = flash.x + 1
                                or grid.x = flash.x + 1 and grid.y = flash.y - 1
                                or grid.x = flash.x + 1 and grid.y = flash.y + 1
                                or grid.x = flash.x - 1 and grid.y = flash.y - 1
                                or grid.x = flash.x - 1 and grid.y = flash.y + 1);
                        end loop;

                    update grid set status = 'flashed' where status = 'flashing';
                end loop;
            if (select count(0) from grid where status = 'flashed') = 100
            then
                return i;
            end if;
            update grid set status = 'charging', energy = 0 where status = 'flashed';
        end loop;
end
$$
    language plpgsql;

select synchronizedFlash();

drop table if exists dots;
create table dots as
    (
        select split_part(line, ',', 1)::int as x, split_part(line, ',', 2)::int as y
        from day13
        where not line ~ '^fold'
    );

create or replace view folds as
(
select substring(line, 'fold along ([xy])') as axis, substring(line, '=(\d+)')::int as value
from day13
where line ~ '^fold'
    );


with fold as (select axis, value from folds limit 1)
update dots
set x = case when fold.axis = 'x' then fold.value * 2 - x else x end,
    y = case when fold.axis = 'y' then fold.value * 2 - y else y end
from fold
where x > fold.value and fold.axis = 'x'
   or y > fold.value and fold.axis = 'y';

select count(0)
from (select distinct x, y from dots) d;


-- part 2
create or replace function foldRemaining() returns void
as
$$
declare
    fold record;
begin
    for fold in (select axis, value
                 from folds
                 offset 1)
        loop
            update dots
            set x = case when fold.axis = 'x' then fold.value * 2 - x else x end,
                y = case when fold.axis = 'y' then fold.value * 2 - y else y end
            where x > fold.value and fold.axis = 'x'
               or y > fold.value and fold.axis = 'y';
        end loop;
end
$$
    language plpgsql;

select foldRemaining();

drop table screen;
create table screen
(
    id int,
    x1 char default '.',
    x2 char default '.',
    x3 char default '.',
    x4 char default '.',
    x5 char default '.',
    x6 char default '.'
);

insert into screen (id)
select x
from generate_series(0, 40) x;

create or replace function render() returns void
as
$$
declare
    dot record;
begin
    for dot in (select x, y
                from dots)
        loop
            update screen
            set x1 = case when dot.y = 0 then '#' else x1 end,
                x2 = case when dot.y = 1 then '#' else x2 end,
                x3 = case when dot.y = 2 then '#' else x3 end,
                x4 = case when dot.y = 3 then '#' else x4 end,
                x5 = case when dot.y = 4 then '#' else x5 end,
                x6 = case when dot.y = 5 then '#' else x6 end
            where id = dot.x;
        end loop;
end
$$
    language plpgsql;

select render();
select *
from dots;

select *
from screen
order by id;

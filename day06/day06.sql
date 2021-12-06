
create or replace function countFishies(days int)
    returns bigint
as
$$
begin
    for i in 1..days loop
            update indexed_lanternfish set age = (age - 1);
            insert into indexed_lanternfish (fishies, age) (select fishies,8 from indexed_lanternfish where age = -1);
            update indexed_lanternfish set fishies = fishies + coalesce((select fishies from indexed_lanternfish where age = - 1),0) where age = 6;
            insert into indexed_lanternfish select fishies, 6 from indexed_lanternfish where age = -1
                                                                                         and not exists (select 1 from indexed_lanternfish where age = 6);
            delete from indexed_lanternfish where age = -1;

        end loop;
    return (select sum(fishies) from indexed_lanternfish);
end;
$$
    language plpgsql;

-- part 1
drop table if exists indexed_lanternfish;
create table indexed_lanternfish as (
    select count(age)::bigint as fishies, age from day06 group by age
);
select countFishies(80);

-- part 2
drop table if exists indexed_lanternfish;
create table indexed_lanternfish as (
    select count(age)::bigint as fishies, age from day06 group by age
);
select countFishies(256);



-- part 1 with brute force approach
drop table polymer;
create table polymer
(
    id   bigint,
    char character
);
create index on polymer (id);

insert into polymer (char, id)
select c, (ordinality - 1) * 100000
from regexp_split_to_table((select line from day14 limit 1), '') with ordinality c;

drop view pair_insertions;
create or replace view pair_insertions as
(
select substring(line, '([A-Z])[A-Z] -> [A-Z]') char1,
       substring(line, '[A-z]([A-Z]) -> [A-Z]') char2,
       substring(line, '[A-Z]{2} -> ([A-Z])')   insertion
from day14
where line ~ '->');

-- execute 10 times :D
with po as (
    select char,
           id,
           lead(char, 1) over (order by id) nextChar,
           lead(id, 1) over (order by id)   nextId
    from polymer
)
insert
into polymer (id, char)
select po.id + (po.nextId - po.id) / 2, pi.insertion
from pair_insertions pi,
     po
where po.char = pi.char1
  and po.nextChar = pi.char2;

select *
from polymer
order by id;
with counts as (select count(char) c from polymer group by char)
select max(c) - min(c)
from counts;

-- part 2 with a smart approach
drop table if exists paircounts;
create table paircounts
(
    char1 character,
    char2 character,
    count bigint
);
create unique index on paircounts (char1, char2);

truncate table paircounts;
-- add 💩 to mark the beginning pair, or else the final sum will be off
-- first pair
with split (char) as (select regexp_split_to_table((select line from day14 limit 1), ''))
insert
into paircounts
values ('💩', (select char from split fetch first row only), 1);

-- rest of the pairs
with split (char) as (select regexp_split_to_table((select line from day14 limit 1), '')),
     pairs as (select char, coalesce(lead(char, 1) over (), '💩') nextChar from split),
     grouped_pairs as (select char as char1, nextChar as char2, count(char || nextChar) as count
                       from pairs
                       group by char, nextChar)
insert
into paircounts
select *
from grouped_pairs
where char2 is not null;


create or replace function polymer(loops int) returns void
as
$$
declare
    insertValue record;
    i           int;
begin
    drop table if exists insertions;
    create table insertions
    (
        char1 character,
        char2 character,
        char3 character,
        count bigint
    );
    for i in 1..loops
        loop
            insert into insertions (select pi.char1, pi.insertion, pi.char2, pc.count
                                    from paircounts pc
                                             join pair_insertions pi on pc.char1 = pi.char1 and pc.char2 = pi.char2);

            for insertValue in (select * from insertions)
                loop
                    update paircounts
                    set count = count - insertValue.count
                    where char1 = insertValue.char1
                      and char2 = insertValue.char3;

                    insert into paircounts as pc
                    select insertValue.char1, insertValue.char2, insertValue.count
                    on conflict (char1, char2)
                        do update set count = pc.count + insertValue.count;

                    insert into paircounts as pc
                    select insertValue.char2, insertValue.char3, insertValue.count
                    on conflict (char1, char2)
                        do update set count = pc.count + insertValue.count;
                end loop;

            truncate table insertions;
        end loop;
end
$$
    language plpgsql;

select polymer(40);

with allchars (char, count) as
         (
             select char1, count
             from paircounts
             union all
             select char2,
                    count
             from paircounts),
     charsums as
         (
             select char, sum(count) / 2 sum
             from allchars
             group by char)
select max(sum) - min(sum)
from charsums
where char <> '💩';


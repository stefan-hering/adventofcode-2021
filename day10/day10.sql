create or replace function firstIllegalChar(line text)
    returns char
as
$$
begin
    drop table if exists stack;
    create table stack
    (
        character text,
        counter   serial
    );

    for i in 1..length(line)
        loop
            -- push [,{,< or (
            with s as (select substring(line, i, 1) c)
            insert
            into stack(character)
            select c
            from s
            where c in ('[', '(', '{', '<');

            if substring(line, i, 1) in (']', ')', '}', '>') then
                if
                        (select case
                                    when character = '[' then ']'
                                    when character = '(' then ')'
                                    when character = '{' then '}'
                                    when character = '<' then '>'
                                    end
                         from stack
                         order by counter desc
                         limit 1) = substring(line, i, 1)
                then
                    delete from stack where counter = (select max(counter) from stack);
                else
                    return substring(line, i, 1);
                end if;
            end if;
        end loop;
    return null;
end
$$
    language plpgsql;

with illegalChars as (select firstIllegalChar(line) i
                      from day10),
     illegalScores as (
         select case
                    when i = ')' then 3
                    when i = ']' then 57
                    when i = '}' then 1197
                    when i = '>' then 25137
                    end score
         from illegalChars
         where i is not null
     )
select sum(score)
from illegalScores;



-- part 2
create or replace function remainingSequence(line text)
    returns text
as
$$
begin
    drop table if exists stack;
    create table stack
    (
        character text,
        counter   serial
    );

    for i in 1..length(line)
        loop
            with s as (select substring(line, i, 1) c)
            insert
            into stack(character)
            select c
            from s
            where c in ('[', '(', '{', '<');

            if substring(line, i, 1) in (']', ')', '}', '>') then
                delete from stack where counter = (select max(counter) from stack);
            end if;
        end loop;
    return reverse(translate((select string_agg(character, '') from stack), '({[<', ')}]>'));
end
$$
    language plpgsql;

create or replace function calculateScore(line text, out result bigint)
as
$$
begin
    result := 0;
    for i in 1..length(line)
        loop
            result := result * 5;

            if substring(line, i, 1) = ')'
            then
                result := result + 1;
            elsif substring(line, i, 1) = ']'
            then
                result := result + 2;
            elseif substring(line, i, 1) = '}'
            then
                result := result + 3;
            elseif substring(line, i, 1) = '>'
            then
                result := result + 4;
            end if;
        end loop;
end
$$
    language plpgsql;

with scores as (
    select calculateScore(remainingSequence(line)) score
    from day10
    where (select firstIllegalChar(line)) is null)
select percentile_cont(0.5) within group (order by score)
from scores;

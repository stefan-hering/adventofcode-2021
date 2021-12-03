create extension if not exists tablefunc;

create or replace view indexes as
(
select *
from generate_series(
             1,
             (select length(number) from day03 fetch first row only)) columnIndex
    );

create or replace function most_common(index text) returns setof char
    language plpgsql as
$func$
begin
    return query execute format(
                'with bits as (select substr(number,%s,1)::char as bit from day03) ' ||
                'select bit from bits group by 1 order by count(*) desc, bit desc fetch first row only', index);
end
$func$;

create or replace function least_common(index text) returns setof char
    language plpgsql as
$func$
begin
    return query execute format(
                'with bits as (select substr(number,%s,1)::char as bit from day03) ' ||
                'select bit from bits group by 1 order by count(*), bit fetch first row only',
                index);
end
$func$;

-- part 1
with gammaRateBits as (select most_common(columnIndex::text) as bit from indexes),
     epsilonRateBits as (select least_common(columnIndex::text) as bit from indexes),
     gammaRate as (select string_agg(bit, '') rate from gammaRateBits),
     epsilonRate as (select string_agg(bit, '') rate from epsilonRateBits)
select gammaRate.rate::bit(12)::integer * epsilonRate.rate::bit(12)::integer
from gammaRate,
     epsilonRate;


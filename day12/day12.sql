create or replace view available_paths as
(
select fromcave, tocave
from day12
where fromcave <> 'end'
union
select tocave, fromcave
from day12
where fromcave <> 'start');

-- part 1
with recursive paths as (
    select fromcave, tocave, array [fromcave, tocave] as path
    from available_paths
    where fromcave = 'start'
    union
    select available_paths.fromcave, available_paths.tocave, array_append(path, available_paths.tocave)
    from available_paths
             join paths on
                available_paths.fromcave = paths.tocave
            and available_paths.fromcave <> 'start'
            and paths.tocave <> 'end'
            and (not paths.path @> array [available_paths.tocave] or available_paths.tocave ~ '[A-Z]+')
)
select count(0)
from paths
where tocave = 'end';

-- part 2
with recursive paths as (
    select fromcave,
           tocave,
           array [fromcave, tocave] as path,
           false                    as hasduplicate
    from available_paths
    where fromcave = 'start'
    union
    select available_paths.fromcave,
           available_paths.tocave,
           array_append(path, available_paths.tocave),
           paths.hasduplicate or (available_paths.tocave ~ '[a-z]+' and paths.path @> array [available_paths.tocave])
    from available_paths
             join paths on
                available_paths.fromcave = paths.tocave
            and available_paths.fromcave <> 'start'
            and paths.tocave <> 'end'
            and (not paths.path @> array [available_paths.tocave] or
                 available_paths.tocave ~ '[A-Z]+' or
                 not hasduplicate)
)
select count(*)
from paths
where tocave = 'end';

-- part 1
with outputs as (
    select unnest(outputs) output
    from day08)
select count(0)
from outputs
where length(output) in (2, 3, 4, 7);


-- part 2, schema
create or replace view day08_indexed as
(
select signals,
       outputs,
       row_number() over () as id
from day08);

drop table if exists displays;
create table displays
(
    display_id int primary key
);

drop table if exists signals;
create table signals
(
    display_id    int,
    signal        text,
    matchednumber int
);

drop table if exists outputs;
create table outputs
(
    display_id int,
    output     text,
    ordinal    serial
);

drop table if exists identified_signals;
create table identified_signals
(
    display_id int,
    signal     text,
    character  char
);

-- normalize input data
insert into displays (select row_number() over () as id from day08);
insert into signals (select row_number() over () as display_id, unnest(signals) as signal, null from day08);
insert into outputs (select row_number() over () as display_id, unnest(outputs) as output from day08);

-- first the easy ones
update signals
set matchednumber = 1
where length(signal) = 2;

update signals
set matchednumber = 7
where length(signal) = 3;

update signals
set matchednumber = 4
where length(signal) = 4;

update signals
set matchednumber = 8
where length(signal) = 7;

-- when removing the 2 letters from 1 from the 5 char numbers, the remaining lengths are, 3->3, 2->4, 4->4
-- so we can identify 3
update signals
set matchednumber = 3
where length(signal) = 5
  and length(translate(signal, (select signal
                                from signals s1
                                where s1.display_id = signals.display_id
                                  and s1.matchednumber = 1), '')) = 3;

-- just like 3 we can identify 6
update signals
set matchednumber = 6
where length(signal) = 6
  and length(translate(signal, (select signal
                                from signals s1
                                where s1.display_id = signals.display_id
                                  and s1.matchednumber = 1), '')) = 5;

-- with 6 identified, we can use it and 1 to find out the two characters on the right side
with match1n6 as
         (select s1.display_id, s1.signal as signal1, s6.signal as signal6
          from signals s1
                   join signals s6 on s1.display_id = s6.display_id and s1.matchednumber = 1 and s6.matchednumber = 6)
insert
into identified_signals (display_id, signal, character)
    (select display_id,
            'bottomright',
            case when (signal6 ~ substr(signal1, 1, 1)) then substr(signal1, 1, 1) else substr(signal1, 2, 1) end
     from match1n6
     union
     select display_id,
            'topright',
            translate(signal1, signal6, '')
     from match1n6);

-- since we already know 3, we can identify 5 over 2 by using the bottom right character
update signals
set matchednumber = 5
where length(signal) = 5
  and matchednumber is null
  and signal ~ (select character
                from identified_signals
                where identified_signals.display_id = signals.display_id
                  and signal = 'bottomright');

-- now 2 is the only 5 length thing left
update signals
set matchednumber = 2
where length(signal) = 5
  and matchednumber is null;

-- we camn find the bottom left character using 1,2 and 5
insert into identified_signals (display_id, signal, character)
    (select s2.display_id,
            'bottomleft',
            translate(translate(s2.signal, s5.signal, ''), s1.signal, '')
     from signals s5
              join signals s2 on s5.matchednumber = 5
         and s2.matchednumber = 2
         and s2.display_id = s5.display_id
              join signals s1 on s1.matchednumber = 1 and s1.display_id = s5.display_id);

-- bottom left helps us find 0 over 9
update signals
set matchednumber = 0
where length(signal) = 6
  and matchednumber is null
  and signal ~ (select character
                from identified_signals
                where identified_signals.display_id = signals.display_id
                  and signal = 'bottomleft');

-- and now only 9 remains
update signals
set matchednumber = 9
where matchednumber is null;

-- identify some more characters so we have an easier time decoding the result
insert into identified_signals (select s0.display_id, 'middle', translate(s8.signal, s0.signal, '')
                                from signals s0
                                         join signals s8 on s0.display_id = s8.display_id and s0.matchednumber = 0 and
                                                            s8.matchednumber = 8);

insert into identified_signals (select s4.display_id, 'topleft', translate(s4.signal, s3.signal, '')
                                from signals s4
                                         join signals s3 on s4.display_id = s3.display_id and s4.matchednumber = 4 and
                                                            s3.matchednumber = 3);

insert into identified_signals (
    select s7.display_id, 'top', translate(s7.signal, s1.signal, '')
    from signals s1
             join signals s7 on s7.display_id = s1.display_id and s7.matchednumber = 7 and s1.matchednumber = 1);

-- now just match the outputs to numbers, concatenate and sum them
with decoded_numbers as
         (select string_agg(case
                                when length(output) = 2 then '1'
                                when length(output) = 3 then '7'
                                when length(output) = 4 then '4'
                                when length(output) = 7 then '8'
                                when length(output) = 5 and output ~ (select character
                                                                      from identified_signals ids
                                                                      where outputs.display_id = ids.display_id
                                                                        and ids.signal = 'bottomleft') then '2'
                                when length(output) = 5 and output ~ (select character
                                                                      from identified_signals ids
                                                                      where outputs.display_id = ids.display_id
                                                                        and ids.signal = 'topleft')
                                    then '5'
                                when length(output) = 5 then '3'
                                when length(output) = 6 and not output ~ (select character
                                                                          from identified_signals ids
                                                                          where outputs.display_id = ids.display_id
                                                                            and ids.signal = 'middle') then '0'
                                when length(output) = 6 and not output ~ (select character
                                                                          from identified_signals ids
                                                                          where outputs.display_id = ids.display_id
                                                                            and ids.signal = 'topright') then '6'
                                when length(output) = 6 then '9'
                                end, '') number
          from outputs
          group by display_id)
select sum(number::int)
from decoded_numbers;

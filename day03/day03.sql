create or replace view bits as
(
select substr(number, 1, 1)  as digit1,
       substr(number, 2, 1)  as digit2,
       substr(number, 3, 1)  as digit3,
       substr(number, 4, 1)  as digit4,
       substr(number, 5, 1)  as digit5,
       substr(number, 6, 1)  as digit6,
       substr(number, 7, 1)  as digit7,
       substr(number, 8, 1)  as digit8,
       substr(number, 9, 1)  as digit9,
       substr(number, 10, 1) as digit10,
       substr(number, 11, 1) as digit11,
       substr(number, 12, 1) as digit12
from day03);

-- sample input, good vim practice
select (mostCommonDigit1.digit || mostCommonDigit2.digit || mostCommonDigit3.digit || mostCommonDigit4.digit ||
        mostCommonDigit5.digit)::bit(5)::integer *
       (leastCommonDigit1.digit || leastCommonDigit2.digit || leastCommonDigit3.digit || leastCommonDigit4.digit ||
        leastCommonDigit5.digit)::bit(5)::integer
from (select digit1 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit1,
     (select digit2 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit2,
     (select digit3 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit3,
     (select digit4 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit4,
     (select digit5 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit5,
     (select digit1 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit1,
     (select digit2 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit2,
     (select digit3 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit3,
     (select digit4 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit4,
     (select digit5 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit5;


-- part 1, maybe this wasn't the best approach
select (mostCommonDigit1.digit || mostCommonDigit2.digit || mostCommonDigit3.digit || mostCommonDigit4.digit ||
        mostCommonDigit5.digit || mostCommonDigit6.digit || mostCommonDigit7.digit || mostCommonDigit8.digit ||
        mostCommonDigit9.digit || mostCommonDigit10.digit || mostCommonDigit11.digit ||
        mostCommonDigit12.digit)::bit(12)::integer *
       (leastCommonDigit1.digit || leastCommonDigit2.digit || leastCommonDigit3.digit || leastCommonDigit4.digit ||
        leastCommonDigit5.digit || leastCommonDigit6.digit || leastCommonDigit7.digit || leastCommonDigit8.digit ||
        leastCommonDigit9.digit || leastCommonDigit10.digit || leastCommonDigit11.digit ||
        leastCommonDigit12.digit)::bit(12)::integer
from (select digit1 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit1,
     (select digit2 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit2,
     (select digit3 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit3,
     (select digit4 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit4,
     (select digit5 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit5,
     (select digit6 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit6,
     (select digit7 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit7,
     (select digit8 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit8,
     (select digit9 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit9,
     (select digit10 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit10,
     (select digit11 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit11,
     (select digit12 as digit from bits group by 1 order by count(*) desc fetch first row only) mostCommonDigit12,
     (select digit1 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit1,
     (select digit2 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit2,
     (select digit3 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit3,
     (select digit4 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit4,
     (select digit5 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit5,
     (select digit6 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit6,
     (select digit7 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit7,
     (select digit8 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit8,
     (select digit9 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit9,
     (select digit10 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit10,
     (select digit11 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit11,
     (select digit12 as digit from bits group by 1 order by count(*) fetch first row only) leastCommonDigit12;

-- part 2, uhh...
with leastCommonBit1 as (
    select digit1 as digit from bits group by digit1 order by count(*), digit1 fetch first row only
),
     oxygen1 as (
         select bits.*
         from bits,
              leastCommonBit1
         where digit1 = leastCommonBit1.digit
     ),
     leastCommonBit2 as (
         select digit2 as digit from oxygen1 group by digit2 order by count(*), digit2 fetch first row only
     ),
     oxygen2 as (
         select oxygen1.*
         from oxygen1,
              leastCommonBit2
         where digit2 = leastCommonBit2.digit
     ),
     leastCommonBit3 as (
         select digit3 as digit from oxygen2 group by digit3 order by count(*), digit3 fetch first row only
     ),
     oxygen3 as (
         select oxygen2.*
         from oxygen2,
              leastCommonBit3
         where digit3 = leastCommonBit3.digit
     ),
     leastCommonBit4 as (
         select digit4 as digit from oxygen3 group by digit4 order by count(*), digit4 fetch first row only
     ),
     oxygen4 as (
         select oxygen3.*
         from oxygen3,
              leastCommonBit4
         where digit4 = leastCommonBit4.digit
     ),
     leastCommonBit5 as (
         select digit5 as digit from oxygen4 group by digit5 order by count(*), digit5 fetch first row only
     ),
     oxygen5 as (
         select oxygen4.*
         from oxygen4,
              leastCommonBit5
         where digit5 = leastCommonBit5.digit
     ),
     leastCommonBit6 as (
         select digit6 as digit from oxygen5 group by digit6 order by count(*), digit6 fetch first row only
     ),
     oxygen6 as (
         select oxygen5.*
         from oxygen5,
              leastCommonBit6
         where digit6 = leastCommonBit6.digit
     ),
     leastCommonBit7 as (
         select digit7 as digit from oxygen6 group by digit7 order by count(*), digit7 fetch first row only
     ),
     oxygen7 as (
         select oxygen6.*
         from oxygen6,
              leastCommonBit7
         where digit7 = leastCommonBit7.digit
     ),
     leastCommonBit8 as (
         select digit8 as digit from oxygen7 group by digit8 order by count(*), digit8 fetch first row only
     ),
     oxygen8 as (
         select oxygen7.*
         from oxygen7,
              leastCommonBit8
         where digit8 = leastCommonBit8.digit
     ),
     leastCommonBit9 as (
         select digit9 as digit from oxygen8 group by digit9 order by count(*), digit9 fetch first row only
     ),
     oxygen9 as (
         select oxygen8.*
         from oxygen8,
              leastCommonBit9
         where digit9 = leastCommonBit9.digit
     ),
     leastCommonBit10 as (
         select digit10 as digit from oxygen9 group by digit10 order by count(*), digit10 fetch first row only
     ),
     oxygen10 as (
         select oxygen9.*
         from oxygen9,
              leastCommonBit10
         where digit10 = leastCommonBit10.digit
     ),
     leastCommonBit11 as (
         select digit11 as digit from oxygen10 group by digit11 order by count(*), digit11 fetch first row only
     ),
     oxygen11 as (
         select oxygen10.*
         from oxygen10,
              leastCommonBit11
         where digit11 = leastCommonBit11.digit
     ),
     leastCommonBit12 as (
         select digit12 as digit from oxygen11 group by digit12 order by count(*), digit12 fetch first row only
     ),
     -- now co2
     mostCommonBit1 as (
         select digit1 as digit from bits group by digit1 order by count(*) desc, digit1 desc fetch first row only
     ),
     co21 as (
         select bits.*
         from bits,
              mostCommonBit1
         where digit1 = mostCommonBit1.digit
     ),
     mostCommonBit2 as (
         select digit2 as digit from co21 group by digit2 order by count(*) desc, digit2 desc fetch first row only
     ),
     co22 as (
         select co21.*
         from co21,
              mostCommonBit2
         where digit2 = mostCommonBit2.digit
     ),
     mostCommonBit3 as (
         select digit3 as digit from co22 group by digit3 order by count(*) desc, digit3 desc fetch first row only
     ),
     co23 as (
         select co22.*
         from co22,
              mostCommonBit3
         where digit3 = mostCommonBit3.digit
     ),
     mostCommonBit4 as (
         select digit4 as digit from co23 group by digit4 order by count(*) desc, digit4 desc fetch first row only
     ),
     co24 as (
         select co23.*
         from co23,
              mostCommonBit4
         where digit4 = mostCommonBit4.digit
     ),
     mostCommonBit5 as (
         select digit5 as digit from co24 group by digit5 order by count(*) desc, digit5 desc fetch first row only
     ),
     co25 as (
         select co24.*
         from co24,
              mostCommonBit5
         where digit5 = mostCommonBit5.digit
     ),
     mostCommonBit6 as (
         select digit6 as digit from co25 group by digit6 order by count(*) desc, digit6 desc fetch first row only
     ),
     co26 as (
         select co25.*
         from co25,
              mostCommonBit6
         where digit6 = mostCommonBit6.digit
     ),
     mostCommonBit7 as (
         select digit7 as digit from co26 group by digit7 order by count(*) desc, digit7 desc fetch first row only
     ),
     co27 as (
         select co26.*
         from co26,
              mostCommonBit7
         where digit7 = mostCommonBit7.digit
     ),
     mostCommonBit8 as (
         select digit8 as digit from co27 group by digit8 order by count(*) desc, digit8 desc fetch first row only
     ),
     co28 as (
         select co27.*
         from co27,
              mostCommonBit8
         where digit8 = mostCommonBit8.digit
     ),
     mostCommonBit9 as (
         select digit9 as digit from co28 group by digit9 order by count(*) desc, digit9 desc fetch first row only
     ),
     co29 as (
         select co28.*
         from co28,
              mostCommonBit9
         where digit9 = mostCommonBit9.digit
     ),
     mostCommonBit10 as (
         select digit10 as digit from co29 group by digit10 order by count(*) desc, digit10 desc fetch first row only
     ),
     co210 as (
         select co29.*
         from co29,
              mostCommonBit10
         where digit10 = mostCommonBit10.digit
     ),
     mostCommonBit11 as (
         select digit11 as digit from co210 group by digit11 order by count(*) desc, digit11 desc fetch first row only
     ),
     co211 as (
         select co210.*
         from co210,
              mostCommonBit11
         where digit11 = mostCommonBit11.digit
     ),
     mostCommonBit12 as (
         select digit12 as digit from co211 group by digit12 order by count(*) desc, digit12 desc fetch first row only
     )
select (oxygen.digit1 || oxygen.digit2 || oxygen.digit3 || oxygen.digit4 ||
        oxygen.digit5 || oxygen.digit6 || oxygen.digit7 || oxygen.digit8 ||
        oxygen.digit9 || oxygen.digit10 || oxygen.digit11 ||
        oxygen.digit12)::bit(12)::integer *
       (co2.digit1 || co2.digit2 || co2.digit3 || co2.digit4 ||
        co2.digit5 || co2.digit6 || co2.digit7 || co2.digit8 ||
        co2.digit9 || co2.digit10 || co2.digit11 ||
        co2.digit12)::bit(12)::integer
from (co211 join mostCommonBit12 on co211.digit12 = mostCommonBit12.digit) co2,
     (oxygen11 join leastCommonBit12 on oxygen11.digit12 = leastCommonBit12.digit) oxygen;

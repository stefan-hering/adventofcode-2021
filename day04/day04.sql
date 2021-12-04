drop table splitboards;
create table splitboards as
    (
        select board,
               (select ARRAY(select unnest(board[1:1])))    as row1,
               (select ARRAY(select unnest(board[2:2])))    as row2,
               (select ARRAY(select unnest(board[3:3])))    as row3,
               (select ARRAY(select unnest(board[4:4])))    as row4,
               (select ARRAY(select unnest(board[5:5])))    as row5,
               (select ARRAY(select unnest(board[5][1:1]))) as column1,
               (select ARRAY(select unnest(board[5][2:2]))) as column2,
               (select ARRAY(select unnest(board[5][3:3]))) as column3,
               (select ARRAY(select unnest(board[5][4:4]))) as column4,
               (select ARRAY(select unnest(board[5][5:5]))) as column5
        from day04_boards);

create or replace function bingo()
    returns int
as
$$
declare
    t_row day04_numbers%rowtype;
begin
    for t_row in SELECT number from day04_numbers
        loop
            update splitboards
            set row1    = array_remove(row1, t_row.number),
                row2    = array_remove(row2, t_row.number),
                row3    = array_remove(row3, t_row.number),
                row4    = array_remove(row4, t_row.number),
                row5    = array_remove(row5, t_row.number),
                column1 = array_remove(column1, t_row.number),
                column2 = array_remove(column2, t_row.number),
                column3 = array_remove(column3, t_row.number),
                column4 = array_remove(column4, t_row.number),
                column5 = array_remove(column5, t_row.number);

            if exists(select 1
                      from splitboards
                      where array_length(row1, 1) is null
                         or array_length(row2, 1) is null
                         or array_length(row3, 1) is null
                         or array_length(row4, 1) is null
                         or array_length(row5, 1) is null
                         or array_length(column1, 1) is null
                         or array_length(column2, 1) is null
                         or array_length(column3, 1) is null
                         or array_length(column4, 1) is null
                         or array_length(column5, 1) is null) then
                return ((select (coalesce((select sum(s) from unnest(row1) s), 0) +
                                coalesce((select sum(s) from unnest(row2) s), 0) +
                                coalesce((select sum(s) from unnest(row3) s), 0) +
                                coalesce((select sum(s) from unnest(row4) s), 0) +
                                coalesce((select sum(s) from unnest(row5) s), 0)) * t_row.number
                         from splitboards
                         where array_length(row1, 1) is null
                            or array_length(row2, 1) is null
                            or array_length(row3, 1) is null
                            or array_length(row4, 1) is null
                            or array_length(row5, 1) is null
                            or array_length(column1, 1) is null
                            or array_length(column2, 1) is null
                            or array_length(column3, 1) is null
                            or array_length(column4, 1) is null
                            or array_length(column5, 1) is null));
            end if;

        end loop;
end;
$$
    language plpgsql;


select bingo();


-- part 2, need to fill split boards again

create or replace function losingBingo()
    returns int
as
$$
declare
    t_row day04_numbers%rowtype;
begin
    for t_row in SELECT number from day04_numbers
        loop
            update splitboards
            set row1    = array_remove(row1, t_row.number),
                row2    = array_remove(row2, t_row.number),
                row3    = array_remove(row3, t_row.number),
                row4    = array_remove(row4, t_row.number),
                row5    = array_remove(row5, t_row.number),
                column1 = array_remove(column1, t_row.number),
                column2 = array_remove(column2, t_row.number),
                column3 = array_remove(column3, t_row.number),
                column4 = array_remove(column4, t_row.number),
                column5 = array_remove(column5, t_row.number);

            if (select count(*) from splitboards) > 1
            then
                delete
                from splitboards
                where array_length(row1, 1) is null
                   or array_length(row2, 1) is null
                   or array_length(row3, 1) is null
                   or array_length(row4, 1) is null
                   or array_length(row5, 1) is null
                   or array_length(column1, 1) is null
                   or array_length(column2, 1) is null
                   or array_length(column3, 1) is null
                   or array_length(column4, 1) is null
                   or array_length(column5, 1) is null;
            end if;
            if exists(select 1
                      from splitboards
                      where array_length(row1, 1) is null
                         or array_length(row2, 1) is null
                         or array_length(row3, 1) is null
                         or array_length(row4, 1) is null
                         or array_length(row5, 1) is null
                         or array_length(column1, 1) is null
                         or array_length(column2, 1) is null
                         or array_length(column3, 1) is null
                         or array_length(column4, 1) is null
                         or array_length(column5, 1) is null) then
                return ((select (coalesce((select sum(s) from unnest(row1) s), 0) +
                                 coalesce((select sum(s) from unnest(row2) s), 0) +
                                 coalesce((select sum(s) from unnest(row3) s), 0) +
                                 coalesce((select sum(s) from unnest(row4) s), 0) +
                                 coalesce((select sum(s) from unnest(row5) s), 0)) * t_row.number
                         from splitboards
                         where array_length(row1, 1) is null
                            or array_length(row2, 1) is null
                            or array_length(row3, 1) is null
                            or array_length(row4, 1) is null
                            or array_length(row5, 1) is null
                            or array_length(column1, 1) is null
                            or array_length(column2, 1) is null
                            or array_length(column3, 1) is null
                            or array_length(column4, 1) is null
                            or array_length(column5, 1) is null));
            end if;

        end loop;
end;
$$
    language plpgsql;

select losingBingo();

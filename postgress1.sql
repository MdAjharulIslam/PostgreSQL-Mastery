create table person(
id serial primary key,
name varchar(100),
city varchar(100) not null default 'dhaka'
)
drop table person

insert into person values

(1, 'ajharul', 'khulna')



select * from person

update person
set city = 'kishoregonj'
where id = 1;
delete from person
where id=1
create table stores (
	id serial primary key,
    name varchar(64) not null
);
create table hardwares (
	id serial primary key,
    deviceId varchar(64) not null,
    fk_store integer REFERENCES stores (id)
)

#!/bin/bash
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -h localhost  <<-EOSQL
     create schema if not exists $SCHEMA;
     create table $SCHEMA.images (
        id serial primary key,
        capture_event_id varchar (12) not null,
        url_info text not null
     );
     create table $SCHEMA.consensus (
        id serial primary key,
        capture_event_id varchar (12) not null,
        num_images smallint,
        date_time timestamp,
        site_id varchar (4),
        long float8,
        lat float8,
        num_species smallint,
        species text,
        count smallint,
        standing float8,
        resting float8,
        moving float8,
        eating float8,
        interacting float8,
        babies float8,
        num_classifications smallint,
        num_votes smallint,
        num_blanks smallint,
        evenness float8
     );
     create table $SCHEMA.inference (
        id serial primary key,
        url_info text not null,
        classes smallint[] not null,
        scores float8[] not null
     );
     create table $SCHEMA.classes (
        id serial primary key,
        classes_id smallint not null,
        species text not null
     );
EOSQL

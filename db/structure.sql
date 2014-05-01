--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: poems; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE poems (
    id integer NOT NULL,
    title character varying(255),
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    content_text tsvector
);


--
-- Name: poems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE poems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE poems_id_seq OWNED BY poems.id;


--
-- Name: rows; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rows (
    id integer NOT NULL,
    content character varying(255),
    content_text tsvector
);


--
-- Name: rows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rows_id_seq OWNED BY rows.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tokens (
    id integer NOT NULL,
    token character varying(255)
);


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tokens_id_seq OWNED BY tokens.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY poems ALTER COLUMN id SET DEFAULT nextval('poems_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rows ALTER COLUMN id SET DEFAULT nextval('rows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tokens ALTER COLUMN id SET DEFAULT nextval('tokens_id_seq'::regclass);


--
-- Name: poems_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY poems
    ADD CONSTRAINT poems_pkey PRIMARY KEY (id);


--
-- Name: rows_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rows
    ADD CONSTRAINT rows_pkey PRIMARY KEY (id);


--
-- Name: tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: content_text_gin; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX content_text_gin ON rows USING gin (content_text);


--
-- Name: content_text_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX content_text_index ON poems USING gin (content_text);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: ts_content_text; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_content_text BEFORE INSERT OR UPDATE ON rows FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('content_text', 'pg_catalog.russian', 'content');


--
-- Name: ts_content_text; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ts_content_text BEFORE INSERT OR UPDATE ON poems FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('content_text', 'pg_catalog.russian', 'content');


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140225204300');

INSERT INTO schema_migrations (version) VALUES ('20140323181417');

INSERT INTO schema_migrations (version) VALUES ('20140501081552');

INSERT INTO schema_migrations (version) VALUES ('20140501105912');

INSERT INTO schema_migrations (version) VALUES ('20140501115346');

INSERT INTO schema_migrations (version) VALUES ('20140501130314');

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id bigint NOT NULL,
    name character varying NOT NULL,
    platform_owner boolean DEFAULT false NOT NULL,
    users_count integer DEFAULT 0 NOT NULL,
    teams_count integer DEFAULT 0 NOT NULL,
    lockers_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: locker_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locker_actions (
    id bigint NOT NULL,
    locker_id bigint NOT NULL,
    user_id bigint,
    company_id bigint,
    action integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
)
PARTITION BY RANGE (created_at);


--
-- Name: locker_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locker_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locker_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locker_actions_id_seq OWNED BY public.locker_actions.id;


--
-- Name: locker_actions_2026_07; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locker_actions_2026_07 (
    id bigint DEFAULT nextval('public.locker_actions_id_seq'::regclass) NOT NULL,
    locker_id bigint NOT NULL,
    user_id bigint,
    company_id bigint,
    action integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locker_actions_2026_08; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locker_actions_2026_08 (
    id bigint DEFAULT nextval('public.locker_actions_id_seq'::regclass) NOT NULL,
    locker_id bigint NOT NULL,
    user_id bigint,
    company_id bigint,
    action integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locker_actions_2026_09; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locker_actions_2026_09 (
    id bigint DEFAULT nextval('public.locker_actions_id_seq'::regclass) NOT NULL,
    locker_id bigint NOT NULL,
    user_id bigint,
    company_id bigint,
    action integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locker_actions_2026_10; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locker_actions_2026_10 (
    id bigint DEFAULT nextval('public.locker_actions_id_seq'::regclass) NOT NULL,
    locker_id bigint NOT NULL,
    user_id bigint,
    company_id bigint,
    action integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locker_actions_2026_11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locker_actions_2026_11 (
    id bigint DEFAULT nextval('public.locker_actions_id_seq'::regclass) NOT NULL,
    locker_id bigint NOT NULL,
    user_id bigint,
    company_id bigint,
    action integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locker_actions_2026_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locker_actions_2026_12 (
    id bigint DEFAULT nextval('public.locker_actions_id_seq'::regclass) NOT NULL,
    locker_id bigint NOT NULL,
    user_id bigint,
    company_id bigint,
    action integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locker_team_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locker_team_permissions (
    id bigint NOT NULL,
    locker_id bigint NOT NULL,
    team_id bigint NOT NULL,
    company_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locker_team_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locker_team_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locker_team_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locker_team_permissions_id_seq OWNED BY public.locker_team_permissions.id;


--
-- Name: lockers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lockers (
    id bigint NOT NULL,
    physical_device_id bigint NOT NULL,
    company_id bigint,
    name character varying NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    started_at timestamp(6) without time zone NOT NULL,
    ended_at timestamp(6) without time zone,
    last_status_changed_at timestamp(6) without time zone,
    last_status_changed_by_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT lockers_ended_after_started CHECK (((ended_at IS NULL) OR (ended_at > started_at)))
);


--
-- Name: lockers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lockers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lockers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lockers_id_seq OWNED BY public.lockers.id;


--
-- Name: physical_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.physical_devices (
    id bigint NOT NULL,
    device_id character varying NOT NULL,
    model character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: physical_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.physical_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: physical_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.physical_devices_id_seq OWNED BY public.physical_devices.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    name character varying NOT NULL,
    company_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: teams_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams_users (
    team_id bigint NOT NULL,
    user_id bigint NOT NULL,
    company_id bigint NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying NOT NULL,
    company_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: locker_actions_2026_07; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions ATTACH PARTITION public.locker_actions_2026_07 FOR VALUES FROM ('2026-07-01 00:00:00') TO ('2026-08-01 00:00:00');


--
-- Name: locker_actions_2026_08; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions ATTACH PARTITION public.locker_actions_2026_08 FOR VALUES FROM ('2026-08-01 00:00:00') TO ('2026-09-01 00:00:00');


--
-- Name: locker_actions_2026_09; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions ATTACH PARTITION public.locker_actions_2026_09 FOR VALUES FROM ('2026-09-01 00:00:00') TO ('2026-10-01 00:00:00');


--
-- Name: locker_actions_2026_10; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions ATTACH PARTITION public.locker_actions_2026_10 FOR VALUES FROM ('2026-10-01 00:00:00') TO ('2026-11-01 00:00:00');


--
-- Name: locker_actions_2026_11; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions ATTACH PARTITION public.locker_actions_2026_11 FOR VALUES FROM ('2026-11-01 00:00:00') TO ('2026-12-01 00:00:00');


--
-- Name: locker_actions_2026_12; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions ATTACH PARTITION public.locker_actions_2026_12 FOR VALUES FROM ('2026-12-01 00:00:00') TO ('2027-01-01 00:00:00');


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: locker_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions ALTER COLUMN id SET DEFAULT nextval('public.locker_actions_id_seq'::regclass);


--
-- Name: locker_team_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_team_permissions ALTER COLUMN id SET DEFAULT nextval('public.locker_team_permissions_id_seq'::regclass);


--
-- Name: lockers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lockers ALTER COLUMN id SET DEFAULT nextval('public.lockers_id_seq'::regclass);


--
-- Name: physical_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.physical_devices ALTER COLUMN id SET DEFAULT nextval('public.physical_devices_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: locker_actions locker_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions
    ADD CONSTRAINT locker_actions_pkey PRIMARY KEY (id, created_at);


--
-- Name: locker_actions_2026_07 locker_actions_2026_07_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions_2026_07
    ADD CONSTRAINT locker_actions_2026_07_pkey PRIMARY KEY (id, created_at);


--
-- Name: locker_actions_2026_08 locker_actions_2026_08_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions_2026_08
    ADD CONSTRAINT locker_actions_2026_08_pkey PRIMARY KEY (id, created_at);


--
-- Name: locker_actions_2026_09 locker_actions_2026_09_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions_2026_09
    ADD CONSTRAINT locker_actions_2026_09_pkey PRIMARY KEY (id, created_at);


--
-- Name: locker_actions_2026_10 locker_actions_2026_10_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions_2026_10
    ADD CONSTRAINT locker_actions_2026_10_pkey PRIMARY KEY (id, created_at);


--
-- Name: locker_actions_2026_11 locker_actions_2026_11_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions_2026_11
    ADD CONSTRAINT locker_actions_2026_11_pkey PRIMARY KEY (id, created_at);


--
-- Name: locker_actions_2026_12 locker_actions_2026_12_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_actions_2026_12
    ADD CONSTRAINT locker_actions_2026_12_pkey PRIMARY KEY (id, created_at);


--
-- Name: locker_team_permissions locker_team_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_team_permissions
    ADD CONSTRAINT locker_team_permissions_pkey PRIMARY KEY (id);


--
-- Name: lockers lockers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lockers
    ADD CONSTRAINT lockers_pkey PRIMARY KEY (id);


--
-- Name: physical_devices physical_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.physical_devices
    ADD CONSTRAINT physical_devices_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_companies_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_name ON public.companies USING btree (name);


--
-- Name: index_companies_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_name_trgm ON public.companies USING gin (name public.gin_trgm_ops);


--
-- Name: index_companies_on_platform_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_platform_owner ON public.companies USING btree (platform_owner) WHERE (platform_owner = true);


--
-- Name: index_locker_actions_on_company_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locker_actions_on_company_id_and_created_at ON ONLY public.locker_actions USING btree (company_id, created_at);


--
-- Name: index_locker_actions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locker_actions_on_created_at ON ONLY public.locker_actions USING btree (created_at);


--
-- Name: index_locker_actions_on_locker_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locker_actions_on_locker_id_and_created_at ON ONLY public.locker_actions USING btree (locker_id, created_at);


--
-- Name: index_locker_actions_on_user_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locker_actions_on_user_id_and_created_at ON ONLY public.locker_actions USING btree (user_id, created_at);


--
-- Name: index_locker_team_permissions_on_locker_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locker_team_permissions_on_locker_id_and_company_id ON public.locker_team_permissions USING btree (locker_id, company_id);


--
-- Name: index_locker_team_permissions_on_locker_id_and_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_locker_team_permissions_on_locker_id_and_team_id ON public.locker_team_permissions USING btree (locker_id, team_id);


--
-- Name: index_locker_team_permissions_on_team_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locker_team_permissions_on_team_id_and_company_id ON public.locker_team_permissions USING btree (team_id, company_id);


--
-- Name: index_lockers_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lockers_on_company_id ON public.lockers USING btree (company_id);


--
-- Name: index_lockers_on_company_id_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lockers_on_company_id_active ON public.lockers USING btree (company_id) WHERE (ended_at IS NULL);


--
-- Name: index_lockers_on_company_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lockers_on_company_id_and_status ON public.lockers USING btree (company_id, status);


--
-- Name: index_lockers_on_ended_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lockers_on_ended_at ON public.lockers USING btree (ended_at);


--
-- Name: index_lockers_on_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lockers_on_id_and_company_id ON public.lockers USING btree (id, company_id);


--
-- Name: index_lockers_on_last_status_changed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lockers_on_last_status_changed_at ON public.lockers USING btree (last_status_changed_at);


--
-- Name: index_lockers_on_last_status_changed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lockers_on_last_status_changed_by_id ON public.lockers USING btree (last_status_changed_by_id);


--
-- Name: index_lockers_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lockers_on_name_trgm ON public.lockers USING gin (name public.gin_trgm_ops);


--
-- Name: index_lockers_on_physical_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lockers_on_physical_device_id ON public.lockers USING btree (physical_device_id);


--
-- Name: index_lockers_on_physical_device_id_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lockers_on_physical_device_id_active ON public.lockers USING btree (physical_device_id) WHERE (ended_at IS NULL);


--
-- Name: index_physical_devices_on_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_physical_devices_on_device_id ON public.physical_devices USING btree (device_id);


--
-- Name: index_physical_devices_on_device_id_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_physical_devices_on_device_id_trgm ON public.physical_devices USING gin (device_id public.gin_trgm_ops);


--
-- Name: index_teams_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_company_id ON public.teams USING btree (company_id);


--
-- Name: index_teams_on_company_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_on_company_id_and_name ON public.teams USING btree (company_id, name);


--
-- Name: index_teams_on_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_on_id_and_company_id ON public.teams USING btree (id, company_id);


--
-- Name: index_teams_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_name_trgm ON public.teams USING gin (name public.gin_trgm_ops);


--
-- Name: index_teams_users_on_team_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_users_on_team_id_and_company_id ON public.teams_users USING btree (team_id, company_id);


--
-- Name: index_teams_users_on_team_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_users_on_team_id_and_user_id ON public.teams_users USING btree (team_id, user_id);


--
-- Name: index_teams_users_on_user_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_users_on_user_id_and_company_id ON public.teams_users USING btree (user_id, company_id);


--
-- Name: index_teams_users_on_user_id_and_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_users_on_user_id_and_team_id ON public.teams_users USING btree (user_id, team_id);


--
-- Name: index_users_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_company_id ON public.users USING btree (company_id);


--
-- Name: index_users_on_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_id_and_company_id ON public.users USING btree (id, company_id);


--
-- Name: index_users_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name_trgm ON public.users USING gin (name public.gin_trgm_ops);


--
-- Name: locker_actions_2026_07_company_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_07_company_id_created_at_idx ON public.locker_actions_2026_07 USING btree (company_id, created_at);


--
-- Name: locker_actions_2026_07_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_07_created_at_idx ON public.locker_actions_2026_07 USING btree (created_at);


--
-- Name: locker_actions_2026_07_locker_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_07_locker_id_created_at_idx ON public.locker_actions_2026_07 USING btree (locker_id, created_at);


--
-- Name: locker_actions_2026_07_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_07_user_id_created_at_idx ON public.locker_actions_2026_07 USING btree (user_id, created_at);


--
-- Name: locker_actions_2026_08_company_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_08_company_id_created_at_idx ON public.locker_actions_2026_08 USING btree (company_id, created_at);


--
-- Name: locker_actions_2026_08_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_08_created_at_idx ON public.locker_actions_2026_08 USING btree (created_at);


--
-- Name: locker_actions_2026_08_locker_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_08_locker_id_created_at_idx ON public.locker_actions_2026_08 USING btree (locker_id, created_at);


--
-- Name: locker_actions_2026_08_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_08_user_id_created_at_idx ON public.locker_actions_2026_08 USING btree (user_id, created_at);


--
-- Name: locker_actions_2026_09_company_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_09_company_id_created_at_idx ON public.locker_actions_2026_09 USING btree (company_id, created_at);


--
-- Name: locker_actions_2026_09_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_09_created_at_idx ON public.locker_actions_2026_09 USING btree (created_at);


--
-- Name: locker_actions_2026_09_locker_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_09_locker_id_created_at_idx ON public.locker_actions_2026_09 USING btree (locker_id, created_at);


--
-- Name: locker_actions_2026_09_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_09_user_id_created_at_idx ON public.locker_actions_2026_09 USING btree (user_id, created_at);


--
-- Name: locker_actions_2026_10_company_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_10_company_id_created_at_idx ON public.locker_actions_2026_10 USING btree (company_id, created_at);


--
-- Name: locker_actions_2026_10_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_10_created_at_idx ON public.locker_actions_2026_10 USING btree (created_at);


--
-- Name: locker_actions_2026_10_locker_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_10_locker_id_created_at_idx ON public.locker_actions_2026_10 USING btree (locker_id, created_at);


--
-- Name: locker_actions_2026_10_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_10_user_id_created_at_idx ON public.locker_actions_2026_10 USING btree (user_id, created_at);


--
-- Name: locker_actions_2026_11_company_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_11_company_id_created_at_idx ON public.locker_actions_2026_11 USING btree (company_id, created_at);


--
-- Name: locker_actions_2026_11_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_11_created_at_idx ON public.locker_actions_2026_11 USING btree (created_at);


--
-- Name: locker_actions_2026_11_locker_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_11_locker_id_created_at_idx ON public.locker_actions_2026_11 USING btree (locker_id, created_at);


--
-- Name: locker_actions_2026_11_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_11_user_id_created_at_idx ON public.locker_actions_2026_11 USING btree (user_id, created_at);


--
-- Name: locker_actions_2026_12_company_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_12_company_id_created_at_idx ON public.locker_actions_2026_12 USING btree (company_id, created_at);


--
-- Name: locker_actions_2026_12_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_12_created_at_idx ON public.locker_actions_2026_12 USING btree (created_at);


--
-- Name: locker_actions_2026_12_locker_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_12_locker_id_created_at_idx ON public.locker_actions_2026_12 USING btree (locker_id, created_at);


--
-- Name: locker_actions_2026_12_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locker_actions_2026_12_user_id_created_at_idx ON public.locker_actions_2026_12 USING btree (user_id, created_at);


--
-- Name: locker_actions_2026_07_company_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_company_id_and_created_at ATTACH PARTITION public.locker_actions_2026_07_company_id_created_at_idx;


--
-- Name: locker_actions_2026_07_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_created_at ATTACH PARTITION public.locker_actions_2026_07_created_at_idx;


--
-- Name: locker_actions_2026_07_locker_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_locker_id_and_created_at ATTACH PARTITION public.locker_actions_2026_07_locker_id_created_at_idx;


--
-- Name: locker_actions_2026_07_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.locker_actions_pkey ATTACH PARTITION public.locker_actions_2026_07_pkey;


--
-- Name: locker_actions_2026_07_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_user_id_and_created_at ATTACH PARTITION public.locker_actions_2026_07_user_id_created_at_idx;


--
-- Name: locker_actions_2026_08_company_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_company_id_and_created_at ATTACH PARTITION public.locker_actions_2026_08_company_id_created_at_idx;


--
-- Name: locker_actions_2026_08_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_created_at ATTACH PARTITION public.locker_actions_2026_08_created_at_idx;


--
-- Name: locker_actions_2026_08_locker_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_locker_id_and_created_at ATTACH PARTITION public.locker_actions_2026_08_locker_id_created_at_idx;


--
-- Name: locker_actions_2026_08_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.locker_actions_pkey ATTACH PARTITION public.locker_actions_2026_08_pkey;


--
-- Name: locker_actions_2026_08_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_user_id_and_created_at ATTACH PARTITION public.locker_actions_2026_08_user_id_created_at_idx;


--
-- Name: locker_actions_2026_09_company_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_company_id_and_created_at ATTACH PARTITION public.locker_actions_2026_09_company_id_created_at_idx;


--
-- Name: locker_actions_2026_09_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_created_at ATTACH PARTITION public.locker_actions_2026_09_created_at_idx;


--
-- Name: locker_actions_2026_09_locker_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_locker_id_and_created_at ATTACH PARTITION public.locker_actions_2026_09_locker_id_created_at_idx;


--
-- Name: locker_actions_2026_09_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.locker_actions_pkey ATTACH PARTITION public.locker_actions_2026_09_pkey;


--
-- Name: locker_actions_2026_09_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_user_id_and_created_at ATTACH PARTITION public.locker_actions_2026_09_user_id_created_at_idx;


--
-- Name: locker_actions_2026_10_company_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_company_id_and_created_at ATTACH PARTITION public.locker_actions_2026_10_company_id_created_at_idx;


--
-- Name: locker_actions_2026_10_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_created_at ATTACH PARTITION public.locker_actions_2026_10_created_at_idx;


--
-- Name: locker_actions_2026_10_locker_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_locker_id_and_created_at ATTACH PARTITION public.locker_actions_2026_10_locker_id_created_at_idx;


--
-- Name: locker_actions_2026_10_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.locker_actions_pkey ATTACH PARTITION public.locker_actions_2026_10_pkey;


--
-- Name: locker_actions_2026_10_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_user_id_and_created_at ATTACH PARTITION public.locker_actions_2026_10_user_id_created_at_idx;


--
-- Name: locker_actions_2026_11_company_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_company_id_and_created_at ATTACH PARTITION public.locker_actions_2026_11_company_id_created_at_idx;


--
-- Name: locker_actions_2026_11_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_created_at ATTACH PARTITION public.locker_actions_2026_11_created_at_idx;


--
-- Name: locker_actions_2026_11_locker_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_locker_id_and_created_at ATTACH PARTITION public.locker_actions_2026_11_locker_id_created_at_idx;


--
-- Name: locker_actions_2026_11_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.locker_actions_pkey ATTACH PARTITION public.locker_actions_2026_11_pkey;


--
-- Name: locker_actions_2026_11_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_user_id_and_created_at ATTACH PARTITION public.locker_actions_2026_11_user_id_created_at_idx;


--
-- Name: locker_actions_2026_12_company_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_company_id_and_created_at ATTACH PARTITION public.locker_actions_2026_12_company_id_created_at_idx;


--
-- Name: locker_actions_2026_12_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_created_at ATTACH PARTITION public.locker_actions_2026_12_created_at_idx;


--
-- Name: locker_actions_2026_12_locker_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_locker_id_and_created_at ATTACH PARTITION public.locker_actions_2026_12_locker_id_created_at_idx;


--
-- Name: locker_actions_2026_12_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.locker_actions_pkey ATTACH PARTITION public.locker_actions_2026_12_pkey;


--
-- Name: locker_actions_2026_12_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_locker_actions_on_user_id_and_created_at ATTACH PARTITION public.locker_actions_2026_12_user_id_created_at_idx;


--
-- Name: locker_team_permissions fk_rails_218de8ba10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_team_permissions
    ADD CONSTRAINT fk_rails_218de8ba10 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: lockers fk_rails_700e738313; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lockers
    ADD CONSTRAINT fk_rails_700e738313 FOREIGN KEY (physical_device_id) REFERENCES public.physical_devices(id);


--
-- Name: teams_users fk_rails_74983f37ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams_users
    ADD CONSTRAINT fk_rails_74983f37ec FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_7682a3bdfe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_7682a3bdfe FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: teams_users fk_rails_7caef73a94; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams_users
    ADD CONSTRAINT fk_rails_7caef73a94 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: lockers fk_rails_7d044c7bf0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lockers
    ADD CONSTRAINT fk_rails_7d044c7bf0 FOREIGN KEY (last_status_changed_by_id) REFERENCES public.users(id);


--
-- Name: locker_team_permissions fk_rails_9152c7a576; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_team_permissions
    ADD CONSTRAINT fk_rails_9152c7a576 FOREIGN KEY (locker_id) REFERENCES public.lockers(id);


--
-- Name: lockers fk_rails_b167e7f6d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lockers
    ADD CONSTRAINT fk_rails_b167e7f6d8 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: teams fk_rails_e080df8a94; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT fk_rails_e080df8a94 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: locker_team_permissions fk_rails_e460f03e34; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_team_permissions
    ADD CONSTRAINT fk_rails_e460f03e34 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: teams_users fk_rails_fc526a31fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams_users
    ADD CONSTRAINT fk_rails_fc526a31fc FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: locker_actions locker_actions_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.locker_actions
    ADD CONSTRAINT locker_actions_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: locker_actions locker_actions_locker_company_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.locker_actions
    ADD CONSTRAINT locker_actions_locker_company_fk FOREIGN KEY (locker_id, company_id) REFERENCES public.lockers(id, company_id);


--
-- Name: locker_actions locker_actions_locker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.locker_actions
    ADD CONSTRAINT locker_actions_locker_id_fkey FOREIGN KEY (locker_id) REFERENCES public.lockers(id);


--
-- Name: locker_actions locker_actions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.locker_actions
    ADD CONSTRAINT locker_actions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: locker_team_permissions locker_team_permissions_locker_company_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_team_permissions
    ADD CONSTRAINT locker_team_permissions_locker_company_fk FOREIGN KEY (locker_id, company_id) REFERENCES public.lockers(id, company_id);


--
-- Name: locker_team_permissions locker_team_permissions_team_company_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locker_team_permissions
    ADD CONSTRAINT locker_team_permissions_team_company_fk FOREIGN KEY (team_id, company_id) REFERENCES public.teams(id, company_id);


--
-- Name: teams_users teams_users_team_company_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams_users
    ADD CONSTRAINT teams_users_team_company_fk FOREIGN KEY (team_id, company_id) REFERENCES public.teams(id, company_id);


--
-- Name: teams_users teams_users_user_company_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams_users
    ADD CONSTRAINT teams_users_user_company_fk FOREIGN KEY (user_id, company_id) REFERENCES public.users(id, company_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20261003140000'),
('20261002151657'),
('20261002151550'),
('20261002151545'),
('20261002151537'),
('20261002151515'),
('20261002151504'),
('20261002151457'),
('20261002151435');


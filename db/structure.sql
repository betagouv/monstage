SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: fr; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION public.fr (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR asciiword WITH french_stem;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR word WITH public.unaccent, french_stem;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR hword_part WITH public.unaccent, french_stem;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR hword_asciipart WITH french_stem;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR asciihword WITH french_stem;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR hword WITH public.unaccent, french_stem;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.fr
    ADD MAPPING FOR uint WITH simple;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: action_text_rich_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.action_text_rich_texts (
    id bigint NOT NULL,
    name character varying NOT NULL,
    body text,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.action_text_rich_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.action_text_rich_texts_id_seq OWNED BY public.action_text_rich_texts.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: class_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.class_rooms (
    id bigint NOT NULL,
    name character varying,
    school_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: class_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.class_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: class_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.class_rooms_id_seq OWNED BY public.class_rooms.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id bigint NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: email_whitelists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_whitelists (
    id bigint NOT NULL,
    email character varying,
    zipcode character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: email_whitelists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_whitelists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_whitelists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_whitelists_id_seq OWNED BY public.email_whitelists.id;


--
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedbacks (
    id bigint NOT NULL,
    email character varying NOT NULL,
    comment text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aasm_state character varying,
    zammad_id character varying
);


--
-- Name: feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feedbacks_id_seq OWNED BY public.feedbacks.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    is_public boolean,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: internship_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_applications (
    id bigint NOT NULL,
    user_id bigint,
    internship_offer_week_id bigint,
    motivation text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    aasm_state character varying,
    approved_at timestamp without time zone,
    rejected_at timestamp without time zone,
    convention_signed_at timestamp without time zone,
    submitted_at timestamp without time zone,
    pending_reminder_sent_at date,
    automatically_rejected_at date
);


--
-- Name: internship_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_applications_id_seq OWNED BY public.internship_applications.id;


--
-- Name: internship_offer_operators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offer_operators (
    id bigint NOT NULL,
    internship_offer_id bigint,
    operator_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: internship_offer_operators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offer_operators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offer_operators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offer_operators_id_seq OWNED BY public.internship_offer_operators.id;


--
-- Name: internship_offer_weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offer_weeks (
    id bigint NOT NULL,
    internship_offer_id bigint,
    week_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    blocked_applications_count integer DEFAULT 0 NOT NULL
);


--
-- Name: internship_offer_weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offer_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offer_weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offer_weeks_id_seq OWNED BY public.internship_offer_weeks.id;


--
-- Name: internship_offers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internship_offers (
    id bigint NOT NULL,
    title character varying NOT NULL,
    max_candidates integer DEFAULT 1 NOT NULL,
    internship_offer_weeks_count integer DEFAULT 1 NOT NULL,
    tutor_name character varying,
    tutor_phone character varying,
    tutor_email character varying,
    employer_website character varying,
    street text NOT NULL,
    zipcode character varying NOT NULL,
    city character varying NOT NULL,
    is_public boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    coordinates public.geography(Point,4326),
    employer_name character varying NOT NULL,
    old_group character varying,
    employer_id bigint,
    school_id bigint,
    sector_id bigint NOT NULL,
    blocked_weeks_count integer DEFAULT 0 NOT NULL,
    total_applications_count integer DEFAULT 0 NOT NULL,
    convention_signed_applications_count integer DEFAULT 0 NOT NULL,
    approved_applications_count integer DEFAULT 0 NOT NULL,
    employer_type character varying,
    department character varying DEFAULT ''::character varying NOT NULL,
    academy character varying DEFAULT ''::character varying NOT NULL,
    total_male_applications_count integer DEFAULT 0 NOT NULL,
    total_male_convention_signed_applications_count integer DEFAULT 0 NOT NULL,
    remote_id character varying,
    permalink character varying,
    total_custom_track_convention_signed_applications_count integer DEFAULT 0 NOT NULL,
    view_count integer DEFAULT 0 NOT NULL,
    submitted_applications_count integer DEFAULT 0 NOT NULL,
    rejected_applications_count integer DEFAULT 0 NOT NULL,
    published_at timestamp without time zone,
    description character varying DEFAULT ''::character varying NOT NULL,
    employer_description character varying,
    total_male_approved_applications_count integer DEFAULT 0,
    total_custom_track_approved_applications_count integer DEFAULT 0,
    group_id bigint
);


--
-- Name: internship_offers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internship_offers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internship_offers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internship_offers_id_seq OWNED BY public.internship_offers.id;


--
-- Name: operators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operators (
    id bigint NOT NULL,
    name character varying
);


--
-- Name: operators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.operators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.operators_id_seq OWNED BY public.operators.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: school_internship_weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.school_internship_weeks (
    id bigint NOT NULL,
    school_id bigint,
    week_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: school_internship_weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.school_internship_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: school_internship_weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.school_internship_weeks_id_seq OWNED BY public.school_internship_weeks.id;


--
-- Name: schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schools (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    city character varying DEFAULT ''::character varying NOT NULL,
    department character varying,
    zipcode character varying,
    code_uai character varying,
    coordinates public.geography(Point,4326),
    street character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    city_tsv tsvector,
    kind character varying,
    visible boolean DEFAULT true
);


--
-- Name: schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schools_id_seq OWNED BY public.schools.id;


--
-- Name: sectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sectors (
    id bigint NOT NULL,
    name character varying,
    external_url character varying DEFAULT ''::character varying NOT NULL,
    uuid character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: sectors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sectors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sectors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sectors_id_seq OWNED BY public.sectors.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    phone character varying,
    first_name character varying,
    last_name character varying,
    operator_name character varying,
    type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    school_id bigint,
    birth_date date,
    gender character varying,
    class_room_id bigint,
    resume_educational_background text,
    resume_other text,
    resume_languages text,
    has_parental_consent boolean DEFAULT false,
    operator_id bigint,
    api_token character varying,
    handicap text,
    custom_track boolean DEFAULT false NOT NULL,
    accept_terms boolean DEFAULT false NOT NULL,
    discarded_at timestamp without time zone,
    zipcode character varying,
    department_name character varying
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
-- Name: weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weeks (
    id bigint NOT NULL,
    number integer,
    year integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.weeks_id_seq OWNED BY public.weeks.id;


--
-- Name: action_text_rich_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts ALTER COLUMN id SET DEFAULT nextval('public.action_text_rich_texts_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: class_rooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_rooms ALTER COLUMN id SET DEFAULT nextval('public.class_rooms_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: email_whitelists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_whitelists ALTER COLUMN id SET DEFAULT nextval('public.email_whitelists_id_seq'::regclass);


--
-- Name: feedbacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks ALTER COLUMN id SET DEFAULT nextval('public.feedbacks_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: internship_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_applications ALTER COLUMN id SET DEFAULT nextval('public.internship_applications_id_seq'::regclass);


--
-- Name: internship_offer_operators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_operators ALTER COLUMN id SET DEFAULT nextval('public.internship_offer_operators_id_seq'::regclass);


--
-- Name: internship_offer_weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_weeks ALTER COLUMN id SET DEFAULT nextval('public.internship_offer_weeks_id_seq'::regclass);


--
-- Name: internship_offers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers ALTER COLUMN id SET DEFAULT nextval('public.internship_offers_id_seq'::regclass);


--
-- Name: operators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operators ALTER COLUMN id SET DEFAULT nextval('public.operators_id_seq'::regclass);


--
-- Name: school_internship_weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_internship_weeks ALTER COLUMN id SET DEFAULT nextval('public.school_internship_weeks_id_seq'::regclass);


--
-- Name: schools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools ALTER COLUMN id SET DEFAULT nextval('public.schools_id_seq'::regclass);


--
-- Name: sectors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sectors ALTER COLUMN id SET DEFAULT nextval('public.sectors_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks ALTER COLUMN id SET DEFAULT nextval('public.weeks_id_seq'::regclass);


--
-- Name: action_text_rich_texts action_text_rich_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts
    ADD CONSTRAINT action_text_rich_texts_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: class_rooms class_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_rooms
    ADD CONSTRAINT class_rooms_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: email_whitelists email_whitelists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_whitelists
    ADD CONSTRAINT email_whitelists_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: internship_applications internship_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_applications
    ADD CONSTRAINT internship_applications_pkey PRIMARY KEY (id);


--
-- Name: internship_offer_operators internship_offer_operators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_operators
    ADD CONSTRAINT internship_offer_operators_pkey PRIMARY KEY (id);


--
-- Name: internship_offer_weeks internship_offer_weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_weeks
    ADD CONSTRAINT internship_offer_weeks_pkey PRIMARY KEY (id);


--
-- Name: internship_offers internship_offers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT internship_offers_pkey PRIMARY KEY (id);


--
-- Name: operators operators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operators
    ADD CONSTRAINT operators_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: school_internship_weeks school_internship_weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_internship_weeks
    ADD CONSTRAINT school_internship_weeks_pkey PRIMARY KEY (id);


--
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: sectors sectors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sectors
    ADD CONSTRAINT sectors_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weeks weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks
    ADD CONSTRAINT weeks_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: index_action_text_rich_texts_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_action_text_rich_texts_uniqueness ON public.action_text_rich_texts USING btree (record_type, record_id, name);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_class_rooms_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_class_rooms_on_school_id ON public.class_rooms USING btree (school_id);


--
-- Name: index_internship_applications_on_aasm_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_applications_on_aasm_state ON public.internship_applications USING btree (aasm_state);


--
-- Name: index_internship_applications_on_internship_offer_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_applications_on_internship_offer_week_id ON public.internship_applications USING btree (internship_offer_week_id);


--
-- Name: index_internship_applications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_applications_on_user_id ON public.internship_applications USING btree (user_id);


--
-- Name: index_internship_offer_operators_on_internship_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_operators_on_internship_offer_id ON public.internship_offer_operators USING btree (internship_offer_id);


--
-- Name: index_internship_offer_operators_on_operator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_operators_on_operator_id ON public.internship_offer_operators USING btree (operator_id);


--
-- Name: index_internship_offer_weeks_on_blocked_applications_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_weeks_on_blocked_applications_count ON public.internship_offer_weeks USING btree (blocked_applications_count);


--
-- Name: index_internship_offer_weeks_on_internship_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_weeks_on_internship_offer_id ON public.internship_offer_weeks USING btree (internship_offer_id);


--
-- Name: index_internship_offer_weeks_on_internship_offer_id_and_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_weeks_on_internship_offer_id_and_week_id ON public.internship_offer_weeks USING btree (internship_offer_id, week_id);


--
-- Name: index_internship_offer_weeks_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offer_weeks_on_week_id ON public.internship_offer_weeks USING btree (week_id);


--
-- Name: index_internship_offers_on_academy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_academy ON public.internship_offers USING btree (academy);


--
-- Name: index_internship_offers_on_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_coordinates ON public.internship_offers USING gist (coordinates);


--
-- Name: index_internship_offers_on_department; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_department ON public.internship_offers USING btree (department);


--
-- Name: index_internship_offers_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_discarded_at ON public.internship_offers USING btree (discarded_at);


--
-- Name: index_internship_offers_on_employer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_employer_id ON public.internship_offers USING btree (employer_id);


--
-- Name: index_internship_offers_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_group_id ON public.internship_offers USING btree (group_id);


--
-- Name: index_internship_offers_on_old_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_old_group ON public.internship_offers USING btree (old_group);


--
-- Name: index_internship_offers_on_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_remote_id ON public.internship_offers USING btree (remote_id);


--
-- Name: index_internship_offers_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_school_id ON public.internship_offers USING btree (school_id);


--
-- Name: index_internship_offers_on_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_internship_offers_on_sector_id ON public.internship_offers USING btree (sector_id);


--
-- Name: index_school_internship_weeks_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_school_internship_weeks_on_school_id ON public.school_internship_weeks USING btree (school_id);


--
-- Name: index_school_internship_weeks_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_school_internship_weeks_on_week_id ON public.school_internship_weeks USING btree (week_id);


--
-- Name: index_schools_on_city_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_city_tsv ON public.schools USING gin (city_tsv);


--
-- Name: index_schools_on_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_coordinates ON public.schools USING gist (coordinates);


--
-- Name: index_users_on_api_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_api_token ON public.users USING btree (api_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_discarded_at ON public.users USING btree (discarded_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_school_id ON public.users USING btree (school_id);


--
-- Name: index_weeks_on_number_and_year; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_weeks_on_number_and_year ON public.weeks USING btree (number, year);


--
-- Name: index_weeks_on_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weeks_on_year ON public.weeks USING btree (year);


--
-- Name: not_blocked_by_weeks_count_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX not_blocked_by_weeks_count_index ON public.internship_offers USING btree (internship_offer_weeks_count, blocked_weeks_count);


--
-- Name: uniq_applications_per_internship_offer_week; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_applications_per_internship_offer_week ON public.internship_applications USING btree (user_id, internship_offer_week_id);


--
-- Name: schools sync_schools_city_tsv; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sync_schools_city_tsv BEFORE INSERT OR UPDATE ON public.schools FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('city_tsv', 'public.fr', 'city', 'name', 'zipcode');


--
-- Name: school_internship_weeks fk_rails_07f908dbef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_internship_weeks
    ADD CONSTRAINT fk_rails_07f908dbef FOREIGN KEY (week_id) REFERENCES public.weeks(id);


--
-- Name: internship_offer_operators fk_rails_256357b65e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_operators
    ADD CONSTRAINT fk_rails_256357b65e FOREIGN KEY (internship_offer_id) REFERENCES public.internship_offers(id);


--
-- Name: internship_applications fk_rails_32ed157946; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_applications
    ADD CONSTRAINT fk_rails_32ed157946 FOREIGN KEY (internship_offer_week_id) REFERENCES public.internship_offer_weeks(id);


--
-- Name: internship_offers fk_rails_34bc8b9f6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_34bc8b9f6c FOREIGN KEY (employer_id) REFERENCES public.users(id);


--
-- Name: internship_offers fk_rails_3cef9bdd89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_3cef9bdd89 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: class_rooms fk_rails_49ae717ca2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_rooms
    ADD CONSTRAINT fk_rails_49ae717ca2 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: users fk_rails_535539e4e8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_535539e4e8 FOREIGN KEY (operator_id) REFERENCES public.operators(id);


--
-- Name: internship_offer_weeks fk_rails_5b8648c95e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_weeks
    ADD CONSTRAINT fk_rails_5b8648c95e FOREIGN KEY (week_id) REFERENCES public.weeks(id);


--
-- Name: school_internship_weeks fk_rails_61db9e054c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.school_internship_weeks
    ADD CONSTRAINT fk_rails_61db9e054c FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: internship_offers fk_rails_77a64a8062; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_77a64a8062 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: internship_applications fk_rails_93579c3ede; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_applications
    ADD CONSTRAINT fk_rails_93579c3ede FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: internship_offers fk_rails_aaa97f3a41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offers
    ADD CONSTRAINT fk_rails_aaa97f3a41 FOREIGN KEY (sector_id) REFERENCES public.sectors(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: users fk_rails_d23d91f0e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_d23d91f0e6 FOREIGN KEY (class_room_id) REFERENCES public.class_rooms(id);


--
-- Name: internship_offer_operators fk_rails_f2bf160031; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_operators
    ADD CONSTRAINT fk_rails_f2bf160031 FOREIGN KEY (operator_id) REFERENCES public.operators(id);


--
-- Name: internship_offer_weeks fk_rails_f36a7226ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internship_offer_weeks
    ADD CONSTRAINT fk_rails_f36a7226ee FOREIGN KEY (internship_offer_id) REFERENCES public.internship_offers(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20190207111844'),
('20190212163331'),
('20190215085127'),
('20190215085241'),
('20190215091447'),
('20190215093600'),
('20190215094300'),
('20190221091804'),
('20190221092730'),
('20190222073540'),
('20190222105911'),
('20190222163308'),
('20190222170419'),
('20190301090235'),
('20190305103435'),
('20190305141531'),
('20190306095302'),
('20190306105437'),
('20190306105656'),
('20190306110022'),
('20190306110023'),
('20190307101119'),
('20190307102151'),
('20190308164116'),
('20190313093340'),
('20190313104908'),
('20190315134228'),
('20190315155431'),
('20190315164204'),
('20190319144452'),
('20190320105347'),
('20190320141522'),
('20190320180942'),
('20190321142430'),
('20190322092608'),
('20190324172606'),
('20190328190416'),
('20190328231657'),
('20190328235707'),
('20190329002736'),
('20190329003048'),
('20190329104358'),
('20190329142701'),
('20190402074125'),
('20190402083217'),
('20190402120207'),
('20190403101116'),
('20190403101319'),
('20190403104915'),
('20190403153507'),
('20190403155105'),
('20190404120942'),
('20190404133601'),
('20190404142124'),
('20190405081101'),
('20190405095801'),
('20190405113420'),
('20190405113421'),
('20190411151038'),
('20190412140509'),
('20190412140608'),
('20190412143018'),
('20190412143905'),
('20190412202203'),
('20190417084500'),
('20190417084501'),
('20190419082459'),
('20190419142003'),
('20190424085502'),
('20190424085503'),
('20190424115311'),
('20190426075049'),
('20190509125437'),
('20190509131202'),
('20190516145246'),
('20190518064711'),
('20190522083217'),
('20190522120310'),
('20190523072433'),
('20190523144837'),
('20190524051223'),
('20190524051545'),
('20190524091853'),
('20190524092527'),
('20190524153049'),
('20190606144929'),
('20190606145310'),
('20190606151156'),
('20190614130950'),
('20190615210642'),
('20190626093643'),
('20190627210748'),
('20190731084620'),
('20190802130601'),
('20190802140943'),
('20190802142452'),
('20190802163449'),
('20190807122943'),
('20190808091244'),
('20190814075600'),
('20190814124142'),
('20190814152258'),
('20190821145025'),
('20190821200207'),
('20190828090307'),
('20190828130418'),
('20190830080035'),
('20190830082420'),
('20190909092332'),
('20190911091325'),
('20190911091821'),
('20190911132109'),
('20190911134144'),
('20190918101306'),
('20190918140641'),
('20190919131236'),
('20190926131324'),
('20190927140816'),
('20191004132428'),
('20191004151418'),
('20191015142231'),
('20191030141809'),
('20191105104038'),
('20191105104039'),
('20191120184441'),
('20191120184442'),
('20191127144843'),
('20191211145010'),
('20191212090431'),
('20191218134559'),
('20200114163150'),
('20200114163210'),
('20200114164134'),
('20200114164236');



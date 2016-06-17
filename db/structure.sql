--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ballot_response_results; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ballot_response_results (
    id integer NOT NULL,
    ballot_response_id integer,
    precinct_id integer,
    votes integer,
    uid character varying(255),
    contest_result_id integer NOT NULL,
    ballot_type character varying(255)
);


--
-- Name: ballot_response_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ballot_response_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ballot_response_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ballot_response_results_id_seq OWNED BY ballot_response_results.id;


--
-- Name: ballot_responses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ballot_responses (
    id integer NOT NULL,
    referendum_id integer,
    uid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    sort_order integer
);


--
-- Name: ballot_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ballot_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ballot_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ballot_responses_id_seq OWNED BY ballot_responses.id;


--
-- Name: candidate_results; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE candidate_results (
    id integer NOT NULL,
    candidate_id integer,
    precinct_id integer,
    votes integer,
    uid character varying(255),
    contest_result_id integer NOT NULL,
    ballot_type character varying(255)
);


--
-- Name: candidate_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE candidate_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: candidate_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE candidate_results_id_seq OWNED BY candidate_results.id;


--
-- Name: candidates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE candidates (
    id integer NOT NULL,
    uid character varying(255) NOT NULL,
    contest_id integer,
    name character varying(255),
    sort_order integer,
    party_id integer NOT NULL,
    color character varying(255)
);


--
-- Name: candidates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE candidates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: candidates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE candidates_id_seq OWNED BY candidates.id;


--
-- Name: contest_results; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contest_results (
    id integer NOT NULL,
    uid character varying(255) NOT NULL,
    certification character varying(255) NOT NULL,
    precinct_id integer,
    contest_id integer,
    referendum_id integer,
    total_votes integer,
    total_valid_votes integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    color_code character varying(255),
    overvotes integer,
    undervotes integer
);


--
-- Name: contest_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contest_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contest_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contest_results_id_seq OWNED BY contest_results.id;


--
-- Name: contests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contests (
    id integer NOT NULL,
    uid character varying(255) NOT NULL,
    district_id integer,
    office character varying(255),
    sort_order character varying(255),
    district_type character varying(255),
    locality_id integer,
    partisan boolean,
    write_in boolean,
    election_id integer
);


--
-- Name: contests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contests_id_seq OWNED BY contests.id;


--
-- Name: districts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE districts (
    id integer NOT NULL,
    uid character varying(255) NOT NULL,
    name character varying(255),
    district_type character varying(255),
    locality_id integer
);


--
-- Name: districts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE districts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: districts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE districts_id_seq OWNED BY districts.id;


--
-- Name: districts_precincts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE districts_precincts (
    district_id integer NOT NULL,
    precinct_id integer NOT NULL
);


--
-- Name: elections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE elections (
    id integer NOT NULL,
    state_id integer NOT NULL,
    uid character varying(255) NOT NULL,
    held_on date,
    election_type character varying(255) NOT NULL,
    statewide boolean,
    reporting numeric(5,2) DEFAULT 0 NOT NULL,
    seq integer DEFAULT 0 NOT NULL
);


--
-- Name: elections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE elections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: elections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE elections_id_seq OWNED BY elections.id;


--
-- Name: localities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE localities (
    id integer NOT NULL,
    state_id integer NOT NULL,
    name character varying(255) NOT NULL,
    locality_type character varying(255) NOT NULL,
    uid character varying(255) NOT NULL
);


--
-- Name: localities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE localities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: localities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE localities_id_seq OWNED BY localities.id;


--
-- Name: parties; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE parties (
    id integer NOT NULL,
    uid character varying(255) NOT NULL,
    sort_order integer,
    name character varying(255) NOT NULL,
    abbr character varying(255) NOT NULL,
    locality_id integer
);


--
-- Name: parties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parties_id_seq OWNED BY parties.id;


--
-- Name: polling_locations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE polling_locations (
    id integer NOT NULL,
    precinct_id integer,
    address_id integer,
    name character varying(255) NOT NULL,
    line1 character varying(255),
    line2 character varying(255),
    city character varying(255),
    state character varying(255),
    zip character varying(255)
);


--
-- Name: polling_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE polling_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: polling_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE polling_locations_id_seq OWNED BY polling_locations.id;


--
-- Name: precincts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE precincts (
    id integer NOT NULL,
    locality_id integer,
    uid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    kml text,
    total_cast integer,
    geo geometry(Geometry,4326),
    precinct_id integer,
    registered_voters integer
);


--
-- Name: precincts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE precincts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: precincts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE precincts_id_seq OWNED BY precincts.id;


--
-- Name: referendums; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE referendums (
    id integer NOT NULL,
    district_id integer,
    uid character varying(255) NOT NULL,
    title character varying(255),
    subtitle text,
    question text,
    sort_order character varying(255),
    locality_id integer,
    district_type character varying(255)
);


--
-- Name: referendums_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE referendums_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referendums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE referendums_id_seq OWNED BY referendums.id;


--
-- Name: results_feed_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW results_feed_view AS
 SELECT cr.precinct_id,
    cor.contest_id,
    NULL::numeric AS referendum_id,
    co.office AS contest,
    ca.name AS candidate,
    p.name AS party,
    cr.votes,
    ca.sort_order
   FROM candidate_results cr,
    contest_results cor,
    contests co,
    candidates ca,
    parties p
  WHERE ((((cor.id = cr.contest_result_id) AND (co.id = cor.contest_id)) AND (ca.id = cr.candidate_id)) AND (p.id = ca.party_id))
UNION ALL
 SELECT brr.precinct_id,
    NULL::integer AS contest_id,
    cor.referendum_id,
    re.title AS contest,
    br.name AS candidate,
    ''::character varying AS party,
    brr.votes,
    br.sort_order
   FROM ballot_response_results brr,
    contest_results cor,
    referendums re,
    ballot_responses br
  WHERE (((cor.id = brr.contest_result_id) AND (br.id = brr.ballot_response_id)) AND (re.id = cor.referendum_id))
UNION ALL
 SELECT cor.precinct_id,
    cor.contest_id,
    NULL::numeric AS referendum_id,
    co.office AS contest,
    v.candidate,
    ''::character varying AS party,
    0 AS votes,
    v.sort_order
   FROM contest_results cor,
    contests co,
    ( SELECT 'OVERVOTES'::text AS candidate,
            9999 AS sort_order
        UNION ALL
         SELECT 'UNDERVOTES'::text,
            9998) v
  WHERE (co.id = cor.contest_id)
UNION ALL
 SELECT cor.precinct_id,
    NULL::integer AS contest_id,
    cor.referendum_id,
    re.title AS contest,
    v.candidate,
    ''::character varying AS party,
    0 AS votes,
    v.sort_order
   FROM contest_results cor,
    referendums re,
    ( SELECT 'OVERVOTES'::text AS candidate,
            9999 AS sort_order
        UNION ALL
         SELECT 'UNDERVOTES'::text,
            9998) v
  WHERE (re.id = cor.referendum_id);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    uid character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255)
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: voter_registration_classifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE voter_registration_classifications (
    id integer NOT NULL,
    voter_registration_id integer,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: voter_registration_classifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE voter_registration_classifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: voter_registration_classifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE voter_registration_classifications_id_seq OWNED BY voter_registration_classifications.id;


--
-- Name: voter_registrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE voter_registrations (
    id integer NOT NULL,
    precinct_id integer,
    date_of_birth character varying(255),
    phone character varying(255),
    race character varying(255),
    sex character varying(255),
    party character varying(255),
    voter_id_type character varying(255),
    voter_id_value character varying(255),
    registration_address character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uid character varying(255) NOT NULL,
    is_citizen boolean DEFAULT false NOT NULL,
    is_eighteen_election_day boolean DEFAULT false NOT NULL,
    is_election_absentee boolean DEFAULT false NOT NULL,
    is_residing_at_registration_address boolean DEFAULT false NOT NULL,
    is_active_duty_uniformed_services boolean DEFAULT false NOT NULL,
    is_permanent_absetee boolean DEFAULT false NOT NULL,
    is_eligible_military_spouse_or_dependent boolean DEFAULT false NOT NULL,
    is_residing_abroad_uncertain_return boolean DEFAULT false NOT NULL,
    voter_outcome character varying(255),
    voter_rejected_reason character varying(255)
);


--
-- Name: voter_registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE voter_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: voter_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE voter_registrations_id_seq OWNED BY voter_registrations.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ballot_response_results ALTER COLUMN id SET DEFAULT nextval('ballot_response_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ballot_responses ALTER COLUMN id SET DEFAULT nextval('ballot_responses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY candidate_results ALTER COLUMN id SET DEFAULT nextval('candidate_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY candidates ALTER COLUMN id SET DEFAULT nextval('candidates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contest_results ALTER COLUMN id SET DEFAULT nextval('contest_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contests ALTER COLUMN id SET DEFAULT nextval('contests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY districts ALTER COLUMN id SET DEFAULT nextval('districts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY elections ALTER COLUMN id SET DEFAULT nextval('elections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY localities ALTER COLUMN id SET DEFAULT nextval('localities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY parties ALTER COLUMN id SET DEFAULT nextval('parties_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_locations ALTER COLUMN id SET DEFAULT nextval('polling_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY precincts ALTER COLUMN id SET DEFAULT nextval('precincts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY referendums ALTER COLUMN id SET DEFAULT nextval('referendums_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY voter_registration_classifications ALTER COLUMN id SET DEFAULT nextval('voter_registration_classifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY voter_registrations ALTER COLUMN id SET DEFAULT nextval('voter_registrations_id_seq'::regclass);


--
-- Name: ballot_response_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ballot_response_results
    ADD CONSTRAINT ballot_response_results_pkey PRIMARY KEY (id);


--
-- Name: ballot_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ballot_responses
    ADD CONSTRAINT ballot_responses_pkey PRIMARY KEY (id);


--
-- Name: candidates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY candidates
    ADD CONSTRAINT candidates_pkey PRIMARY KEY (id);


--
-- Name: contest_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contest_results
    ADD CONSTRAINT contest_results_pkey PRIMARY KEY (id);


--
-- Name: contests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contests
    ADD CONSTRAINT contests_pkey PRIMARY KEY (id);


--
-- Name: districts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- Name: elections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY elections
    ADD CONSTRAINT elections_pkey PRIMARY KEY (id);


--
-- Name: localities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY localities
    ADD CONSTRAINT localities_pkey PRIMARY KEY (id);


--
-- Name: parties_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY parties
    ADD CONSTRAINT parties_pkey PRIMARY KEY (id);


--
-- Name: polling_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY polling_locations
    ADD CONSTRAINT polling_locations_pkey PRIMARY KEY (id);


--
-- Name: precincts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY precincts
    ADD CONSTRAINT precincts_pkey PRIMARY KEY (id);


--
-- Name: referendums_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY referendums
    ADD CONSTRAINT referendums_pkey PRIMARY KEY (id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: voter_registration_classifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY voter_registration_classifications
    ADD CONSTRAINT voter_registration_classifications_pkey PRIMARY KEY (id);


--
-- Name: voter_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY voter_registrations
    ADD CONSTRAINT voter_registrations_pkey PRIMARY KEY (id);


--
-- Name: voting_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY candidate_results
    ADD CONSTRAINT voting_results_pkey PRIMARY KEY (id);


--
-- Name: index_ballot_response_results_on_ballot_response_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ballot_response_results_on_ballot_response_id ON ballot_response_results USING btree (ballot_response_id);


--
-- Name: index_ballot_response_results_on_contest_result_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ballot_response_results_on_contest_result_id ON ballot_response_results USING btree (contest_result_id);


--
-- Name: index_ballot_response_results_on_precinct_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ballot_response_results_on_precinct_id ON ballot_response_results USING btree (precinct_id);


--
-- Name: index_ballot_response_results_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ballot_response_results_on_uid ON ballot_response_results USING btree (uid);


--
-- Name: index_ballot_responses_on_referendum_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ballot_responses_on_referendum_id ON ballot_responses USING btree (referendum_id);


--
-- Name: index_ballot_responses_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_ballot_responses_on_uid ON ballot_responses USING btree (uid);


--
-- Name: index_candidate_results_on_candidate_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_candidate_results_on_candidate_id ON candidate_results USING btree (candidate_id);


--
-- Name: index_candidate_results_on_contest_result_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_candidate_results_on_contest_result_id ON candidate_results USING btree (contest_result_id);


--
-- Name: index_candidate_results_on_precinct_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_candidate_results_on_precinct_id ON candidate_results USING btree (precinct_id);


--
-- Name: index_candidate_results_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_candidate_results_on_uid ON candidate_results USING btree (uid);


--
-- Name: index_candidates_on_contest_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_candidates_on_contest_id ON candidates USING btree (contest_id);


--
-- Name: index_candidates_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_candidates_on_uid ON candidates USING btree (uid);


--
-- Name: index_contest_results_on_contest_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contest_results_on_contest_id ON contest_results USING btree (contest_id);


--
-- Name: index_contest_results_on_precinct_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contest_results_on_precinct_id ON contest_results USING btree (precinct_id);


--
-- Name: index_contest_results_on_referendum_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contest_results_on_referendum_id ON contest_results USING btree (referendum_id);


--
-- Name: index_contest_results_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contest_results_on_uid ON contest_results USING btree (uid);


--
-- Name: index_contests_on_district_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contests_on_district_id ON contests USING btree (district_id);


--
-- Name: index_contests_on_district_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contests_on_district_type ON contests USING btree (district_type);


--
-- Name: index_contests_on_election_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contests_on_election_id ON contests USING btree (election_id);


--
-- Name: index_contests_on_locality_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contests_on_locality_id ON contests USING btree (locality_id);


--
-- Name: index_contests_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_contests_on_uid ON contests USING btree (uid);


--
-- Name: index_districts_on_locality_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_districts_on_locality_id ON districts USING btree (locality_id);


--
-- Name: index_districts_on_uid_and_locality_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_districts_on_uid_and_locality_id ON districts USING btree (uid, locality_id);


--
-- Name: index_districts_precincts_on_district_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_districts_precincts_on_district_id ON districts_precincts USING btree (district_id);


--
-- Name: index_districts_precincts_on_precinct_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_districts_precincts_on_precinct_id ON districts_precincts USING btree (precinct_id);


--
-- Name: index_elections_on_state_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_elections_on_state_id ON elections USING btree (state_id);


--
-- Name: index_elections_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_elections_on_uid ON elections USING btree (uid);


--
-- Name: index_localities_on_state_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_localities_on_state_id ON localities USING btree (state_id);


--
-- Name: index_localities_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_localities_on_uid ON localities USING btree (uid);


--
-- Name: index_parties_on_locality_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_parties_on_locality_id ON parties USING btree (locality_id);


--
-- Name: index_parties_on_uid_and_locality_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_parties_on_uid_and_locality_id ON parties USING btree (uid, locality_id);


--
-- Name: index_polling_locations_on_address_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polling_locations_on_address_id ON polling_locations USING btree (address_id);


--
-- Name: index_polling_locations_on_precinct_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polling_locations_on_precinct_id ON polling_locations USING btree (precinct_id);


--
-- Name: index_precincts_on_locality_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_precincts_on_locality_id ON precincts USING btree (locality_id);


--
-- Name: index_precincts_on_precinct_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_precincts_on_precinct_id ON precincts USING btree (precinct_id);


--
-- Name: index_precincts_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_precincts_on_uid ON precincts USING btree (uid);


--
-- Name: index_referendums_on_district_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_referendums_on_district_id ON referendums USING btree (district_id);


--
-- Name: index_referendums_on_locality_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_referendums_on_locality_id ON referendums USING btree (locality_id);


--
-- Name: index_referendums_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_referendums_on_uid ON referendums USING btree (uid);


--
-- Name: index_states_on_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_states_on_code ON states USING btree (code);


--
-- Name: index_states_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_states_on_uid ON states USING btree (uid);


--
-- Name: index_voter_registrations_on_precinct_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_voter_registrations_on_precinct_id ON voter_registrations USING btree (precinct_id);


--
-- Name: index_voter_registrations_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_voter_registrations_on_uid ON voter_registrations USING btree (uid);


--
-- Name: index_vr_on_is_abroad; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_is_abroad ON voter_registrations USING btree (is_residing_abroad_uncertain_return);


--
-- Name: index_vr_on_is_absentee; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_is_absentee ON voter_registrations USING btree (is_election_absentee);


--
-- Name: index_vr_on_is_citizen; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_is_citizen ON voter_registrations USING btree (is_citizen);


--
-- Name: index_vr_on_is_eighteen; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_is_eighteen ON voter_registrations USING btree (is_eighteen_election_day);


--
-- Name: index_vr_on_is_home; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_is_home ON voter_registrations USING btree (is_residing_at_registration_address);


--
-- Name: index_vr_on_is_military; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_is_military ON voter_registrations USING btree (is_active_duty_uniformed_services);


--
-- Name: index_vr_on_is_military_dep; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_is_military_dep ON voter_registrations USING btree (is_eligible_military_spouse_or_dependent);


--
-- Name: index_vr_on_is_permane; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_is_permane ON voter_registrations USING btree (is_permanent_absetee);


--
-- Name: index_vr_on_outcome; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_outcome ON voter_registrations USING btree (voter_outcome);


--
-- Name: index_vr_on_party; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_party ON voter_registrations USING btree (party);


--
-- Name: index_vr_on_party_and_precinct; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_party_and_precinct ON voter_registrations USING btree (party, precinct_id);


--
-- Name: index_vr_on_reason; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vr_on_reason ON voter_registrations USING btree (voter_rejected_reason);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: voter_reg_class_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX voter_reg_class_index ON voter_registration_classifications USING btree (voter_registration_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20131212110520');

INSERT INTO schema_migrations (version) VALUES ('20131216112523');

INSERT INTO schema_migrations (version) VALUES ('20131216115036');

INSERT INTO schema_migrations (version) VALUES ('20131216170742');

INSERT INTO schema_migrations (version) VALUES ('20131216171053');

INSERT INTO schema_migrations (version) VALUES ('20131216171134');

INSERT INTO schema_migrations (version) VALUES ('20131216175609');

INSERT INTO schema_migrations (version) VALUES ('20131216175756');

INSERT INTO schema_migrations (version) VALUES ('20131216180804');

INSERT INTO schema_migrations (version) VALUES ('20131217130336');

INSERT INTO schema_migrations (version) VALUES ('20131217130427');

INSERT INTO schema_migrations (version) VALUES ('20131224081947');

INSERT INTO schema_migrations (version) VALUES ('20131224130152');

INSERT INTO schema_migrations (version) VALUES ('20131224133144');

INSERT INTO schema_migrations (version) VALUES ('20140103103430');

INSERT INTO schema_migrations (version) VALUES ('20140106171244');

INSERT INTO schema_migrations (version) VALUES ('20140107070101');

INSERT INTO schema_migrations (version) VALUES ('20140107070833');

INSERT INTO schema_migrations (version) VALUES ('20140107073503');

INSERT INTO schema_migrations (version) VALUES ('20140107080956');

INSERT INTO schema_migrations (version) VALUES ('20140210095146');

INSERT INTO schema_migrations (version) VALUES ('20140210100706');

INSERT INTO schema_migrations (version) VALUES ('20140226173623');

INSERT INTO schema_migrations (version) VALUES ('20140227112204');

INSERT INTO schema_migrations (version) VALUES ('20140307094204');

INSERT INTO schema_migrations (version) VALUES ('20140321100112');

INSERT INTO schema_migrations (version) VALUES ('20140324092613');

INSERT INTO schema_migrations (version) VALUES ('20140324092900');

INSERT INTO schema_migrations (version) VALUES ('20140324142355');

INSERT INTO schema_migrations (version) VALUES ('20140325120721');

INSERT INTO schema_migrations (version) VALUES ('20140327083159');

INSERT INTO schema_migrations (version) VALUES ('20140327083408');

INSERT INTO schema_migrations (version) VALUES ('20140327092652');

INSERT INTO schema_migrations (version) VALUES ('20140327102215');

INSERT INTO schema_migrations (version) VALUES ('20140327173617');

INSERT INTO schema_migrations (version) VALUES ('20140331182245');

INSERT INTO schema_migrations (version) VALUES ('20140401123339');

INSERT INTO schema_migrations (version) VALUES ('20140402102246');

INSERT INTO schema_migrations (version) VALUES ('20140409183226');

INSERT INTO schema_migrations (version) VALUES ('20140416044538');

INSERT INTO schema_migrations (version) VALUES ('20140428181530');

INSERT INTO schema_migrations (version) VALUES ('20140430071457');

INSERT INTO schema_migrations (version) VALUES ('20150304142413');

INSERT INTO schema_migrations (version) VALUES ('20150324134710');

INSERT INTO schema_migrations (version) VALUES ('20150624102912');

INSERT INTO schema_migrations (version) VALUES ('20150624104722');

INSERT INTO schema_migrations (version) VALUES ('20150624111229');

INSERT INTO schema_migrations (version) VALUES ('20160313222221');

INSERT INTO schema_migrations (version) VALUES ('20160313222329');

INSERT INTO schema_migrations (version) VALUES ('20160316151449');

INSERT INTO schema_migrations (version) VALUES ('20160316153123');

INSERT INTO schema_migrations (version) VALUES ('20160317160439');

INSERT INTO schema_migrations (version) VALUES ('20160603011358');

INSERT INTO schema_migrations (version) VALUES ('20160603110908');

INSERT INTO schema_migrations (version) VALUES ('20160617020513');

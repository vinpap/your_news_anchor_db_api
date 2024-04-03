--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2 (Ubuntu 16.2-1.pgdg22.04+1)

-- Started on 2024-04-03 11:10:04 CEST

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

DROP DATABASE your_news_anchor;
--
-- TOC entry 3979 (class 1262 OID 24730)
-- Name: your_news_anchor; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE your_news_anchor WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


\connect your_news_anchor

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
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- TOC entry 3980 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 24731)
-- Name: daily_articles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_articles (
    id integer NOT NULL,
    title character varying NOT NULL,
    url character varying NOT NULL,
    content character varying NOT NULL,
    date time without time zone NOT NULL,
    author character varying,
    image character varying,
    standard_source_id integer,
    is_from_user boolean DEFAULT false NOT NULL,
    user_source_id integer
);


--
-- TOC entry 216 (class 1259 OID 24734)
-- Name: daily_articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.daily_articles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3981 (class 0 OID 0)
-- Dependencies: 216
-- Name: daily_articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.daily_articles_id_seq OWNED BY public.daily_articles.id;


--
-- TOC entry 224 (class 1259 OID 24771)
-- Name: daily_recaps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_recaps (
    id integer NOT NULL,
    article_id integer NOT NULL,
    recap character varying NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 24770)
-- Name: daily_recaps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.daily_recaps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3982 (class 0 OID 0)
-- Dependencies: 223
-- Name: daily_recaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.daily_recaps_id_seq OWNED BY public.daily_recaps.id;


--
-- TOC entry 218 (class 1259 OID 24744)
-- Name: standard_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.standard_sources (
    id integer NOT NULL,
    url character varying NOT NULL,
    language character varying NOT NULL,
    name character varying NOT NULL,
    topic character varying
);


--
-- TOC entry 217 (class 1259 OID 24743)
-- Name: standard_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.standard_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3983 (class 0 OID 0)
-- Dependencies: 217
-- Name: standard_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.standard_sources_id_seq OWNED BY public.standard_sources.id;


--
-- TOC entry 220 (class 1259 OID 24753)
-- Name: user_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_sources (
    id integer NOT NULL,
    user_id integer NOT NULL,
    url character varying NOT NULL,
    language character varying NOT NULL,
    topic character varying,
    name character varying NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 24752)
-- Name: user_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3984 (class 0 OID 0)
-- Dependencies: 219
-- Name: user_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_sources_id_seq OWNED BY public.user_sources.id;


--
-- TOC entry 222 (class 1259 OID 24762)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    password_hash character varying NOT NULL,
    is_admin boolean NOT NULL,
    creation_date date NOT NULL,
    username character varying NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 24761)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3985 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3801 (class 2604 OID 24735)
-- Name: daily_articles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_articles ALTER COLUMN id SET DEFAULT nextval('public.daily_articles_id_seq'::regclass);


--
-- TOC entry 3806 (class 2604 OID 24774)
-- Name: daily_recaps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_recaps ALTER COLUMN id SET DEFAULT nextval('public.daily_recaps_id_seq'::regclass);


--
-- TOC entry 3803 (class 2604 OID 24747)
-- Name: standard_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.standard_sources ALTER COLUMN id SET DEFAULT nextval('public.standard_sources_id_seq'::regclass);


--
-- TOC entry 3804 (class 2604 OID 24756)
-- Name: user_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sources ALTER COLUMN id SET DEFAULT nextval('public.user_sources_id_seq'::regclass);


--
-- TOC entry 3805 (class 2604 OID 24765)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3964 (class 0 OID 24731)
-- Dependencies: 215
-- Data for Name: daily_articles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.daily_articles (id, title, url, content, date, author, image, standard_source_id, is_from_user, user_source_id) FROM stdin;
\.


--
-- TOC entry 3973 (class 0 OID 24771)
-- Dependencies: 224
-- Data for Name: daily_recaps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.daily_recaps (id, article_id, recap) FROM stdin;
\.


--
-- TOC entry 3967 (class 0 OID 24744)
-- Dependencies: 218
-- Data for Name: standard_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.standard_sources (id, url, language, name, topic) FROM stdin;
\.


--
-- TOC entry 3969 (class 0 OID 24753)
-- Dependencies: 220
-- Data for Name: user_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_sources (id, user_id, url, language, topic, name) FROM stdin;
\.


--
-- TOC entry 3971 (class 0 OID 24762)
-- Dependencies: 222
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, password_hash, is_admin, creation_date, username) FROM stdin;
3	hash	t	2024-01-01	admin
\.


--
-- TOC entry 3986 (class 0 OID 0)
-- Dependencies: 216
-- Name: daily_articles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.daily_articles_id_seq', 1, false);


--
-- TOC entry 3987 (class 0 OID 0)
-- Dependencies: 223
-- Name: daily_recaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.daily_recaps_id_seq', 1, false);


--
-- TOC entry 3988 (class 0 OID 0)
-- Dependencies: 217
-- Name: standard_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.standard_sources_id_seq', 1, false);


--
-- TOC entry 3989 (class 0 OID 0)
-- Dependencies: 219
-- Name: user_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_sources_id_seq', 1, false);


--
-- TOC entry 3990 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- TOC entry 3808 (class 2606 OID 24740)
-- Name: daily_articles daily_articles_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_articles
    ADD CONSTRAINT daily_articles_pk PRIMARY KEY (id);


--
-- TOC entry 3816 (class 2606 OID 24779)
-- Name: daily_recaps daily_recaps_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_recaps
    ADD CONSTRAINT daily_recaps_pk PRIMARY KEY (id);


--
-- TOC entry 3810 (class 2606 OID 24751)
-- Name: standard_sources standard_sources_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.standard_sources
    ADD CONSTRAINT standard_sources_pk PRIMARY KEY (id);


--
-- TOC entry 3812 (class 2606 OID 24760)
-- Name: user_sources user_sources_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sources
    ADD CONSTRAINT user_sources_pk PRIMARY KEY (id);


--
-- TOC entry 3814 (class 2606 OID 24769)
-- Name: users users_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pk PRIMARY KEY (id);


--
-- TOC entry 3817 (class 2606 OID 24807)
-- Name: daily_articles daily_articles_standard_sources_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_articles
    ADD CONSTRAINT daily_articles_standard_sources_fk FOREIGN KEY (standard_source_id) REFERENCES public.standard_sources(id);


--
-- TOC entry 3818 (class 2606 OID 24812)
-- Name: daily_articles daily_articles_user_sources_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_articles
    ADD CONSTRAINT daily_articles_user_sources_fk FOREIGN KEY (user_source_id) REFERENCES public.user_sources(id);


--
-- TOC entry 3820 (class 2606 OID 24780)
-- Name: daily_recaps daily_recaps_daily_articles_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_recaps
    ADD CONSTRAINT daily_recaps_daily_articles_fk FOREIGN KEY (article_id) REFERENCES public.daily_articles(id);


--
-- TOC entry 3819 (class 2606 OID 24795)
-- Name: user_sources user_sources_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sources
    ADD CONSTRAINT user_sources_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


-- Completed on 2024-04-03 11:10:06 CEST

--
-- PostgreSQL database dump complete
--


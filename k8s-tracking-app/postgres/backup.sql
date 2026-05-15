--
-- PostgreSQL database cluster dump
--

\restrict 0Ma5PJ12DNI9U4yR4gmsczWsrOe44RN1VyTgiCiPZEqTOZXhK4IA3CtRWm4eaeN

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE budget_user;
ALTER ROLE budget_user WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:d2RubLgvfeI+6jsjW1NtfQ==$cPQFulKOROBINjDMgomEDoP495alMibMbh+Syx4MSUU=:aaEAQD9CkFSEk7HmP6OHN4KAA2yt0HqowdKq7TSaYig=';






\unrestrict 0Ma5PJ12DNI9U4yR4gmsczWsrOe44RN1VyTgiCiPZEqTOZXhK4IA3CtRWm4eaeN

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict TCQgk2bnyWtrUgLZJeR8cGdtWnGKlf9k2YF2Nrb8SphbgWjhJduhVh9HzFaplCP

-- Dumped from database version 14.22 (Debian 14.22-1.pgdg13+1)
-- Dumped by pg_dump version 14.22 (Debian 14.22-1.pgdg13+1)

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
-- PostgreSQL database dump complete
--

\unrestrict TCQgk2bnyWtrUgLZJeR8cGdtWnGKlf9k2YF2Nrb8SphbgWjhJduhVh9HzFaplCP

--
-- Database "budget_db" dump
--

--
-- PostgreSQL database dump
--

\restrict 0udYF11EbI1hfDTKlwfLQ0GBZRGauX4I3ainQWJdF9jYXUg8UBFqt7RaSYVtF0b

-- Dumped from database version 14.22 (Debian 14.22-1.pgdg13+1)
-- Dumped by pg_dump version 14.22 (Debian 14.22-1.pgdg13+1)

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
-- Name: budget_db; Type: DATABASE; Schema: -; Owner: budget_user
--

CREATE DATABASE budget_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';


ALTER DATABASE budget_db OWNER TO budget_user;

\unrestrict 0udYF11EbI1hfDTKlwfLQ0GBZRGauX4I3ainQWJdF9jYXUg8UBFqt7RaSYVtF0b
\connect budget_db
\restrict 0udYF11EbI1hfDTKlwfLQ0GBZRGauX4I3ainQWJdF9jYXUg8UBFqt7RaSYVtF0b

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: budget_user
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO budget_user;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: budget_user
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    color character varying(7) NOT NULL,
    CONSTRAINT check_category_name_not_empty CHECK ((length((name)::text) > 0))
);


ALTER TABLE public.categories OWNER TO budget_user;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: budget_user
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_id_seq OWNER TO budget_user;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: budget_user
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: food_item; Type: TABLE; Schema: public; Owner: budget_user
--

CREATE TABLE public.food_item (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    base_amount double precision NOT NULL,
    calories double precision NOT NULL,
    protein double precision NOT NULL,
    fiber double precision NOT NULL,
    fat double precision,
    sodium double precision
);


ALTER TABLE public.food_item OWNER TO budget_user;

--
-- Name: food_item_id_seq; Type: SEQUENCE; Schema: public; Owner: budget_user
--

CREATE SEQUENCE public.food_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.food_item_id_seq OWNER TO budget_user;

--
-- Name: food_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: budget_user
--

ALTER SEQUENCE public.food_item_id_seq OWNED BY public.food_item.id;


--
-- Name: log_entry; Type: TABLE; Schema: public; Owner: budget_user
--

CREATE TABLE public.log_entry (
    id integer NOT NULL,
    user_id integer NOT NULL,
    food_id integer NOT NULL,
    amount double precision NOT NULL,
    unit character varying(10),
    calories double precision,
    protein double precision,
    fiber double precision,
    fat double precision,
    sodium double precision,
    "timestamp" timestamp without time zone
);


ALTER TABLE public.log_entry OWNER TO budget_user;

--
-- Name: log_entry_id_seq; Type: SEQUENCE; Schema: public; Owner: budget_user
--

CREATE SEQUENCE public.log_entry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_entry_id_seq OWNER TO budget_user;

--
-- Name: log_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: budget_user
--

ALTER SEQUENCE public.log_entry_id_seq OWNED BY public.log_entry.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: budget_user
--

CREATE TABLE public.transactions (
    id integer NOT NULL,
    description character varying(200) NOT NULL,
    amount numeric(10,2) NOT NULL,
    date date,
    category_id integer
);


ALTER TABLE public.transactions OWNER TO budget_user;

--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: budget_user
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transactions_id_seq OWNER TO budget_user;

--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: budget_user
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: budget_user
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    calorie_goal double precision,
    protein_goal double precision,
    fiber_goal double precision,
    day_start_time time without time zone,
    day_end_time time without time zone
);


ALTER TABLE public."user" OWNER TO budget_user;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: budget_user
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO budget_user;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: budget_user
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: food_item id; Type: DEFAULT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.food_item ALTER COLUMN id SET DEFAULT nextval('public.food_item_id_seq'::regclass);


--
-- Name: log_entry id; Type: DEFAULT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.log_entry ALTER COLUMN id SET DEFAULT nextval('public.log_entry_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: budget_user
--

COPY public.alembic_version (version_num) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: budget_user
--

COPY public.categories (id, name, color) FROM stdin;
1	Other	#efb2ec
2	Entertainment	#e48ac3
3	Restaurant	#b5f3a7
4	Grocery	#926fd3
5	Gas	#695ee4
6	Vending	#bcb9f6
7	Restaurants	#eb7fdd
8	Schoolcafe	#8eb0e5
9	Shoes	#ebd69e
10	Medical	#e8d186
11	Clothing	#ee996f
12	Sports	#d378c8
13	Coffee	#e19f81
14	Supplements	#a8eecc
15	Pharmacy	#b5f1d7
16	Eztag	#9ee2f0
17	Parking	#b883e9
18	Misc	#dc64ae
\.


--
-- Data for Name: food_item; Type: TABLE DATA; Schema: public; Owner: budget_user
--

COPY public.food_item (id, name, base_amount, calories, protein, fiber, fat, sodium) FROM stdin;
1	celery juice	100	40	1	0	0	0
2	collagen	100	40	10	0	0	0
3	Yogurt	100	115	8	0	0	0
4	ezekial cinnamon raisin	100	80	4	2	0	0
5	Eggs	100	240	18	0	0	0
6	butter	100	100	0	0	0	0
7	dark chocolate	100	140	3	4	0	0
8	pistachios	100	170	6	3	0	0
9	dark chocolate almond clusters	100	150	4	3	0	0
10	Apple Large	100	140	1	5	0	0
11	Cava	100	800	30	10	0	0
12	blackberries	100	45	5	1	0	0
13	Sour Kraut	100	5	0	0	0	0
14	chicken pack	100	140	24	0	0	0
15	pumpkin seeds	100	90	4	1	0	0
16	potatoes roasted	100	150	2	2	0	0
17	slider bun	100	90	4	1	0	0
18	kraft single	100	50	3	0	0	0
19	pan fried chicken	100	300	20	0	0	0
20	Mac	100	160	7	1	0	0
21	Chia Seeds	100	160	6	10	0	0
22	ezekial almond cereal	100	190	8	6	0	0
23	milk	100	150	8	0	0	0
24	thai fresh	100	300	5	1	0	0
25	pizza	100	300	12	0	0	0
26	Greenhouse Shake	100	180	20	4	0	0
27	miso tofu	100	110	13	2	0	0
28	flax seeds	100	150	5	8	0	0
29	parmesan	100	120	11	0	0	0
30	japanese bbq sauce	100	35	0	0	0	0
31	tofu pressed	100	150	15	4	0	0
32	rice	100	310	6	3	0	0
33	Veggie Grain Soup	100	200	6	6	0	0
34	Cheddar Bay	100	190	2	0	0	0
35	Baguette	100	270	8	2	0	0
36	raspberries	100	50	1	6.5	0	0
37	walking tamale	100	250	6	5	0	0
38	lunch kit	100	260	12	1	0	0
39	P Terrys veggie burger	100	408	12	8	0	0
40	ezekial flax bread	100	80	5	3	0	0
41	olive oil	100	120	0	0	0	0
42	turkey	100	60	13	0	0	0
43	provolone cheese	100	100	7	0	0	0
44	sourdough bread	100	150	5	1	0	0
45	dark chocolate raspberry	100	220	4	4	0	0
46	Greenhouse vanilla shake	100	180	20	4	0	0
47	Koia drink Shake	100	190	18	7	0	0
48	pizza hut thin veggie large	100	230	11	3	0	0
49	salad	100	100	4	1	0	0
50	Bone broth bare bones pack	100	50	10	0	0	0
51	drumroll donut	100	190	10	3	0	0
52	blueberries	100	60	0.8	2.6	0	0
53	protein powder	100	120	21	0	0	0
54	french green lentils	100	260	16	14	0	0
55	taco cabana black bean taco	100	220	7	5	0	0
56	archers mango habanero jerky	100	160	22	0	0	0
57	sushi	100	50	2	0.5	0	0
58	Walking tamale blue	100	190	0	0	0	0
59	Fair life chocolate milk	100	250	23	1	0	0
60	pirates booty	100	530	7	0	0	0
61	charro beans	100	250	14	8	0	0
62	no manches veggie taco corn tortilla	100	300	10	5	0	0
63	yellow dal	100	105	5	4	0	0
64	pretzel bread	100	140	3	1	0	0
65	kale salad raquel	100	800	16	16	0	0
66	red dal	100	420	20	16	0	0
67	red dal lentils	100	315	15	12	0	0
68	lesser evil popcorn	100	60	1	2	0	0
69	hamburger patty	100	275	19	0	0	0
70	martins sandwich roll bun	100	130	6	1	0	0
71	broccoli cooked w ghee	100	80	3	3	0	0
72	galaxy salmon dish	100	800	40	6	0	0
73	jimmy johns turkey and cheese	100	500	40	2	0	0
74	watermelon	100	60	0	1	0	0
75	refried beans	100	150	8	5	0	0
76	tortilla flour HEB	100	100	3	1	0	0
77	Apple medium	100	120	1	4	0	0
78	Hot dog w bun	100	280	15	1	0	0
79	logans roadhouse 1/4	100	800	40	3	0	0
80	chocolate	100	50	1	1	0	0
81	impossible hot dog	100	120	12	0	0	0
82	chipotle	100	150	4	2	0	0
83	Raw shake	100	150	30	1	0	0
85	Goodles cheddy mac	100	500	21	10	0	0
86	tortilla flour HEB homestyle	100	120	3	1	0	0
89	candy	100	100	0	0	0	0
91	Whopper Jr	100	500	17	3	0	0
92	popcorn	100	120	2	4	0	0
93	pizza hut medium hand tossed	100	250	10	2	0	0
95	Bagel chips	100	130	4	1	0	0
97	Pretel bites	100	120	2	0	0	0
98	Taco cabana bean cheese	100	300	10	4	0	0
99	boba muffin	100	160	3	2	0	0
104	clif bar banana peanut butter	100	260	10	5	0	0
105	Fair life chocolate milk 26	100	170	26	2	0	0
84	calories	100	300	0	0	0	0
87	monterrey jack cheese	100	100	7	0	0	0
88	panda	100	300	5	0	0	0
90	pigs in blanket	100	500	20	2	0	0
94	Honey roasted cashews	100	150	4	0	0	0
96	yellow thai curry	100	800	20	5	0	0
100	little hat creek	100	400	20	2	0	0
101	rosarita refried beans	100	100	5	5	0	0
102	rocher square	100	60	2	2	0	0
103	raos meatball	100	100	6.5	1	0	0
106	Cornbread	100	250	5	4	0	0
107	pinto beans cracker barrell	100	150	8	6	0	0
108	cracker barrell side corn	100	160	3	3	0	0
109	cracker barrell side carrots	100	100	1	3	0	0
110	cracker barrell side green beans	100	80	2	2	0	0
111	tortilla chips	100	140	2	1	0	0
112	Chipotle Pinto beans	100	250	15	15	0	0
113	amys baked beans	100	170	8	9	0	0
114	fried chicken liver	100	120	11	0	0	0
115	american cheese	100	75	3	0	0	0
116	ritz	100	70	1	0	0	0
117	siete ranchero beans	100	150	7	5	0	0
118	asparagus	100	20	2	2	0	0
119	avacado	100	110	1.5	5	0	0
120	mango	100	30	0.3	0.8	0	0
121	Pf ChangS	100	1200	40	0	0	0
122	cheese stick	100	80	7	0	0	0
123	spaghetti w/ olive oil	100	400	10	2	0	0
124	egg white bites	100	160	11	1	0	0
125	chicken grilled	100	165	31	0	0	0
126	wundershowzen	100	400	11	8	0	0
127	Ike’s turkey and cheese	100	1300	40	3	0	0
128	hat creek veggie burger	100	550	15	5	0	0
129	Sushi philly roll	100	480	13	5	0	0
130	brisket lean	100	800	100	0	0	0
131	brisket fatty	100	1400	80	0	0	0
132	Kung Pao Tofu	100	600	20	5	0	0
133	sausage egg taco clem	100	600	25	2	0	0
134	Peanuts	100	400	17	6	0	0
135	Bbq chicken plate Texas Roadhouse	100	900	60	12	0	0
136	Roll	100	120	0	0	0	0
137	babybel	100	70	5	0	0	0
138	Miltons pizza	100	120	4	1	0	0
139	taco deli freakin vegan	100	350	7	6	0	0
140	annies mac instant	100	220	7	3	0	0
141	Subway Turkey and. Cheese	100	400	26	3	0	0
142	Simply vegan ramen	100	1000	25	5	0	0
143	Freddys veggie burger	100	500	22	10	0	0
144	chicken maple breakfast bite	100	140	14	0	0	0
145	thundercloud veggie delite	100	600	20	12	0	0
\.


--
-- Data for Name: log_entry; Type: TABLE DATA; Schema: public; Owner: budget_user
--

COPY public.log_entry (id, user_id, food_id, amount, unit, calories, protein, fiber, fat, sodium, "timestamp") FROM stdin;
1	3	1	16	oz	40	1	0	\N	\N	2026-02-17 09:34:19.240995
2	3	2	11	g	40	10	0	\N	\N	2026-02-17 09:35:10.986376
4	3	3	300	g	202.9	14.1	0	\N	\N	2026-02-17 10:13:47.736264
5	3	4	1	slice	80	4	2	\N	\N	2026-02-17 11:16:35.313861
6	3	4	1	slice	80	4	2	\N	\N	2026-02-17 11:16:44.240307
7	3	5	3	egg	240	18	0	\N	\N	2026-02-17 11:18:34.082538
8	3	6	1	tbsp	100	0	0	\N	\N	2026-02-17 11:18:59.992744
10	3	7	18	g	84	1.8	2.4	\N	\N	2026-02-17 12:09:08.195223
11	3	7	18	g	84	1.8	2.4	\N	\N	2026-02-17 13:19:11.886372
13	3	8	125	g	354.2	12.5	6.3	\N	\N	2026-02-17 14:32:04.590905
14	3	9	30	g	150	4	3	\N	\N	2026-02-17 14:46:24.797146
15	3	10	1	apple	140	1	5	\N	\N	2026-02-17 16:45:39.196797
16	3	11	1	bowl	800	30	10	\N	\N	2026-02-17 19:52:44.855603
17	3	1	16	oz	40	1	0	\N	\N	2026-02-18 09:12:18.28263
18	3	3	300	g	202.9	14.1	0	\N	\N	2026-02-18 09:36:16.962576
19	3	12	100	g	45	5	1	\N	\N	2026-02-18 09:37:24.714749
20	3	7	18	g	84	1.8	2.4	\N	\N	2026-02-18 09:51:28.913521
21	3	4	1	slice	80	4	2	\N	\N	2026-02-18 11:51:33.917508
22	3	5	3	egg	240	18	0	\N	\N	2026-02-18 11:51:46.530618
23	3	6	0.4	tbsp	40	0	0	\N	\N	2026-02-18 11:51:59.909841
24	3	2	11	g	40	10	0	\N	\N	2026-02-18 13:10:51.58462
25	3	7	18	g	84	1.8	2.4	\N	\N	2026-02-18 13:11:00.70687
27	3	13	60	g	10.7	0	0	\N	\N	2026-02-18 14:34:44.116761
28	3	14	1	pack	140	24	0	\N	\N	2026-02-18 14:41:56.209483
29	3	8	100	g	283.4	10	5	\N	\N	2026-02-18 15:48:25.936509
30	3	10	1	apple	140	1	5	\N	\N	2026-02-18 16:13:14.794716
31	3	15	15	g	90	4	1	\N	\N	2026-02-18 16:46:24.340825
32	3	16	100	g	150	2	2	\N	\N	2026-02-18 19:12:49.183652
33	3	17	1	bun	90	4	1	\N	\N	2026-02-18 19:48:54.558405
34	3	17	1	bun	90	4	1	\N	\N	2026-02-18 19:49:00.7396
35	3	18	1	slice	50	3	0	\N	\N	2026-02-18 19:50:08.290057
36	3	19	1	breast	300	20	0	\N	\N	2026-02-18 19:51:24.534474
37	3	19	1	breast	300	20	0	\N	\N	2026-02-18 19:52:12.641456
38	3	1	16	oz	40	1	0	\N	\N	2026-02-19 09:19:05.40453
39	3	2	11	g	40	10	0	\N	\N	2026-02-19 09:19:11.021716
40	3	3	250	g	169.1	11.8	0	\N	\N	2026-02-19 10:12:01.466466
41	3	7	18	g	84	1.8	2.4	\N	\N	2026-02-19 11:33:28.293921
42	3	5	3	egg	240	18	0	\N	\N	2026-02-19 11:58:02.50221
43	3	4	1	slice	80	4	2	\N	\N	2026-02-19 11:58:20.994322
44	3	6	0.4	tbsp	40	0	0	\N	\N	2026-02-19 11:58:30.726125
45	3	7	18	g	84	1.8	2.4	\N	\N	2026-02-19 12:56:41.748817
46	3	8	100	g	283.4	10	5	\N	\N	2026-02-19 14:17:41.90583
47	3	14	1	pack	140	24	0	\N	\N	2026-02-19 15:45:42.286465
48	3	13	60	g	10.7	0	0	\N	\N	2026-02-19 15:45:48.836902
49	3	10	1	apple	140	1	5	\N	\N	2026-02-19 16:17:11.3044
50	3	16	130	g	195	2.6	2.6	\N	\N	2026-02-19 17:14:15.115742
51	3	19	1	breast	300	20	0	\N	\N	2026-02-19 17:28:34.498201
52	3	17	1	bun	90	4	1	\N	\N	2026-02-19 17:28:47.726572
53	3	18	1	slice	50	3	0	\N	\N	2026-02-19 17:28:58.490059
54	3	17	1	bun	90	4	1	\N	\N	2026-02-19 19:24:45.983811
55	3	18	1	slice	50	3	0	\N	\N	2026-02-19 19:24:50.995893
56	3	20	100	g	160	7	1	\N	\N	2026-02-19 19:25:33.185817
57	3	1	16	oz	40	1	0	\N	\N	2026-02-20 09:03:41.791698
58	3	2	11	g	40	10	0	\N	\N	2026-02-20 09:03:50.120363
59	3	21	30	g	160	6	10	\N	\N	2026-02-20 09:47:11.514588
60	3	3	250	g	169.1	11.8	0	\N	\N	2026-02-20 09:49:06.665321
61	3	12	100	g	45	5	1	\N	\N	2026-02-20 09:49:14.582499
62	3	7	18	g	84	1.8	2.4	\N	\N	2026-02-20 10:31:16.18787
63	3	22	60	g	190	8	6	\N	\N	2026-02-20 11:44:34.591616
64	3	23	1	cup	150	8	0	\N	\N	2026-02-20 11:49:06.748128
65	3	7	18	g	84	1.8	2.4	\N	\N	2026-02-20 13:34:01.612951
66	3	8	100	g	283.4	10	5	\N	\N	2026-02-20 13:34:07.939417
67	3	24	100	g	300	5	1	\N	\N	2026-02-20 14:16:34.312955
68	3	8	50	g	141.7	5	2.5	\N	\N	2026-02-20 15:42:26.810578
69	3	25	1	slice	300	12	0	\N	\N	2026-02-20 18:27:35.092424
70	3	25	1	slice	300	12	0	\N	\N	2026-02-20 19:13:18.837149
71	3	7	18	g	84	1.8	2.4	\N	\N	2026-02-20 20:30:53.702563
72	3	26	1	bottle	180	20	4	\N	\N	2026-02-21 09:36:49.331708
73	3	2	11	g	40	10	0	\N	\N	2026-02-21 08:30:00
74	3	7	18	g	84	1.8	2.4	\N	\N	2026-02-21 12:56:10.306062
75	3	12	140	g	63	7	1.4	\N	\N	2026-02-21 13:00:57.568232
76	3	27	85	g	110	13	2	\N	\N	2026-02-21 13:26:29.09664
77	3	27	85	g	110	13	2	\N	\N	2026-02-21 13:26:43.794911
78	3	27	85	g	110	13	2	\N	\N	2026-02-21 13:26:50.375868
84	3	1	16	oz	40	1	0	\N	\N	2026-03-10 11:14:26.836616
85	3	2	11	g	40	10	0	\N	\N	2026-03-10 11:14:34.078625
86	3	28	30	g	150	5	8	\N	\N	2026-03-10 11:15:58.643355
88	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-10 11:16:23.8546
90	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-10 11:16:45.883081
91	3	3	250	g	169.1	11.8	0	\N	\N	2026-03-10 12:09:18.730995
93	3	5	3	egg	240	18	0	\N	\N	2026-03-10 13:57:18.316555
94	3	10	1	apple	140	1	5	\N	\N	2026-03-10 14:49:28.62594
99	3	33	1	bowl	200	6	6	\N	\N	2026-03-10 19:30:00
101	3	35	100	g	270	8	2	\N	\N	2026-03-10 19:30:00
104	3	28	30	g	150	5	8	\N	\N	2026-03-11 10:23:56.292697
106	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-11 10:24:08.815182
100	3	34	1	biscuit	190	2	0	\N	\N	2026-03-10 19:30:00
87	3	21	30	g	160	6	10	\N	\N	2026-03-10 11:16:05.600918
89	3	12	140	g	63	7	1.4	\N	\N	2026-03-10 11:16:35.822299
92	3	4	2	slice	160	8	4	\N	\N	2026-03-10 13:57:12.41049
95	3	29	28	g	120	11	0	\N	\N	2026-03-10 15:54:52.857842
96	3	30	19	g	35	0	0	\N	\N	2026-03-10 16:26:40.200238
97	3	31	120	g	150	15	4	\N	\N	2026-03-10 16:27:39.758499
98	3	32	210	g	310	6	3	\N	\N	2026-03-10 16:28:18.730107
102	3	35	50	g	135	4	1	\N	\N	2026-03-10 19:30:00
103	3	36	100	g	50	1	6.5	\N	\N	2026-03-11 10:23:50.141123
105	3	21	30	g	160	6	10	\N	\N	2026-03-11 10:24:03.168902
107	3	2	11	g	40	10	0	\N	\N	2026-03-11 09:25:00
108	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-11 10:26:47.040979
109	3	3	150	g	101.5	7.1	0	\N	\N	2026-03-11 12:25:46.481101
110	3	5	3	egg	240	18	0	\N	\N	2026-03-11 12:30:35.227024
111	3	4	2	slice	160	8	4	\N	\N	2026-03-11 12:30:43.295868
112	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-11 13:09:16.441003
113	3	10	1	apple	140	1	5	\N	\N	2026-03-11 14:09:27.929767
114	3	32	210	g	310	6	3	\N	\N	2026-03-11 16:37:38.098903
115	3	30	30	g	55.3	0	0	\N	\N	2026-03-11 16:37:50.882081
116	3	31	120	g	150	15	4	\N	\N	2026-03-11 16:37:56.977664
117	3	29	20	g	85.7	7.9	0	\N	\N	2026-03-11 17:59:43.771544
118	3	37	1	tamale	250	6	5	\N	\N	2026-03-11 18:36:08.964286
119	3	18	1	slice	50	3	0	\N	\N	2026-03-11 19:46:00.730165
120	3	18	1	slice	50	3	0	\N	\N	2026-03-11 19:46:00.844979
121	3	33	1	bowl	200	6	6	\N	\N	2026-03-11 20:06:12.877385
122	3	35	25	g	67.5	2	0.5	\N	\N	2026-03-11 20:06:40.7376
123	3	2	11	g	40	10	0	\N	\N	2026-03-12 10:15:54.822614
124	3	28	30	g	150	5	8	\N	\N	2026-03-12 10:16:00.150653
125	3	21	30	g	160	6	10	\N	\N	2026-03-12 10:16:05.556155
126	3	1	16	oz	40	1	0	\N	\N	2026-03-12 10:16:10.715409
127	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-12 10:16:17.237316
128	3	12	100	g	45	5	1	\N	\N	2026-03-12 10:16:24.94121
129	3	3	175	g	118.4	8.3	0	\N	\N	2026-03-12 12:44:06.430297
130	3	36	100	g	50	1	6.5	\N	\N	2026-03-12 12:44:15.221798
131	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-12 13:39:45.356496
132	3	10	1	apple	140	1	5	\N	\N	2026-03-12 13:41:43.073859
133	3	32	210	g	310	6	3	\N	\N	2026-03-12 14:56:57.620982
134	3	31	120	g	150	15	4	\N	\N	2026-03-12 14:57:03.548728
135	3	30	25	g	46.1	0	0	\N	\N	2026-03-12 14:57:13.171968
136	3	29	20	g	85.7	7.9	0	\N	\N	2026-03-12 15:52:28.761058
137	3	38	1	kit	260	12	1	\N	\N	2026-03-12 16:15:24.65171
138	3	39	1	burger	408	12	8	\N	\N	2026-03-12 18:00:17.606469
140	3	36	100	g	50	1	6.5	\N	\N	2026-03-12 20:55:00
139	3	3	150	g	101.5	7.1	0	\N	\N	2026-03-12 20:55:00
141	3	1	16	oz	40	1	0	\N	\N	2026-03-13 10:37:43.439615
142	3	2	11	g	40	10	0	\N	\N	2026-03-13 10:37:50.343638
143	3	21	30	g	160	6	10	\N	\N	2026-03-13 10:37:55.254413
144	3	28	30	g	150	5	8	\N	\N	2026-03-13 10:38:00.23983
145	3	12	100	g	45	5	1	\N	\N	2026-03-13 10:38:04.813513
146	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-13 10:38:10.874235
147	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-13 11:07:21.352923
148	3	3	250	g	169.2	11.8	0	\N	\N	2026-03-13 12:13:33.529914
149	3	40	1	slice	80	5	3	\N	\N	2026-03-13 13:17:28.372402
150	3	40	1	slice	80	5	3	\N	\N	2026-03-13 13:17:32.638353
151	3	5	3	egg	240	18	0	\N	\N	2026-03-13 13:17:00
152	3	10	1	apple	140	1	5	\N	\N	2026-03-13 15:32:39.541222
153	3	29	25	g	107.1	9.9	0	\N	\N	2026-03-13 15:47:19.684803
154	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-13 16:05:58.016431
155	3	32	210	g	310	6	3	\N	\N	2026-03-13 16:31:55.859031
156	3	31	120	g	150	15	4	\N	\N	2026-03-13 16:32:02.441798
157	3	30	25	g	46.1	0	0	\N	\N	2026-03-13 16:32:07.523898
160	3	43	28	g	100	7	0	\N	\N	2026-03-13 19:11:40.435691
162	3	44	70	g	172.1	5.7	1.1	\N	\N	2026-03-13 19:12:30.373244
163	3	42	85	g	91.1	19.7	0	\N	\N	2026-03-13 19:12:54.711995
164	3	41	10	g	92.3	0	0	\N	\N	2026-03-13 19:13:04.589355
165	3	23	1	cup	150	8	0	\N	\N	2026-03-14 08:43:55.095164
166	3	45	9	pieces	220	4	4	\N	\N	2026-03-14 09:54:22.042748
167	3	46	1	bottle	180	20	4	\N	\N	2026-03-14 09:55:42.601542
169	3	2	11	g	40	10	0	\N	\N	2026-03-14 08:30:00
170	3	44	74	g	181.9	6	1.2	\N	\N	2026-03-14 12:46:09.62127
171	3	43	28	g	100	7	0	\N	\N	2026-03-14 12:46:17.25109
172	3	42	125	g	134	29	0	\N	\N	2026-03-14 12:46:26.901984
173	3	41	7	g	64.6	0	0	\N	\N	2026-03-14 12:46:39.655135
174	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-14 13:50:19.370489
175	3	47	1	bottle	190	18	7	\N	\N	2026-03-14 15:07:00
176	3	5	3	egg	240	18	0	\N	\N	2026-03-14 15:40:18.271888
177	3	3	200	g	135.4	9.4	0	\N	\N	2026-03-14 15:40:26.708765
178	3	3	200	g	135.4	9.4	0	\N	\N	2026-03-14 16:43:10.949924
179	3	48	1	slice	230	11	3	\N	\N	2026-03-14 20:44:26.263745
180	3	48	2	slice	460	22	6	\N	\N	2026-03-14 20:44:33.917223
181	3	49	1	salad	100	4	1	\N	\N	2026-03-14 20:45:09.43504
182	3	1	16	oz	40	1	0	\N	\N	2026-03-15 10:34:46.907831
184	3	28	30	g	150	5	8	\N	\N	2026-03-15 10:57:22.072243
186	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-15 10:58:20.773791
188	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-15 11:07:09.876577
189	3	50	1	pack	50	10	0	\N	\N	2026-03-15 12:52:11.899121
190	3	39	1.3	burger	530.4	15.6	10.4	\N	\N	2026-03-15 13:37:44.860322
191	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-15 14:28:37.662546
193	3	47	1	bottle	190	18	7	\N	\N	2026-03-15 19:01:42.990987
196	3	11	0.8	bowl	640	24	8	\N	\N	2026-03-15 19:47:48.425283
197	3	1	16	oz	40	1	0	\N	\N	2026-03-16 09:00:08.382291
199	3	2	11	g	40	10	0	\N	\N	2026-03-16 09:41:46.784923
201	3	28	30	g	150	5	8	\N	\N	2026-03-16 10:45:17.80595
202	3	52	110	g	60	0.8	2.6	\N	\N	2026-03-16 10:46:14.045465
204	3	53	30	g	120	21	0	\N	\N	2026-03-16 12:09:31.909775
206	3	4	1	slice	80	4	2	\N	\N	2026-03-16 12:41:23.777152
209	3	29	30	g	128.5	11.9	0	\N	\N	2026-03-16 17:27:19.133236
213	3	54	0.3	cup	156	9.6	8.4	\N	\N	2026-03-16 19:27:04.114247
215	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-16 09:22:00
218	3	2	11	g	40	10	0	\N	\N	2026-03-17 10:58:33.951733
220	3	28	30	g	150	5	8	\N	\N	2026-03-17 10:58:44.246483
222	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-17 10:58:57.898599
183	3	2	11	g	40	10	0	\N	\N	2026-03-15 10:34:59.350945
185	3	21	30	g	160	6	10	\N	\N	2026-03-15 10:57:48.125678
187	3	12	100	g	45	5	1	\N	\N	2026-03-15 10:58:27.628504
192	3	10	1	apple	140	1	5	\N	\N	2026-03-15 17:08:09.845099
195	3	51	1	donuts	63.3	3.3	1	\N	\N	2026-03-15 19:02:26.446957
198	3	3	200	g	135.4	9.4	0	\N	\N	2026-03-16 09:41:09.195241
200	3	21	30	g	160	6	10	\N	\N	2026-03-16 10:45:10.287043
203	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-16 11:23:29.800754
205	3	5	3	egg	240	18	0	\N	\N	2026-03-16 12:41:12.650113
207	3	10	1	apple	140	1	5	\N	\N	2026-03-16 13:55:26.584278
208	3	50	1	pack	50	10	0	\N	\N	2026-03-16 17:15:28.982368
210	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-16 17:30:52.656189
211	3	54	0.5	cup	260	16	14	\N	\N	2026-03-16 17:45:08.776213
212	3	55	1	taco	220	7	5	\N	\N	2026-03-16 19:25:12.597728
214	3	29	20	g	85.7	7.9	0	\N	\N	2026-03-16 20:12:34.393362
216	3	12	100	g	45	5	1	\N	\N	2026-03-16 18:23:00
217	3	1	16	oz	40	1	0	\N	\N	2026-03-17 10:58:28.504842
219	3	21	30	g	160	6	10	\N	\N	2026-03-17 10:58:38.203392
221	3	52	100	g	54.5	0.7	2.4	\N	\N	2026-03-17 10:58:52.740899
223	3	53	30	g	120	21	0	\N	\N	2026-03-17 11:56:04.419035
224	3	4	1	slice	80	4	2	\N	\N	2026-03-17 12:49:58.72458
225	3	5	3	egg	240	18	0	\N	\N	2026-03-17 12:50:05.026252
226	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-17 13:33:34.409293
228	3	3	250	g	169.3	11.8	0	\N	\N	2026-03-17 14:13:28.893477
229	3	56	28	g	160	22	0	\N	\N	2026-03-17 17:38:43.598276
230	3	50	1	pack	50	10	0	\N	\N	2026-03-17 17:38:50.112682
231	3	29	30	g	128.6	11.9	0	\N	\N	2026-03-17 18:12:08.581372
232	3	54	0.5	cup	260	16	14	\N	\N	2026-03-17 18:38:10.48714
233	3	54	0.5	cup	260	16	14	\N	\N	2026-03-17 18:53:50.226039
234	3	54	0.2	cup	104	6.4	5.6	\N	\N	2026-03-17 19:52:11.604156
235	3	57	1	piece	50	2	0.5	\N	\N	2026-03-17 19:54:27.729519
236	3	57	1	piece	50	2	0.5	\N	\N	2026-03-17 19:59:08.428434
237	3	1	16	oz	40	1	0	\N	\N	2026-03-18 11:10:46.019795
238	3	2	11	g	40	10	0	\N	\N	2026-03-18 11:10:52.016991
239	3	21	30	g	160	6	10	\N	\N	2026-03-18 11:11:01.497676
240	3	28	30	g	150	5	8	\N	\N	2026-03-18 11:11:06.33823
241	3	52	100	g	54.5	0.7	2.4	\N	\N	2026-03-18 11:11:11.467017
242	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-18 11:11:18.078049
243	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-18 11:11:23.154349
244	3	3	200	g	135.4	9.4	0	\N	\N	2026-03-18 11:11:43.703681
245	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-18 13:03:05.847745
246	3	58	1	tamale	190	3	4	\N	\N	2026-03-18 14:17:00
247	3	59	1	bottle 	250	23	1	\N	\N	2026-03-18 15:12:33.793588
248	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-18 15:26:19.174746
250	3	60	130	g	689	9.1	0	\N	\N	2026-03-18 17:25:00
251	3	61	1	cup	250	14	8	\N	\N	2026-03-18 20:00:00
252	3	62	2	tacos	300	10	5	\N	\N	2026-03-18 20:27:00
253	3	2	11	g	40	10	0	\N	\N	2026-03-19 09:40:02.451812
254	3	21	30	g	160	6	10	\N	\N	2026-03-19 09:40:12.791412
255	3	28	30	g	150	5	8	\N	\N	2026-03-19 09:40:19.140951
256	3	12	100	g	45	5	1	\N	\N	2026-03-19 09:40:54.503041
257	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-19 09:41:00.36271
258	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-19 09:41:22.267236
259	3	53	30	g	120	21	0	\N	\N	2026-03-19 11:37:33.388106
260	3	4	1	slice	80	4	2	\N	\N	2026-03-19 12:37:15.916518
261	3	5	3	egg	240	18	0	\N	\N	2026-03-19 12:37:20.939561
262	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-19 14:27:32.505337
263	3	29	30	g	128.6	11.9	0	\N	\N	2026-03-19 14:43:45.233184
264	3	50	1	pack	50	10	0	\N	\N	2026-03-19 15:23:48.901696
265	3	3	150	g	101.6	7.1	0	\N	\N	2026-03-19 16:10:56.208102
266	3	10	1	apple	140	1	5	\N	\N	2026-03-19 16:11:20.137201
267	3	43	28	g	100	7	0	\N	\N	2026-03-19 16:30:11.195703
268	3	31	100	g	125	12.5	3.3	\N	\N	2026-03-19 16:32:16.314618
269	3	30	15	g	27.7	0	0	\N	\N	2026-03-19 16:32:29.284191
270	3	47	1	bottle	190	18	7	\N	\N	2026-03-19 17:38:33.527174
271	3	56	28	g	60	9	0	\N	\N	2026-03-19 17:40:09.25695
272	3	56	28	g	60	9	0	\N	\N	2026-03-19 17:43:33.30446
273	3	56	28	g	60	9	0	\N	\N	2026-03-19 19:08:40.819533
274	3	63	1	scoop	105	5	4	\N	\N	2026-03-19 19:28:00.154773
275	3	63	3	scoop	315	15	12	\N	\N	2026-03-19 19:28:07.274972
276	3	1	16	oz	40	1	0	\N	\N	2026-03-20 09:50:16.969801
277	3	3	200	g	135.5	9.5	0	\N	\N	2026-03-20 09:50:29.27395
278	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-20 09:50:36.950598
279	3	2	11	g	40	10	0	\N	\N	2026-03-20 09:50:50.478151
280	3	21	30	g	160	6	10	\N	\N	2026-03-20 10:57:11.216533
281	3	28	30	g	150	5	8	\N	\N	2026-03-20 10:57:16.442725
282	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-20 10:57:21.096973
283	3	52	100	g	54.5	0.7	2.4	\N	\N	2026-03-20 10:57:28.3874
284	3	5	3	egg	240	18	0	\N	\N	2026-03-20 12:40:14.036338
285	3	4	1	slice	80	4	2	\N	\N	2026-03-20 12:40:27.103406
286	3	63	2	scoop	210	10	8	\N	\N	2026-03-20 14:12:51.581539
287	3	56	25	g	53.6	8	0	\N	\N	2026-03-20 14:16:22.272407
288	3	64	40	g	140	3	1	\N	\N	2026-03-20 16:38:45.926954
289	3	63	3	scoop	315	15	12	\N	\N	2026-03-20 18:31:21.692432
290	3	56	30	g	64.3	9.6	0	\N	\N	2026-03-20 19:23:50.912799
291	3	50	1	pack	50	10	0	\N	\N	2026-03-20 19:25:55.238587
292	3	10	1	apple	140	1	5	\N	\N	2026-03-20 19:40:10.317979
293	3	63	2	scoop	210	10	8	\N	\N	2026-03-20 20:38:22.20524
294	3	45	9	pieces	220	4	4	\N	\N	2026-03-21 09:54:00.437862
295	3	47	1	bottle	190	18	7	\N	\N	2026-03-21 09:54:24.821946
296	3	1	16	oz	40	1	0	\N	\N	2026-03-21 09:54:37.841315
297	3	3	200	g	135.5	9.5	0	\N	\N	2026-03-21 10:17:15.435529
299	3	65	80	g	228.6	4.6	4.6	\N	\N	2026-03-21 11:41:25.416481
300	3	16	100	g	150	2	2	\N	\N	2026-03-21 11:55:56.509634
301	3	44	35	g	86	2.8	0.6	\N	\N	2026-03-21 13:56:50.398741
302	3	42	80	g	85.8	18.6	0	\N	\N	2026-03-21 13:56:58.278244
303	3	43	14	g	50	3.5	0	\N	\N	2026-03-21 13:57:10.977151
304	3	41	3	g	27.7	0	0	\N	\N	2026-03-21 13:57:24.400941
305	3	56	32	g	68.6	10.2	0	\N	\N	2026-03-21 15:04:34.644376
306	3	10	1	apple	140	1	5	\N	\N	2026-03-21 15:05:31.5417
307	3	50	1	pack	50	10	0	\N	\N	2026-03-21 15:49:29.883656
308	3	31	100	g	125	12.5	3.3	\N	\N	2026-03-21 16:17:16.779238
309	3	30	15	g	27.7	0	0	\N	\N	2026-03-21 16:17:22.461631
310	3	3	160	g	108.4	7.6	0	\N	\N	2026-03-21 16:46:34.723633
311	3	66	4	scoop	420	20	16	\N	\N	2026-03-21 18:41:37.865122
312	3	66	1.5	scoop	157.5	7.5	6	\N	\N	2026-03-21 19:54:50.715893
313	3	3	250	g	169.4	11.9	0	\N	\N	2026-03-22 11:14:59.814994
314	3	47	1	bottle	190	18	7	\N	\N	2026-03-22 11:15:06.241323
315	3	2	11	g	40	10	0	\N	\N	2026-03-22 11:15:10.803793
316	3	1	16	oz	40	1	0	\N	\N	2026-03-22 11:15:14.777895
317	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-22 11:15:21.273209
318	3	67	3	scoop	315	15	12	\N	\N	2026-03-22 11:45:23.440242
319	3	56	32	g	68.6	10.2	0	\N	\N	2026-03-22 13:21:34.233341
320	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-22 13:41:48.331956
321	3	53	30	g	120	21	0	\N	\N	2026-03-22 13:42:16.551675
322	3	10	1	apple	140	1	5	\N	\N	2026-03-22 15:53:26.683456
323	3	29	30	g	128.6	11.9	0	\N	\N	2026-03-22 16:17:28.637938
324	3	68	14	g	60	1	2	\N	\N	2026-03-22 17:11:03.126592
325	3	69	1	patty	275	19	0	\N	\N	2026-03-22 18:22:10.607916
326	3	70	1	bun	130	6	1	\N	\N	2026-03-22 18:22:57.578062
327	3	18	1	slice	50	3	0	\N	\N	2026-03-22 18:24:07.143112
328	3	69	1	patty	275	19	0	\N	\N	2026-03-22 18:44:56.88621
329	3	18	1	slice	50	3	0	\N	\N	2026-03-22 18:45:00.670035
330	3	70	1	bun	130	6	1	\N	\N	2026-03-22 18:45:04.101745
331	3	1	16	oz	40	1	0	\N	\N	2026-03-23 08:59:46.644392
332	3	2	11	g	40	10	0	\N	\N	2026-03-23 08:59:52.434797
333	3	52	100	g	54.5	0.7	2.4	\N	\N	2026-03-23 09:42:28.7723
334	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-23 09:42:35.036757
335	3	28	30	g	150	5	8	\N	\N	2026-03-23 09:42:43.599331
336	3	21	30	g	160	6	10	\N	\N	2026-03-23 09:42:52.281213
337	3	53	30	g	120	21	0	\N	\N	2026-03-23 11:20:17.787179
338	3	5	3	egg	240	18	0	\N	\N	2026-03-23 12:08:47.629651
339	3	4	1	slice	80	4	2	\N	\N	2026-03-23 12:08:54.890733
340	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-23 13:57:21.733994
341	3	67	5	scoop	525	25	20	\N	\N	2026-03-23 14:03:15.194437
342	3	10	1	apple	140	1	5	\N	\N	2026-03-23 16:27:41.53245
343	3	18	1	slice	50	3	0	\N	\N	2026-03-23 19:03:14.000533
344	3	69	1	patty	275	19	0	\N	\N	2026-03-23 19:03:20.427723
345	3	70	1	bun	130	6	1	\N	\N	2026-03-23 19:03:27.19183
346	3	71	100	g	80	3	3	\N	\N	2026-03-23 19:45:18.70424
347	3	3	200	g	135.5	9.5	0	\N	\N	2026-03-23 20:06:00.661142
348	3	1	16	oz	40	1	0	\N	\N	2026-03-24 08:47:05.87043
349	3	2	11	g	40	10	0	\N	\N	2026-03-24 08:47:35.495671
350	3	28	30	g	150	5	8	\N	\N	2026-03-24 09:55:48.471567
351	3	21	30	g	160	6	10	\N	\N	2026-03-24 09:55:53.624207
352	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-24 09:55:58.249556
353	3	12	100	g	45	5	1	\N	\N	2026-03-24 09:56:02.735803
354	3	53	30	g	120	21	0	\N	\N	2026-03-24 11:12:56.914106
355	3	5	3	egg	240	18	0	\N	\N	2026-03-24 13:09:12.945589
356	3	4	1	slice	80	4	2	\N	\N	2026-03-24 13:09:18.352248
357	3	56	44	g	94.3	14	0	\N	\N	2026-03-24 15:07:07.981225
358	3	10	1	apple	140	1	5	\N	\N	2026-03-24 15:07:14.610558
359	3	3	200	g	135.5	9.5	0	\N	\N	2026-03-24 16:28:05.569037
360	3	29	30	g	128.6	11.9	0	\N	\N	2026-03-24 16:30:55.925991
361	3	31	100	g	125	12.5	3.3	\N	\N	2026-03-24 17:07:26.897272
362	3	30	15	g	27.7	0	0	\N	\N	2026-03-24 17:07:33.906099
363	3	55	1	taco	300	9	7	\N	\N	2026-03-24 19:28:00
364	3	55	1	taco	300	9	7	\N	\N	2026-03-24 20:32:00
365	3	1	16	oz	40	1	0	\N	\N	2026-03-25 09:22:30.19557
366	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-25 09:22:36.619878
367	3	2	11	g	40	10	0	\N	\N	2026-03-25 09:22:41.325211
368	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-25 09:22:46.712572
369	3	21	30	g	160	6	10	\N	\N	2026-03-25 09:22:52.537124
371	3	52	100	g	54.5	0.7	2.4	\N	\N	2026-03-25 09:23:05.212457
372	3	53	30	g	120	21	0	\N	\N	2026-03-25 11:52:51.052792
374	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-25 13:24:27.771548
376	3	29	30	g	128.6	11.9	0	\N	\N	2026-03-25 18:18:16.057589
378	3	1	16	oz	40	1	0	\N	\N	2026-03-26 10:30:41.898939
380	3	2	11	g	40	10	0	\N	\N	2026-03-26 10:30:52.957124
382	3	21	30	g	160	6	10	\N	\N	2026-03-26 10:31:02.839958
384	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-26 10:31:15.777432
385	3	5	3	egg	240	18	0	\N	\N	2026-03-26 12:11:50.528141
386	3	53	30	g	120	21	0	\N	\N	2026-03-26 12:50:03.576284
389	3	31	65	g	81.3	8.1	2.1	\N	\N	2026-03-26 14:13:06.500241
393	3	50	1	pack	50	10	0	\N	\N	2026-03-26 16:13:52.452825
394	3	74	200	g	60	0	1	\N	\N	2026-03-26 16:59:36.670373
395	3	75	100	g	150	8	5	\N	\N	2026-03-26 17:36:37.514538
396	3	76	1	tortilla	100	3	1	\N	\N	2026-03-26 17:36:56.937438
399	3	1	16	oz	40	1	0	\N	\N	2026-03-27 09:20:43.137591
401	3	3	250	g	169.4	11.9	0	\N	\N	2026-03-27 09:20:58.093307
403	3	28	30	g	150	5	8	\N	\N	2026-03-27 10:38:36.565851
405	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-27 10:39:20.222138
407	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-27 13:42:44.67597
408	3	5	3	egg	240	18	0	\N	\N	2026-03-27 14:22:37.16846
411	3	53	30	g	120	21	0	\N	\N	2026-03-27 16:41:41.927536
413	3	56	43	g	92.1	13.7	0	\N	\N	2026-03-27 18:26:44.198678
415	3	75	100	g	150	8	5	\N	\N	2026-03-27 19:01:45.668845
418	3	46	1	bottle	180	20	4	\N	\N	2026-03-28 11:05:35.214349
420	3	52	100	g	54.5	0.7	2.4	\N	\N	2026-03-28 11:12:11.345379
422	3	28	30	g	150	5	8	\N	\N	2026-03-28 11:12:22.106538
424	3	3	200	g	135.5	9.5	0	\N	\N	2026-03-28 14:01:17.25175
426	3	56	100	g	214.2	31.9	0	\N	\N	2026-03-28 16:36:47.134502
427	3	78	1	Dog	280	15	1	\N	\N	2026-03-28 17:50:21.253089
428	3	79	1	meal	800	40	3	\N	\N	2026-03-28 20:59:00
429	3	52	110	g	60	0.8	2.6	\N	\N	2026-03-29 09:27:08.24767
431	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-29 09:35:15.256182
433	3	2	11	g	40	10	0	\N	\N	2026-03-29 09:35:37.776299
434	3	80	10	g	50	1	1	\N	\N	2026-03-29 11:05:50.408288
437	3	42	143	g	153.4	33.2	0	\N	\N	2026-03-29 13:02:14.705204
439	3	41	6	g	55.4	0	0	\N	\N	2026-03-29 13:02:35.732352
442	3	29	30	g	128.6	11.9	0	\N	\N	2026-03-29 16:53:37.403251
444	3	69	2	patty	550	38	0	\N	\N	2026-03-29 19:45:35.812342
446	3	3	300	g	203.3	14.3	0	\N	\N	2026-03-30 10:10:30.653592
370	3	28	30	g	150	5	8	\N	\N	2026-03-25 09:22:57.335637
373	3	3	200	g	135.5	9.5	0	\N	\N	2026-03-25 11:53:04.684346
375	3	72	1	plate	800	40	6	\N	\N	2026-03-25 16:00:08.191219
377	3	73	8	inch	500	40	2	\N	\N	2026-03-25 20:32:04.350555
379	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-26 10:30:48.16135
381	3	12	100	g	45	5	1	\N	\N	2026-03-26 10:30:57.510674
383	3	28	30	g	150	5	8	\N	\N	2026-03-26 10:31:07.2686
387	3	56	40	g	85.7	12.7	0	\N	\N	2026-03-26 13:33:48.86813
388	3	10	1	apple	140	1	5	\N	\N	2026-03-26 13:51:06.642197
390	3	30	10	g	18.5	0	0	\N	\N	2026-03-26 14:13:14.034792
391	3	3	200	g	135.5	9.5	0	\N	\N	2026-03-26 15:13:18.283845
392	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-26 16:03:31.379065
397	3	43	28	g	100	7	0	\N	\N	2026-03-26 17:37:10.079177
398	3	3	200	g	135.5	9.5	0	\N	\N	2026-03-26 19:59:00
400	3	2	11	g	40	10	0	\N	\N	2026-03-27 09:20:48.271238
402	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-27 10:23:01.431415
404	3	21	30	g	160	6	10	\N	\N	2026-03-27 10:39:05.129492
406	3	52	100	g	54.5	0.7	2.4	\N	\N	2026-03-27 10:39:41.619347
409	3	56	43	g	92.1	13.7	0	\N	\N	2026-03-27 14:23:55.600152
410	3	77	1	apple	120	1	4	\N	\N	2026-03-27 14:24:19.061754
412	3	29	30	g	128.6	11.9	0	\N	\N	2026-03-27 16:41:47.547777
414	3	76	1	tortilla	100	3	1	\N	\N	2026-03-27 19:01:35.106997
416	3	43	28	g	100	7	0	\N	\N	2026-03-27 19:02:02.606254
417	3	2	11	g	40	10	0	\N	\N	2026-03-28 11:05:29.123177
419	3	45	9	pieces	220	4	4	\N	\N	2026-03-28 11:05:43.564804
421	3	23	0.8	cup	120	6.4	0	\N	\N	2026-03-28 11:12:17.676478
423	3	21	30	g	160	6	10	\N	\N	2026-03-28 11:12:27.197129
425	3	47	1	bottle	190	18	7	\N	\N	2026-03-28 16:35:57.30464
430	3	3	250	g	169.4	11.9	0	\N	\N	2026-03-29 09:27:17.862823
432	3	1	16	oz	40	1	0	\N	\N	2026-03-29 09:35:32.92652
435	3	47	1	bottle	190	18	7	\N	\N	2026-03-29 11:05:57.299154
436	3	44	70	g	172	5.6	1.2	\N	\N	2026-03-29 13:02:05.076547
438	3	43	60	g	214.3	15	0	\N	\N	2026-03-29 13:02:25.986631
440	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-29 13:35:14.82552
441	3	77	1	apple	120	1	4	\N	\N	2026-03-29 15:40:18.576376
443	3	70	2	bun	260	12	2	\N	\N	2026-03-29 19:45:28.897708
445	3	18	2	slice	100	6	0	\N	\N	2026-03-29 19:45:48.069802
447	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-30 10:10:45.913875
448	3	2	11	g	40	10	0	\N	\N	2026-03-30 10:10:57.150027
449	3	1	16	oz	40	1	0	\N	\N	2026-03-30 10:11:07.584333
450	3	81	1	dog	120	12	0	\N	\N	2026-03-30 11:49:23.847881
451	3	81	1	dog	120	12	0	\N	\N	2026-03-30 11:54:13.011437
452	3	56	30	g	64.3	9.6	0	\N	\N	2026-03-30 12:33:14.064393
453	3	39	1.3	burger	530.4	15.6	10.4	\N	\N	2026-03-30 13:03:34.837135
454	3	10	1	apple	140	1	5	\N	\N	2026-03-30 14:34:24.374134
455	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-30 14:35:11.900283
456	3	53	30	g	120	21	0	\N	\N	2026-03-30 16:20:21.148703
457	3	76	1	tortilla	100	3	1	\N	\N	2026-03-30 17:09:05.193469
458	3	75	100	g	150	8	5	\N	\N	2026-03-30 17:09:19.814417
459	3	43	28	g	100	7	0	\N	\N	2026-03-30 17:09:47.422698
460	3	76	1	tortilla	100	3	1	\N	\N	2026-03-30 20:12:17.354967
461	3	75	100	g	150	8	5	\N	\N	2026-03-30 20:12:24.3824
462	3	43	28	g	100	7	0	\N	\N	2026-03-30 20:12:37.3912
463	3	82	0.2	burrito	150	4	2	\N	\N	2026-03-30 20:13:18.807121
464	3	1	16	oz	40	1	0	\N	\N	2026-03-31 09:08:44.583489
465	3	2	11	g	40	10	0	\N	\N	2026-03-31 09:08:49.264675
466	3	3	250	g	169.4	11.9	0	\N	\N	2026-03-31 09:21:08.382742
467	3	12	100	g	45	5	1	\N	\N	2026-03-31 09:21:12.928417
468	3	5	3	egg	240	18	0	\N	\N	2026-03-31 10:43:52.144617
469	3	4	1	slice	80	4	2	\N	\N	2026-03-31 10:43:56.864808
470	3	52	50	g	27.3	0.4	1.2	\N	\N	2026-03-31 12:03:34.552073
471	3	53	30	g	120	21	0	\N	\N	2026-03-31 12:03:40.547217
472	3	3	150	g	101.6	7.1	0	\N	\N	2026-03-31 12:33:13.38472
473	3	81	2	dog	240	24	0	\N	\N	2026-03-31 12:51:09.865369
474	3	32	210	g	310	6	3	\N	\N	2026-03-31 12:53:38.113543
475	3	30	10	g	18.5	0	0	\N	\N	2026-03-31 12:54:07.337743
476	3	21	20	g	106.7	4	6.7	\N	\N	2026-03-31 12:57:08.711487
477	3	7	12	g	56	1.2	1.6	\N	\N	2026-03-31 13:35:57.111088
478	3	3	250	g	169.3	11.8	0	\N	\N	2026-03-31 16:59:29.899935
480	3	38	1	kit	260	12	1	\N	\N	2026-03-31 17:43:47.281911
481	3	83	1	bottle	150	30	1	\N	\N	2026-03-31 18:08:26.860485
482	3	47	1	bottle	190	18	7	\N	\N	2026-03-31 18:08:39.85843
483	3	84	300	g	300	0	0	\N	\N	2026-03-31 20:46:47.814606
484	3	1	16	oz	40	1	0	\N	\N	2026-04-01 10:12:27.613731
485	3	2	11	g	40	10	0	\N	\N	2026-04-01 10:12:38.856429
486	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-01 10:12:44.875857
487	3	52	100	g	54.6	0.8	2.4	\N	\N	2026-04-01 10:13:03.298555
488	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-01 10:33:06.127935
489	3	5	3	egg	240	18	0	\N	\N	2026-04-01 13:03:11.619147
490	3	4	1	slice	80	4	2	\N	\N	2026-04-01 13:03:27.648172
491	3	53	30	g	120	21	0	\N	\N	2026-04-01 13:16:52.032325
492	3	81	2	dog	240	24	0	\N	\N	2026-04-01 14:04:21.989449
493	3	10	1	apple	140	1	5	\N	\N	2026-04-01 14:26:45.311254
495	3	32	210	g	310	6	3	\N	\N	2026-04-01 14:48:13.21984
500	3	2	11	g	40	10	0	\N	\N	2026-04-02 11:47:06.44679
502	3	52	100	g	54.6	0.8	2.4	\N	\N	2026-04-02 11:49:05.835676
504	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-02 11:49:23.417534
505	3	53	30	g	120	21	0	\N	\N	2026-04-02 12:07:00.530897
508	3	75	100	g	150	8	5	\N	\N	2026-04-02 13:25:45.108668
511	3	75	100	g	150	8	5	\N	\N	2026-04-02 14:19:21.32831
515	3	86	1	tortilla	120	3	1	\N	\N	2026-04-02 17:45:30.950611
516	3	87	28	g	100	7	0	\N	\N	2026-04-02 17:45:43.073661
517	3	88	300	cals	300	5	0	\N	\N	2026-04-02 20:43:41.038805
520	3	52	80	g	43.7	0.6	1.9	\N	\N	2026-04-03 09:14:36.473061
522	3	2	11	g	40	10	0	\N	\N	2026-04-03 09:14:48.988182
524	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-03 09:15:15.005864
526	3	4	1	slice	80	4	2	\N	\N	2026-04-03 11:25:53.874692
527	3	53	30	g	120	21	0	\N	\N	2026-04-03 12:00:29.91697
529	3	86	1	tortilla	120	3	1	\N	\N	2026-04-03 13:20:06.80093
531	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-03 13:27:57.708943
533	3	56	45	g	96.5	14.4	0	\N	\N	2026-04-03 15:34:03.382321
535	3	75	100	g	150	8	5	\N	\N	2026-04-03 19:35:09.469183
538	3	90	4	pigs	500	20	2	\N	\N	2026-04-03 19:35:00
537	3	48	3	slice	690	33	9	\N	\N	2026-04-03 19:34:00
494	3	31	110	g	137.6	13.7	3.6	\N	\N	2026-04-01 14:48:07.17227
496	3	30	15	g	27.8	0	0	\N	\N	2026-04-01 14:48:22.894372
497	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-01 17:01:15.438478
498	3	85	240	g	500	21	10	\N	\N	2026-04-01 18:55:19.046021
499	3	1	16	oz	40	1	0	\N	\N	2026-04-02 11:46:52.935616
501	3	56	50	g	107.2	16	0	\N	\N	2026-04-02 11:48:40.507136
503	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-02 11:49:15.124196
506	3	10	1	apple	140	1	5	\N	\N	2026-04-02 12:07:34.028043
507	3	86	1	tortilla	120	3	1	\N	\N	2026-04-02 13:25:33.481172
509	3	18	2	slice	100	6	0	\N	\N	2026-04-02 13:25:54.08896
510	3	18	2	slice	100	6	0	\N	\N	2026-04-02 14:19:16.862947
512	3	86	1	tortilla	120	3	1	\N	\N	2026-04-02 14:19:27.168399
513	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-02 15:37:09.618812
514	3	75	100	g	150	8	5	\N	\N	2026-04-02 17:45:24.083617
518	3	88	200	cals	200	10	0	\N	\N	2026-04-02 20:46:03.3783
519	3	89	100	cals	100	0	0	\N	\N	2026-04-02 20:46:19.132191
521	3	1	16	oz	40	1	0	\N	\N	2026-04-03 09:14:42.017651
523	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-03 09:14:55.284406
525	3	5	3	egg	240	18	0	\N	\N	2026-04-03 11:25:48.146727
528	3	75	100	g	150	8	5	\N	\N	2026-04-03 13:20:01.151241
530	3	87	28	g	100	7	0	\N	\N	2026-04-03 13:20:12.842162
532	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-03 15:33:51.725626
534	3	86	1	tortilla	120	3	1	\N	\N	2026-04-03 19:35:03.594678
536	3	87	28	g	100	7	0	\N	\N	2026-04-03 19:35:16.388503
539	3	46	1	bottle	180	20	4	\N	\N	2026-04-04 10:17:39.64956
540	3	45	12	pieces	293.3	5.3	5.3	\N	\N	2026-04-04 10:17:50.106951
541	3	2	11	g	40	10	0	\N	\N	2026-04-04 10:18:02.436922
542	3	77	1	apple	120	1	4	\N	\N	2026-04-04 13:07:04.677305
543	3	29	30	g	128.6	11.9	0	\N	\N	2026-04-04 14:31:02.350032
544	3	91	1	sandwich 	500	17	3	\N	\N	2026-04-04 15:02:46.786371
545	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-04 15:33:00.084619
546	3	3	150	g	101.6	7.1	0	\N	\N	2026-04-04 16:10:57.585781
547	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-04 17:55:50.122265
548	3	92	28	g	120	2	4	\N	\N	2026-04-04 18:29:23.814223
549	3	93	1	slice	250	10	2	\N	\N	2026-04-04 20:04:40.156078
550	3	93	1	slice	250	10	2	\N	\N	2026-04-04 20:04:44.846798
551	3	93	1	slice	250	10	2	\N	\N	2026-04-04 20:04:57.672986
552	3	1	16	oz	40	1	0	\N	\N	2026-04-05 10:28:54.325639
553	3	2	11	g	40	10	0	\N	\N	2026-04-05 10:29:03.110999
554	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-05 10:29:23.19215
555	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-05 10:29:55.347168
556	3	5	3	egg	240	18	0	\N	\N	2026-04-05 13:12:00.030515
557	3	76	1	tortilla	100	3	1	\N	\N	2026-04-05 13:12:10.289391
558	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-05 13:48:59.220929
559	3	94	28	g	150	4	0	\N	\N	2026-04-05 14:30:07.274382
560	3	95	28	g	130	4	1	\N	\N	2026-04-05 14:34:19.433894
561	3	94	28	g	150	4	0	\N	\N	2026-04-05 16:53:21.238996
562	3	96	1	bowl	800	20	5	\N	\N	2026-04-05 18:16:11.496736
563	3	32	210	g	310	6	3	\N	\N	2026-04-05 18:28:20.718402
564	3	1	16	oz	40	1	0	\N	\N	2026-04-06 10:43:43.867928
565	3	2	11	g	40	10	0	\N	\N	2026-04-06 10:43:52.653699
566	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-06 10:44:00.545513
567	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-06 10:44:08.621552
568	3	53	30	g	120	21	0	\N	\N	2026-04-06 11:26:58.189498
569	3	59	1	bottle 	250	23	1	\N	\N	2026-04-06 12:55:18.559831
570	3	97	5	bites	120	2	0	\N	\N	2026-04-06 13:00:33.782106
571	3	97	5	bites	120	2	0	\N	\N	2026-04-06 13:20:18.958552
572	3	97	5	bites	120	2	0	\N	\N	2026-04-06 15:26:39.033959
573	3	98	1	Taco	300	10	4	\N	\N	2026-04-06 15:36:44.379126
574	3	77	1	apple	120	1	4	\N	\N	2026-04-06 16:28:50.954355
575	3	84	100	g	100	0	0	\N	\N	2026-04-06 16:58:09.409734
576	3	29	30	g	128.6	11.9	0	\N	\N	2026-04-06 16:59:15.934095
577	3	3	150	g	101.6	7.1	0	\N	\N	2026-04-06 18:12:40.277978
578	3	39	1.3	burger	530.4	15.6	10.4	\N	\N	2026-04-06 19:21:04.434515
579	3	1	16	oz	40	1	0	\N	\N	2026-04-07 10:24:17.631182
580	3	52	100	g	54.6	0.8	2.4	\N	\N	2026-04-07 10:24:26.713476
581	3	3	260	g	176.1	12.3	0	\N	\N	2026-04-07 10:24:35.892729
582	3	2	11	g	40	10	0	\N	\N	2026-04-07 10:24:42.149417
583	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-07 10:25:01.684206
584	3	5	3	egg	240	18	0	\N	\N	2026-04-07 11:56:23.581875
585	3	4	1	slice	80	4	2	\N	\N	2026-04-07 11:56:28.643757
586	3	53	30	g	120	21	0	\N	\N	2026-04-07 13:27:05.321599
587	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-07 13:27:10.600408
588	3	10	1	apple	140	1	5	\N	\N	2026-04-07 14:29:48.740127
589	3	29	38	g	162.9	15.1	0	\N	\N	2026-04-07 15:17:40.607273
590	3	3	140	g	94.8	6.6	0	\N	\N	2026-04-07 15:47:57.740804
591	3	68	28	g	120	2	4	\N	\N	2026-04-07 15:51:10.917731
592	3	99	1	muffin	160	3	2	\N	\N	2026-04-07 16:09:30.376621
593	3	31	110	g	137.6	13.7	3.6	\N	\N	2026-04-07 16:12:52.101164
594	3	30	15	g	27.8	0	0	\N	\N	2026-04-07 16:12:59.013863
595	3	76	1	tortilla	100	3	1	\N	\N	2026-04-07 18:07:33.977542
596	3	75	100	g	150	8	5	\N	\N	2026-04-07 18:07:46.998857
599	3	75	50	g	75	4	2.5	\N	\N	2026-04-07 20:50:21.720628
601	3	88	100	cals	100	5	0	\N	\N	2026-04-07 20:51:04.083509
604	3	2	11	g	40	10	0	\N	\N	2026-04-08 10:18:32.234453
606	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-08 10:18:45.652421
607	3	76	1	tortilla	100	3	1	\N	\N	2026-04-08 12:17:43.649641
609	3	87	14	g	50	3.5	0	\N	\N	2026-04-08 12:18:07.811578
611	3	75	75	g	112.5	6	3.8	\N	\N	2026-04-08 12:19:24.712365
614	3	5	3	egg	240	18	0	\N	\N	2026-04-08 13:58:44.218341
616	3	31	100	g	125.1	12.5	3.3	\N	\N	2026-04-08 15:05:16.695221
618	3	10	1	apple	140	1	5	\N	\N	2026-04-08 16:01:09.049009
621	3	18	1	slice	50	3	0	\N	\N	2026-04-08 18:10:59.640735
623	3	29	22	g	94.3	8.7	0	\N	\N	2026-04-08 19:39:01.680138
624	3	1	16	oz	40	1	0	\N	\N	2026-04-09 10:47:20.820594
626	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-09 10:48:07.113587
628	3	53	30	g	120	21	0	\N	\N	2026-04-09 11:22:38.626137
631	3	4	1	slice	80	4	2	\N	\N	2026-04-09 14:15:50.966616
633	3	30	15	g	27.8	0	0	\N	\N	2026-04-09 14:21:31.488723
635	3	50	1	pack	50	10	0	\N	\N	2026-04-09 15:45:56.689619
638	3	86	1	tortilla	120	3	1	\N	\N	2026-04-09 16:51:11.470983
641	3	56	45	g	96.5	14.4	0	\N	\N	2026-04-09 17:18:27.606971
597	3	87	28	g	100	7	0	\N	\N	2026-04-07 18:07:57.034241
598	3	76	1	tortilla	100	3	1	\N	\N	2026-04-07 20:49:41.426017
600	3	87	28	g	100	7	0	\N	\N	2026-04-07 20:50:41.208333
602	3	75	50	g	75	4	2.5	\N	\N	2026-04-07 20:51:55.606202
603	3	1	16	oz	40	1	0	\N	\N	2026-04-08 10:18:26.049091
605	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-08 10:18:37.352735
608	3	75	75	g	112.5	6	3.8	\N	\N	2026-04-08 12:17:57.737787
610	3	76	1	tortilla	100	3	1	\N	\N	2026-04-08 12:19:19.873235
612	3	87	14	g	50	3.5	0	\N	\N	2026-04-08 12:19:30.396219
613	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-08 13:58:39.372043
615	3	4	1	slice	80	4	2	\N	\N	2026-04-08 13:58:49.288904
617	3	30	15	g	27.8	0	0	\N	\N	2026-04-08 15:05:21.226839
619	3	53	30	g	120	21	0	\N	\N	2026-04-08 17:26:26.493281
620	3	100	1	burger	400	20	2	\N	\N	2026-04-08 18:10:47.262679
622	3	56	45	g	96.5	14.4	0	\N	\N	2026-04-08 19:37:18.75278
625	3	2	11	g	40	10	0	\N	\N	2026-04-09 10:47:27.091171
627	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-09 11:22:31.920675
629	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-09 13:40:15.095649
630	3	5	3	egg	240	18	0	\N	\N	2026-04-09 14:15:46.067503
632	3	31	100	g	125.1	12.5	3.3	\N	\N	2026-04-09 14:21:22.695601
634	3	10	1	apple	140	1	5	\N	\N	2026-04-09 15:29:16.001744
636	3	74	200	g	60	0	1	\N	\N	2026-04-09 16:24:49.669665
637	3	101	130	g	100	5	5	\N	\N	2026-04-09 16:51:01.613198
639	3	87	14	g	50	3.5	0	\N	\N	2026-04-09 16:51:19.548837
640	3	102	1	square	60	2	2	\N	\N	2026-04-09 16:58:34.442081
642	3	76	1	tortilla	100	3	1	\N	\N	2026-04-09 17:18:43.649795
643	3	101	130	g	100	5	5	\N	\N	2026-04-09 17:18:57.484532
644	3	87	21	g	75	5.3	0	\N	\N	2026-04-09 17:28:02.114484
645	3	29	28	g	120	11.1	0	\N	\N	2026-04-09 20:24:00
646	3	86	1	tortilla	120	3	1	\N	\N	2026-04-09 20:25:00
647	3	87	28	g	100	7.1	0	\N	\N	2026-04-09 20:26:00
648	3	1	16	oz	40	1	0	\N	\N	2026-04-10 10:16:49.270828
649	3	2	11	g	40	10	0	\N	\N	2026-04-10 10:16:57.959249
650	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-10 10:17:03.073851
651	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-10 10:17:13.22253
652	3	23	1.3	cup	195	10.4	0	\N	\N	2026-04-10 10:56:05.617047
653	3	53	30	g	120	21	0	\N	\N	2026-04-10 12:34:52.962527
654	3	39	1.3	burger	530.4	15.6	10.4	\N	\N	2026-04-10 13:18:37.036788
655	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-10 13:44:08.446846
656	3	77	1	apple	120	1	4	\N	\N	2026-04-10 14:26:21.003732
657	3	68	18	g	77.1	1.3	2.6	\N	\N	2026-04-10 14:35:37.084634
658	3	86	1	tortilla	120	3	1	\N	\N	2026-04-10 16:28:19.47641
659	3	101	130	g	100	5	5	\N	\N	2026-04-10 16:28:33.223034
660	3	87	21	g	75	5.3	0	\N	\N	2026-04-10 16:28:44.341183
661	3	56	30	g	64.3	9.6	0	\N	\N	2026-04-10 17:36:06.036574
662	3	103	75	g	100	6.5	1	\N	\N	2026-04-10 19:35:30.901693
663	3	103	75	g	100	6.5	1	\N	\N	2026-04-10 19:36:37.252643
664	3	104	1	bar	260	10	5	\N	\N	2026-04-10 19:42:19.558097
665	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-10 19:51:45.481782
666	3	2	11	g	40	10	0	\N	\N	2026-04-11 08:44:47.698995
668	3	47	1	bottle	190	18	7	\N	\N	2026-04-11 08:45:32.747035
669	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-11 08:45:56.385101
670	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-11 08:54:00.80009
671	3	47	1	bottle	190	18	7	\N	\N	2026-04-11 10:38:25.217528
672	3	104	1	bar	260	10	5	\N	\N	2026-04-11 10:50:16.099762
673	3	104	1	bar	260	10	5	\N	\N	2026-04-11 12:43:52.574769
674	3	105	1	bottle 	170	26	2	\N	\N	2026-04-11 13:58:51.61433
675	3	104	1	bar	260	10	5	\N	\N	2026-04-11 17:25:23.032635
676	3	44	75	g	184.3	6	1.3	\N	\N	2026-04-11 20:45:46.992817
677	3	42	121	g	129.8	28.1	0	\N	\N	2026-04-11 20:46:06.309625
678	3	43	44	g	157.1	11	0	\N	\N	2026-04-11 20:46:34.886815
679	3	41	9	g	83.1	0	0	\N	\N	2026-04-11 20:46:51.938369
680	3	106	1	slice	250	5	4	\N	\N	2026-04-11 20:47:56.106188
681	3	107	1	cup	150	8	6	\N	\N	2026-04-11 20:48:47.692163
682	3	108	1	side	160	3	3	\N	\N	2026-04-11 20:49:33.294903
683	3	109	1	side	100	1	3	\N	\N	2026-04-11 20:50:13.048526
684	3	110	1	side	80	2	2	\N	\N	2026-04-11 20:50:54.159768
685	3	1	16	oz	40	1	0	\N	\N	2026-04-12 09:17:37.720421
686	3	2	11	g	40	10	0	\N	\N	2026-04-12 10:06:48.310092
687	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-12 10:07:03.387115
688	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-12 10:07:10.796327
689	3	104	1	bar	260	10	5	\N	\N	2026-04-12 10:49:36.215014
690	3	56	52	g	111.5	16.6	0	\N	\N	2026-04-12 12:20:43.337915
691	3	45	9	pieces	220	4	4	\N	\N	2026-04-12 12:21:03.194652
692	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-12 13:10:52.683788
693	3	48	3	slice	690	33	9	\N	\N	2026-04-12 16:02:15.897507
694	3	43	60	g	214.2	15	0	\N	\N	2026-04-12 16:02:39.357649
695	3	44	75	g	184.3	6	1.3	\N	\N	2026-04-12 16:02:57.509508
696	3	48	1	slice	230	11	3	\N	\N	2026-04-12 17:02:26.24014
697	3	84	300	g	300	0	0	\N	\N	2026-04-12 19:16:27.789019
698	3	1	16	oz	40	1	0	\N	\N	2026-04-13 09:53:15.534344
699	3	2	11	g	40	10	0	\N	\N	2026-04-13 09:53:20.790265
701	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-13 09:53:31.896199
703	3	5	3	egg	240	18	0	\N	\N	2026-04-13 13:40:51.882301
706	3	30	20	g	37.1	0	0	\N	\N	2026-04-13 14:26:39.327746
709	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-13 16:01:30.641298
711	3	48	1	slice	230	11	3	\N	\N	2026-04-13 17:27:42.250264
712	3	48	1	slice	230	11	3	\N	\N	2026-04-13 18:55:31.142426
714	3	85	100	g	208.3	8.8	4.2	\N	\N	2026-04-13 20:22:31.647374
716	3	2	11	g	40	10	0	\N	\N	2026-04-14 12:00:46.076799
718	3	36	100	g	50	1	6.5	\N	\N	2026-04-14 12:00:58.877626
720	3	104	1	bar	260	10	5	\N	\N	2026-04-14 12:01:10.98215
723	3	5	3	egg	240	18	0	\N	\N	2026-04-14 13:48:34.888076
725	3	31	80	g	100.1	10	2.7	\N	\N	2026-04-14 15:47:02.840393
727	3	104	1	bar	260	10	5	\N	\N	2026-04-14 16:16:05.041878
729	3	29	28	g	120	11.1	0	\N	\N	2026-04-14 17:48:06.472978
731	3	104	1	bar	260	10	5	\N	\N	2026-04-14 18:50:04.499547
734	3	2	11	g	40	10	0	\N	\N	2026-04-15 12:11:09.637984
736	3	36	100	g	50	1	6.5	\N	\N	2026-04-15 12:11:27.922336
739	3	113	130	g	170	8	9	\N	\N	2026-04-15 12:15:49.582688
741	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-15 13:34:39.685309
743	3	30	10	g	18.6	0	0	\N	\N	2026-04-15 13:54:15.298838
744	3	10	1	apple	140	1	5	\N	\N	2026-04-15 15:58:50.084464
745	3	111	28	g	140	2	1	\N	\N	2026-04-15 16:03:36.670578
746	3	115	22	g	75	3	0	\N	\N	2026-04-15 16:20:09.026822
747	3	116	14	g	70	1	0	\N	\N	2026-04-15 16:20:49.066439
750	3	20	100	g	160	7	1	\N	\N	2026-04-15 18:48:58.943005
752	3	2	11	g	40	10	0	\N	\N	2026-04-16 12:28:21.747112
754	3	84	100	g	100	0	0	\N	\N	2026-04-16 12:28:37.367362
700	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-13 09:53:26.342499
702	3	36	100	g	50	1	6.5	\N	\N	2026-04-13 09:53:42.276081
704	3	4	1	slice	80	4	2	\N	\N	2026-04-13 13:40:57.113451
705	3	31	220	g	275.2	27.5	7.3	\N	\N	2026-04-13 14:26:31.628998
707	3	53	30	g	120	21	0	\N	\N	2026-04-13 15:06:00.245058
708	3	10	1	apple	140	1	5	\N	\N	2026-04-13 15:14:41.670828
710	3	111	28	g	140	2	1	\N	\N	2026-04-13 17:11:24.184974
713	3	84	150	g	150	0	0	\N	\N	2026-04-13 19:45:49.414815
715	3	1	16	oz	40	1	0	\N	\N	2026-04-14 12:00:36.193642
717	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-14 12:00:52.71524
719	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-14 12:01:04.705433
721	3	3	100	g	67.7	4.7	0	\N	\N	2026-04-14 12:09:20.989378
722	3	53	30	g	120	21	0	\N	\N	2026-04-14 12:53:34.013971
724	3	4	1	slice	80	4	2	\N	\N	2026-04-14 13:48:41.454549
726	3	30	10	g	18.6	0	0	\N	\N	2026-04-14 15:47:09.86067
728	3	10	1	apple	140	1	5	\N	\N	2026-04-14 16:17:23.312797
730	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-14 17:53:23.596232
732	3	112	1	cup	250	15	15	\N	\N	2026-04-14 19:31:29.317341
733	3	1	16	oz	40	1	0	\N	\N	2026-04-15 12:11:02.329391
735	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-15 12:11:21.579124
737	3	47	1	bottle	190	18	7	\N	\N	2026-04-15 12:11:34.727373
738	3	113	130	g	170	8	9	\N	\N	2026-04-15 12:15:44.39486
740	3	114	50	g	120	11	0	\N	\N	2026-04-15 13:03:12.323248
742	3	31	140	g	175.2	17.5	4.7	\N	\N	2026-04-15 13:54:10.408822
748	3	56	35	g	75	11.2	0	\N	\N	2026-04-15 16:54:35.008218
749	3	85	300	g	624.9	26.4	12.6	\N	\N	2026-04-15 18:41:56.640103
751	3	1	16	oz	40	1	0	\N	\N	2026-04-16 12:28:15.797274
753	3	47	1	bottle	190	18	7	\N	\N	2026-04-16 12:28:29.259892
755	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-16 12:44:50.138289
756	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-16 12:44:57.0243
757	3	113	130	g	170	8	9	\N	\N	2026-04-16 12:50:59.146102
758	3	10	1	apple	140	1	5	\N	\N	2026-04-16 14:09:10.273317
759	3	86	1	tortilla	120	3	1	\N	\N	2026-04-16 14:17:01.008125
760	3	117	130	g	150	7	5	\N	\N	2026-04-16 14:23:46.492917
761	3	87	28	g	100	7.1	0	\N	\N	2026-04-16 14:24:01.370528
762	3	31	235	g	294.1	29.4	7.9	\N	\N	2026-04-16 15:43:58.934629
763	3	30	25	g	46.5	0	0	\N	\N	2026-04-16 15:44:07.677054
764	3	86	0.5	tortilla	60	1.5	0.5	\N	\N	2026-04-16 17:21:35.77018
765	3	84	100	g	100	0	0	\N	\N	2026-04-16 18:03:39.271579
766	3	52	125	g	68.3	1	3	\N	\N	2026-04-16 20:33:48.216004
767	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-16 20:34:08.126791
768	3	84	50	g	50	0	0	\N	\N	2026-04-16 20:35:52.466406
769	3	31	120	g	150.2	15	4	\N	\N	2026-04-16 20:39:16.63275
770	3	30	15	g	27.9	0	0	\N	\N	2026-04-16 20:39:23.60645
771	3	3	275	g	186.2	13	0	\N	\N	2026-04-17 10:52:52.889489
772	3	52	100	g	54.6	0.8	2.4	\N	\N	2026-04-17 10:53:00.839215
773	3	2	11	g	40	10	0	\N	\N	2026-04-17 10:53:15.31498
774	3	118	100	g	20	2	2	\N	\N	2026-04-17 12:24:41.342742
775	3	119	70	g	110	1.5	5	\N	\N	2026-04-17 12:27:46.496618
776	3	120	50	g	30	0.3	0.8	\N	\N	2026-04-17 12:28:31.31169
777	3	104	1	bar	260	10	5	\N	\N	2026-04-17 12:43:52.314824
778	3	53	30	g	120	21	0	\N	\N	2026-04-17 13:49:48.592142
779	3	117	80	g	92.3	4.3	3.1	\N	\N	2026-04-17 14:50:03.215685
780	3	86	1	tortilla	120	3	1	\N	\N	2026-04-17 14:50:12.20969
781	3	87	21	g	75	5.3	0	\N	\N	2026-04-17 14:50:33.963098
782	3	117	80	g	92.3	4.3	3.1	\N	\N	2026-04-17 14:58:30.261062
783	3	86	1	tortilla	120	3	1	\N	\N	2026-04-17 14:58:45.947804
784	3	7	18	g	84	1.8	2.4	\N	\N	2026-04-17 15:37:45.722473
785	3	121	1	meal	1200	40	0	\N	\N	2026-04-17 18:40:52.73509
786	3	2	11	g	40	10	0	\N	\N	2026-04-20 09:46:27.772437
787	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-20 09:46:37.85105
788	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-20 10:59:43.402619
789	3	5	3	egg	240	18	0	\N	\N	2026-04-20 11:11:23.757422
790	3	4	1	slice	80	4	2	\N	\N	2026-04-20 11:11:29.961114
791	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-20 13:03:43.599164
792	3	104	1	bar	260	10	5	\N	\N	2026-04-20 13:03:48.513827
793	3	39	1.3	burger	530.4	15.6	10.4	\N	\N	2026-04-20 13:58:32.96607
794	3	38	1	kit	260	12	1	\N	\N	2026-04-20 16:47:08.786392
795	3	122	1	stick	80	7	0	\N	\N	2026-04-20 17:34:05.261366
796	3	122	1	stick	80	7	0	\N	\N	2026-04-20 17:34:09.976105
797	3	123	200	g	400	10	2	\N	\N	2026-04-20 19:20:26.50825
798	3	1	16	oz	40	1	0	\N	\N	2026-04-21 10:58:11.82
799	3	2	11	g	40	10	0	\N	\N	2026-04-21 10:58:21.228401
800	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-21 10:58:35.490848
801	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-21 10:58:48.132586
802	3	104	1	bar	260	10	5	\N	\N	2026-04-21 10:58:59.660369
803	3	31	220	g	275.4	27.5	7.3	\N	\N	2026-04-21 13:08:14.750325
804	3	30	30	g	55.8	0	0	\N	\N	2026-04-21 13:09:41.108293
805	3	51	1	donuts	63.3	3.3	1	\N	\N	2026-04-21 14:13:48.33395
806	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-21 14:17:57.079461
807	3	5	3	egg	240	18	0	\N	\N	2026-04-21 15:08:07.887117
808	3	3	190	g	128.7	9	0	\N	\N	2026-04-21 15:39:45.734858
809	3	122	1	stick	80	7	0	\N	\N	2026-04-21 16:07:09.754203
810	3	36	100	g	50	1	6.5	\N	\N	2026-04-21 16:07:21.701855
811	3	50	1	pack	50	10	0	\N	\N	2026-04-21 17:35:50.582361
814	3	55	1	taco	300	9	7	\N	\N	2026-04-21 18:58:14.820883
815	3	98	1	Taco	300	10	4	\N	\N	2026-04-21 18:58:25.428761
816	3	1	16	oz	40	1	0	\N	\N	2026-04-22 09:26:22.864269
819	3	36	100	g	50	1	6.5	\N	\N	2026-04-22 09:26:53.30283
822	3	4	2	slice	160	8	4	\N	\N	2026-04-22 11:27:08.15988
823	3	104	1	bar	260	10	5	\N	\N	2026-04-22 13:18:32.552354
824	3	124	2	bites	160	11	1	\N	\N	2026-04-22 14:00:20.37573
825	3	39	1.3	burger	530.4	15.6	10.4	\N	\N	2026-04-22 14:43:26.198521
827	3	112	1	cup	250	15	15	\N	\N	2026-04-22 19:11:10.017126
828	3	1	16	oz	40	1	0	\N	\N	2026-04-23 11:26:03.526495
829	3	2	11	g	40	10	0	\N	\N	2026-04-23 11:26:16.782411
830	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-23 11:26:23.262236
833	3	104	1	bar	260	10	5	\N	\N	2026-04-23 13:44:10.349647
836	3	84	200	g	200	0	0	\N	\N	2026-04-23 13:45:48.527539
837	3	122	1	stick	80	7	0	\N	\N	2026-04-23 14:55:52.429465
838	3	124	2	bites	160	11	1	\N	\N	2026-04-23 14:57:52.585781
841	3	125	100	g	165	31	0	\N	\N	2026-04-23 16:46:27.179969
844	3	126	1	small	400	11	8	\N	\N	2026-04-23 20:39:06.503438
845	3	1	16	oz	40	1	0	\N	\N	2026-04-24 09:36:49.307676
848	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-24 09:37:05.228971
849	3	104	1	bar	260	10	5	\N	\N	2026-04-24 10:40:21.423738
851	3	86	1	tortilla	120	3	1	\N	\N	2026-04-24 12:07:08.564161
812	3	18	1	slice	50	3	0	\N	\N	2026-04-21 18:27:37.915376
817	3	2	11	g	40	10	0	\N	\N	2026-04-22 09:26:29.218656
820	3	53	30	g	120	21	0	\N	\N	2026-04-22 11:26:56.819612
831	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-23 11:26:31.237707
834	3	47	1	bottle	190	18	7	\N	\N	2026-04-23 13:44:19.073896
839	3	84	200	g	200	0	0	\N	\N	2026-04-23 16:21:53.404904
842	3	86	1	tortilla	120	3	1	\N	\N	2026-04-23 16:46:36.789033
846	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-24 09:36:55.11876
852	3	117	100	g	115.4	5.4	3.9	\N	\N	2026-04-24 12:07:26.028237
813	3	104	1	bar	260	10	5	\N	\N	2026-04-21 18:27:50.852507
818	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-22 09:26:47.645589
821	3	5	3	egg	240	18	0	\N	\N	2026-04-22 11:27:01.534365
826	3	56	28	g	60	9	0	\N	\N	2026-04-22 17:22:21.215961
832	3	36	100	g	50	1	6.5	\N	\N	2026-04-23 11:26:38.449748
835	3	122	1	stick	80	7	0	\N	\N	2026-04-23 13:44:28.225327
840	3	119	60	g	94.3	1.3	4.3	\N	\N	2026-04-23 16:45:26.180077
843	3	125	100	g	165	31	0	\N	\N	2026-04-23 16:49:47.787782
847	3	2	11	g	40	10	0	\N	\N	2026-04-24 09:37:00.536979
850	3	124	2	bites	160	11	1	\N	\N	2026-04-24 11:28:26.043796
853	3	87	28	g	100	7.1	0	\N	\N	2026-04-24 12:07:36.483771
854	3	86	1	tortilla	120	3	1	\N	\N	2026-04-24 14:47:26.716579
855	3	117	100	g	115.4	5.4	3.9	\N	\N	2026-04-24 14:47:32.457303
856	3	84	250	g	250	0	0	\N	\N	2026-04-24 15:38:28.783453
857	3	86	1	tortilla	120	3	1	\N	\N	2026-04-24 19:26:22.207661
858	3	125	70	g	115.5	21.7	0	\N	\N	2026-04-24 19:26:32.557968
859	3	119	50	g	78.6	1.1	3.6	\N	\N	2026-04-24 19:27:20.64911
860	3	120	150	g	90	0.9	2.4	\N	\N	2026-04-24 19:38:20.115574
861	3	86	1	tortilla	120	3	1	\N	\N	2026-04-24 20:01:09.412371
862	3	119	50	g	78.6	1.1	3.6	\N	\N	2026-04-24 20:01:15.584043
863	3	125	70	g	115.5	21.7	0	\N	\N	2026-04-24 20:01:20.258779
864	3	84	125	g	125	0	0	\N	\N	2026-04-25 09:10:57.453428
865	3	2	11	g	40	10	0	\N	\N	2026-04-25 09:11:34.75371
866	3	45	9	pieces	220	4	4	\N	\N	2026-04-25 10:08:57.606722
867	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-25 10:09:07.879961
868	3	86	1	tortilla	120	3	1	\N	\N	2026-04-25 12:13:46.020215
869	3	117	60	g	69.2	3.2	2.3	\N	\N	2026-04-25 12:14:47.808257
870	3	119	25	g	39.3	0.6	1.8	\N	\N	2026-04-25 12:14:59.597308
871	3	119	50	g	78.6	1.2	3.6	\N	\N	2026-04-25 13:11:53.420015
872	3	117	60	g	69.2	3.2	2.3	\N	\N	2026-04-25 13:12:00.202509
873	3	86	1	tortilla	120	3	1	\N	\N	2026-04-25 13:12:05.761955
874	3	104	1	bar	260	10	5	\N	\N	2026-04-25 15:18:12.63519
875	3	127	1	Sandwich	1300	40	3	\N	\N	2026-04-25 20:42:00
886	3	52	100	g	54.6	0.8	2.4	\N	\N	2026-04-27 09:21:41.097766
887	3	1	16	oz	40	1	0	\N	\N	2026-04-27 09:21:46.3088
888	3	2	11	g	40	10	0	\N	\N	2026-04-27 09:21:51.532051
889	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-27 09:21:57.911917
890	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-27 09:29:05.125885
891	3	124	4	bites	320	22	2	\N	\N	2026-04-27 10:37:23.129341
892	3	39	1.3	burger	530.4	15.6	10.4	\N	\N	2026-04-27 12:10:29.856178
893	3	10	1	apple	140	1	5	\N	\N	2026-04-27 13:54:49.404165
894	3	105	1	bottle 	170	26	2	\N	\N	2026-04-27 13:57:25.840032
895	3	84	50	g	50	0	0	\N	\N	2026-04-27 16:34:37.358523
896	3	38	1	kit	260	12	1	\N	\N	2026-04-27 16:34:46.199661
897	3	122	1	stick	80	7	0	\N	\N	2026-04-27 18:10:52.613447
898	3	128	1	burger	550	15	5	\N	\N	2026-04-27 19:14:53.473258
899	3	1	16	oz	40	1	0	\N	\N	2026-04-28 09:13:12.409407
900	3	2	11	g	40	10	0	\N	\N	2026-04-28 09:13:18.554233
901	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-28 09:13:24.922327
902	3	52	75	g	41	0.6	1.8	\N	\N	2026-04-28 09:13:33.533736
903	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-28 10:06:41.458655
904	3	124	4	bites	320	22	2	\N	\N	2026-04-28 10:07:06.971384
905	3	129	1	roll	480	13	5	\N	\N	2026-04-28 12:52:50.021095
906	3	129	0.7	roll	336	9.1	3.5	\N	\N	2026-04-28 14:13:28.881073
907	3	105	1	bottle 	170	26	2	\N	\N	2026-04-28 14:50:16.082909
908	3	122	1	stick	80	7	0	\N	\N	2026-04-28 17:46:35.993258
909	3	86	1	tortilla	120	3	1	\N	\N	2026-04-28 17:51:00.042438
910	3	119	40	g	62.9	1	2.9	\N	\N	2026-04-28 17:51:17.676746
911	3	125	80	g	132	24.8	0	\N	\N	2026-04-28 17:51:33.928356
912	3	119	40	g	62.9	1	2.9	\N	\N	2026-04-28 20:39:19.79747
913	3	86	1	tortilla	120	3	1	\N	\N	2026-04-28 20:39:26.729924
914	3	117	80	g	92.3	4.3	3.1	\N	\N	2026-04-28 20:39:43.784768
915	3	84	100	g	100	0	0	\N	\N	2026-04-28 20:40:30.742233
916	3	1	16	oz	40	1	0	\N	\N	2026-04-29 10:35:23.897677
917	3	2	11	g	40	10	0	\N	\N	2026-04-29 10:35:32.312598
918	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-29 10:35:47.145774
919	3	3	250	g	169.3	11.8	0	\N	\N	2026-04-29 10:36:06.643992
920	3	105	1	bottle 	170	26	2	\N	\N	2026-04-29 10:36:15.030509
923	3	131	0.3	lb	420	24	0	\N	\N	2026-04-29 12:42:45.077576
925	3	10	1	apple	140	1	5	\N	\N	2026-04-29 15:45:35.107194
924	3	130	0.3	lb	240	30	0	\N	\N	2026-04-29 12:42:55.311875
926	3	31	180	g	225.3	22.5	6	\N	\N	2026-04-29 15:52:12.22942
928	3	122	1	stick	80	7	0	\N	\N	2026-04-29 15:52:29.268301
930	3	84	100	g	100	0	0	\N	\N	2026-04-29 17:58:43.99556
927	3	30	30	g	55.8	0	0	\N	\N	2026-04-29 15:52:20.625865
929	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-29 16:12:22.131597
931	3	91	1	sandwich 	500	17	3	\N	\N	2026-04-29 18:28:22.739646
940	3	1	16	oz	40	1	0	\N	\N	2026-04-30 15:36:34.891694
941	3	2	11	g	40	10	0	\N	\N	2026-04-30 15:36:42.567327
942	3	3	300	g	203.2	14.2	0	\N	\N	2026-04-30 15:36:56.817674
943	3	124	2	bites	160	11	1	\N	\N	2026-04-30 15:37:13.456967
944	3	132	300	g	600	20	5	\N	\N	2026-04-30 15:38:04.526626
945	3	122	1	stick	80	7	0	\N	\N	2026-04-30 15:38:17.402473
946	3	7	12	g	56	1.2	1.6	\N	\N	2026-04-30 15:38:24.296201
947	3	104	1	bar	260	10	5	\N	\N	2026-04-30 15:56:11.719776
948	3	86	1	tortilla	120	3	1	\N	\N	2026-04-30 17:07:42.738618
949	3	117	80	g	92.3	4.3	3.1	\N	\N	2026-04-30 17:07:51.84021
950	3	87	21	g	75	5.3	0	\N	\N	2026-04-30 17:08:01.752232
951	3	104	1	bar	260	10	5	\N	\N	2026-04-30 19:03:44.360468
952	3	88	500	cals	500	25	0	\N	\N	2026-04-30 20:28:00
953	3	3	250	g	169.3	11.8	0	\N	\N	2026-05-01 09:30:59.202038
954	3	133	1	taco	600	25	2	\N	\N	2026-05-01 12:02:51.792328
955	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-01 12:03:09.141664
956	3	117	100	g	115.4	5.4	3.9	\N	\N	2026-05-01 13:15:52.577009
957	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-01 13:16:05.88706
958	3	10	1	apple	140	1	5	\N	\N	2026-05-01 14:18:39.248692
959	3	7	6	g	28	0.6	0.8	\N	\N	2026-05-01 15:32:58.463571
960	3	122	1	stick	80	7	0	\N	\N	2026-05-01 15:33:39.900969
961	3	104	1	bar	260	10	5	\N	\N	2026-05-01 16:31:26.05152
962	3	18	1	slice	50	3	0	\N	\N	2026-05-01 17:04:58.775476
963	3	31	100	g	125.2	12.5	3.3	\N	\N	2026-05-01 18:40:00.423954
964	3	32	180	g	265.7	5.1	2.6	\N	\N	2026-05-01 18:42:37.598794
965	3	32	180	g	265.7	5.1	2.6	\N	\N	2026-05-01 20:18:00
966	3	2	11	g	40	10	0	\N	\N	2026-05-02 11:12:38.565305
967	3	46	1	bottle	180	20	4	\N	\N	2026-05-02 11:12:46.110654
968	3	45	9	pieces	220	4	4	\N	\N	2026-05-02 11:20:31.370848
969	3	7	18	g	84	1.8	2.4	\N	\N	2026-05-02 11:20:49.28467
970	3	3	250	g	169.3	11.8	0	\N	\N	2026-05-02 11:20:55.188521
971	3	7	18	g	84	1.8	2.4	\N	\N	2026-05-02 14:11:35.93135
972	3	124	2	bites	160	11	1	\N	\N	2026-05-02 14:57:56.093193
973	3	77	1	apple	120	1	4	\N	\N	2026-05-02 18:00:03.028715
974	3	45	9	pieces	220	4	4	\N	\N	2026-05-02 18:00:19.313451
975	3	134	4	Oz	400	17	6	\N	\N	2026-05-02 20:06:46.842256
976	3	134	2	Oz	200	8.5	3	\N	\N	2026-05-02 20:19:54.482439
977	3	135	1	g	900	60	12	\N	\N	2026-05-02 20:27:00
978	3	136	1	roll	120	0	0	\N	\N	2026-05-02 20:28:00
979	3	1	16	oz	40	1	0	\N	\N	2026-05-03 09:42:48.295534
980	3	2	11	g	40	10	0	\N	\N	2026-05-03 09:42:57.874356
982	3	3	300	g	203.2	14.2	0	\N	\N	2026-05-03 09:43:57.709027
983	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-03 09:44:22.631868
984	3	137	1	wheel	70	5	0	\N	\N	2026-05-03 12:02:54.585785
985	3	84	100	g	100	0	0	\N	\N	2026-05-03 12:03:03.800144
986	3	124	4	bites	320	22	2	\N	\N	2026-05-03 12:05:08.570099
987	3	86	1	tortilla	120	3	1	\N	\N	2026-05-03 12:59:34.566544
988	3	117	80	g	92.3	4.3	3.1	\N	\N	2026-05-03 12:59:56.105408
989	3	119	50	g	78.6	1.3	3.6	\N	\N	2026-05-03 13:00:17.075433
990	3	137	1	wheel	70	5	0	\N	\N	2026-05-03 14:28:11.276435
991	3	104	1	bar	260	10	5	\N	\N	2026-05-03 15:05:27.657187
992	3	10	1	apple	140	1	5	\N	\N	2026-05-03 15:10:04.803121
993	3	3	180	g	121.9	8.5	0	\N	\N	2026-05-03 17:18:11.246526
994	3	137	1	wheel	70	5	0	\N	\N	2026-05-03 18:39:54.734213
995	3	86	1	tortilla	120	3	1	\N	\N	2026-05-03 18:51:51.220476
996	3	117	80	g	92.3	4.3	3.1	\N	\N	2026-05-03 18:52:10.349866
997	3	119	50	g	78.6	1.3	3.6	\N	\N	2026-05-03 18:52:17.87687
998	3	119	50	g	78.6	1.3	3.6	\N	\N	2026-05-03 18:58:20.156332
999	3	117	80	g	92.3	4.3	3.1	\N	\N	2026-05-03 18:58:25.305923
1000	3	86	1	tortilla	120	3	1	\N	\N	2026-05-03 18:58:30.536968
1001	3	138	1	slice	120	4	1	\N	\N	2026-05-03 19:13:02.44567
1002	3	3	300	g	203.2	14.2	0	\N	\N	2026-05-04 08:47:39.384286
1003	3	1	16	oz	40	1	0	\N	\N	2026-05-04 08:47:44.828869
1004	3	2	11	g	40	10	0	\N	\N	2026-05-04 08:47:50.739695
1005	3	36	125	g	62.5	1.3	8.1	\N	\N	2026-05-04 08:47:58.558363
1006	3	124	2	bites	160	11	1	\N	\N	2026-05-04 11:00:39.141323
1007	3	104	1	bar	260	10	5	\N	\N	2026-05-04 12:01:00.420047
1008	3	31	150	g	187.8	18.8	4.9	\N	\N	2026-05-04 12:40:36.157855
1009	3	30	25	g	46.5	0	0	\N	\N	2026-05-04 12:40:43.102521
1010	3	77	1	apple	120	1	4	\N	\N	2026-05-04 12:43:16.478524
1011	3	45	6	pieces	146.7	2.7	2.7	\N	\N	2026-05-04 15:30:04.81798
1012	3	45	3	pieces	73.3	1.4	1.4	\N	\N	2026-05-04 15:35:44.67077
1013	3	137	1	wheel	70	5	0	\N	\N	2026-05-04 15:43:10.266131
1014	3	137	1	wheel	70	5	0	\N	\N	2026-05-04 15:45:13.288701
1015	3	105	1	bottle 	170	26	2	\N	\N	2026-05-04 15:55:56.98395
1016	3	137	1	wheel	70	5	0	\N	\N	2026-05-04 18:30:53.974151
1017	3	104	1	bar	260	10	5	\N	\N	2026-05-04 18:31:02.628309
1018	3	129	0.7	roll	336	9.1	3.5	\N	\N	2026-05-04 20:40:33.660779
1019	3	85	100	g	208.3	8.8	4.2	\N	\N	2026-05-04 20:54:32.798097
1024	3	1	16	oz	40	1	0	\N	\N	2026-05-07 11:23:20.873513
1025	3	2	11	g	40	10	0	\N	\N	2026-05-07 11:23:26.84502
1026	3	3	300	g	203.2	14.2	0	\N	\N	2026-05-07 11:23:32.637526
1027	3	3	300	g	203.2	14.2	0	\N	\N	2026-05-07 11:23:33.190417
1028	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-07 11:23:46.435084
1030	3	45	4	pieces	97.7	1.9	1.9	\N	\N	2026-05-07 11:27:20.882436
1031	3	5	3	egg	240	18	0	\N	\N	2026-05-07 11:27:37.178213
1032	3	4	1	slice	80	4	2	\N	\N	2026-05-07 11:39:16.797477
1033	3	45	3	pieces	73.3	1.4	1.4	\N	\N	2026-05-07 12:59:22.740175
1034	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-07 12:59:30.698704
1035	3	31	160	g	200.3	20.1	5.2	\N	\N	2026-05-07 13:48:32.038199
1036	3	30	20	g	37.2	0	0	\N	\N	2026-05-07 13:48:40.290398
1037	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-07 14:23:38.772247
1038	3	137	2	wheel	140	10	0	\N	\N	2026-05-07 16:17:51.5854
1039	3	140	1	cup	220	7	3	\N	\N	2026-05-07 17:11:12.503133
1040	3	141	6	Inch	400	26	3	\N	\N	2026-05-07 19:05:21.247261
1041	3	3	150	g	101.6	7.1	0	\N	\N	2026-05-07 21:23:27.429771
1042	3	31	60	g	75.1	7.5	2	\N	\N	2026-05-07 21:23:40.90604
1043	3	84	150	g	150	0	0	\N	\N	2026-05-07 21:23:48.949881
1044	3	1	16	oz	40	1	0	\N	\N	2026-05-08 10:03:41.669991
1045	3	3	300	g	203.2	14.2	0	\N	\N	2026-05-08 10:03:49.984481
1046	3	36	100	g	50	1	6.5	\N	\N	2026-05-08 10:03:58.283845
1047	3	7	18	g	84	1.8	2.4	\N	\N	2026-05-08 10:04:07.716537
1048	3	2	11	g	40	10	0	\N	\N	2026-05-08 10:04:15.196925
1049	3	117	90	g	103.8	4.8	3.5	\N	\N	2026-05-08 10:43:34.034175
1050	3	31	160	g	200.3	20	5.3	\N	\N	2026-05-08 11:54:04.133098
1051	3	84	50	g	50	0	0	\N	\N	2026-05-08 11:54:11.513031
1052	3	140	1	cup	220	7	3	\N	\N	2026-05-08 13:21:01.258454
1053	3	124	4	bites	320	22	2	\N	\N	2026-05-08 14:36:49.662676
1054	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-08 14:37:00.94818
1055	3	3	300	g	203.2	14.2	0	\N	\N	2026-05-08 16:57:05.129056
1056	3	104	1	bar	260	10	5	\N	\N	2026-05-08 17:21:13.220849
1057	3	130	0.3	lb	240	30	0	\N	\N	2026-05-08 19:15:14.012736
1058	3	131	0.3	lb	420	24	0	\N	\N	2026-05-08 19:15:24.918115
1059	3	3	300	g	203.2	14.2	0	\N	\N	2026-05-11 10:40:29.927855
1060	3	2	11	g	40	10	0	\N	\N	2026-05-11 10:40:35.475621
1061	3	124	4	bites	320	22	2	\N	\N	2026-05-11 11:34:33.804452
1062	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-11 11:43:07.308277
1063	3	137	2	wheel	140	10	0	\N	\N	2026-05-11 12:30:42.735461
1064	3	52	150	g	82	1.2	3.6	\N	\N	2026-05-11 14:04:50.155055
1065	3	5	3	egg	240	18	0	\N	\N	2026-05-11 14:34:37.576447
1066	3	4	1	slice	80	4	2	\N	\N	2026-05-11 14:34:42.585453
1067	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-11 14:34:47.193689
1068	3	86	1	tortilla	120	3	1	\N	\N	2026-05-11 16:07:07.789392
1069	3	18	1	slice	50	3	0	\N	\N	2026-05-11 16:07:14.50823
1070	3	117	120	g	138.4	6.4	4.7	\N	\N	2026-05-11 16:46:13.654454
1071	3	3	200	g	135.5	9.5	0	\N	\N	2026-05-11 17:40:34.424389
1072	3	39	1.3	burger	530.4	15.6	10.4	\N	\N	2026-05-11 18:55:08.716345
1073	3	29	28	g	120	11.1	0	\N	\N	2026-05-11 20:00:06.033037
1074	3	84	100	g	100	0	0	\N	\N	2026-05-11 18:26:00
1075	3	2	11	g	40	10	0	\N	\N	2026-05-12 09:02:06.717007
1076	3	3	300	g	203.3	14.3	0	\N	\N	2026-05-12 09:02:20.402907
1077	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-12 09:28:08.155735
1078	3	5	2	egg	160	12	0	\N	\N	2026-05-12 11:19:51.90573
1079	3	86	1	tortilla	120	3	1	\N	\N	2026-05-12 11:19:58.257146
1080	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-12 11:31:08.651905
1081	3	142	1	bowl	1000	25	5	\N	\N	2026-05-12 13:47:38.899022
1082	3	68	18	g	77.1	1.3	2.6	\N	\N	2026-05-12 15:42:49.073937
1083	3	29	50	g	214.3	19.8	0	\N	\N	2026-05-12 17:38:17.404964
1084	3	3	250	g	169.4	11.9	0	\N	\N	2026-05-12 18:25:01.482752
1085	3	143	1	burger	500	22	10	\N	\N	2026-05-12 19:09:00.607473
1086	3	2	11	g	40	10	0	\N	\N	2026-05-13 10:31:53.674861
1087	3	52	140	g	76.5	1.1	3.4	\N	\N	2026-05-13 10:32:05.307556
1088	3	3	250	g	169.4	11.9	0	\N	\N	2026-05-13 10:32:10.220955
1089	3	124	4	bites	320	22	2	\N	\N	2026-05-13 11:10:07.456329
1090	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-13 11:10:16.184286
1091	3	144	6	bites	140	14	0	\N	\N	2026-05-13 12:44:18.017735
1092	3	144	6	bites	140	14	0	\N	\N	2026-05-13 12:44:22.570734
1093	3	144	6	bites	140	14	0	\N	\N	2026-05-13 12:44:22.686035
1094	3	137	1	wheel	70	5	0	\N	\N	2026-05-13 14:34:24.663498
1095	3	7	18	g	84	1.8	2.4	\N	\N	2026-05-13 14:43:04.488133
1096	3	29	32	g	137.2	12.7	0	\N	\N	2026-05-13 14:44:39.82439
1097	3	68	18	g	77.1	1.3	2.6	\N	\N	2026-05-13 15:35:01.095132
1098	3	104	1	bar	260	10	5	\N	\N	2026-05-13 15:35:23.961375
1099	3	84	100	g	100	0	0	\N	\N	2026-05-13 16:28:10.687563
1100	3	84	100	g	100	0	0	\N	\N	2026-05-13 16:28:15.019508
1101	3	145	1	large	600	20	12	\N	\N	2026-05-13 19:22:00
1102	3	84	400	g	400	0	0	\N	\N	2026-05-13 17:22:00
1103	3	2	11	g	40	10	0	\N	\N	2026-05-14 10:46:19.453706
1104	3	3	250	g	169.4	11.9	0	\N	\N	2026-05-14 10:46:24.89596
1105	3	52	140	g	76.5	1.1	3.4	\N	\N	2026-05-14 10:46:30.32722
1106	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-14 10:46:38.928562
1107	3	144	12	bites	280	28	0	\N	\N	2026-05-14 12:02:07.311675
1108	3	7	12	g	56	1.2	1.6	\N	\N	2026-05-14 12:58:39.313664
1109	3	124	2	bites	160	11	1	\N	\N	2026-05-14 14:08:09.575814
1110	3	39	1.3	burger	530.4	15.6	10.4	\N	\N	2026-05-14 14:31:55.385898
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: budget_user
--

COPY public.transactions (id, description, amount, date, category_id) FROM stdin;
1	Amazon	8.92	2026-03-02	1
2	Ra Fee	1.37	2026-03-02	1
3	Resident Advisor	45.70	2026-03-02	2
4	Marlstone	15.99	2026-03-02	1
5	Jersey Mikes	32.40	2026-03-02	3
6	Richardson	51.40	2026-03-02	4
7	Sunset Valley Fame	4.00	2026-03-02	3
8	Dallas N Friends Bastrop	3.79	2026-03-02	1
9	Shark'S Burger	33.16	2026-03-02	3
10	Panda Express	13.42	2026-03-02	3
11	Poco Loco	45.49	2026-03-02	5
12	I Kyle Nti	3.89	2026-03-02	1
14	Lupe Tortilla	57.14	2026-03-02	3
15	Vending	2.00	2026-03-03	6
16	Vending	2.75	2026-03-03	6
17	Heb	140.90	2026-03-03	4
18	Wheatsville	11.67	2026-03-03	3
19	Levy Restaurants	15.66	2026-03-03	7
20	Levy Restaurants	5.32	2026-03-03	7
21	Starbucks	5.90	2026-03-05	3
22	Vending	2.75	2026-03-04	6
23	Sabor A Mi	40.57	2026-03-04	3
24	Amazon	8.31	2026-03-05	1
25	Paramount	15.14	2026-03-05	1
26	Wheatsville	11.16	2026-03-05	3
27	Hat Creek Burger	24.64	2026-03-05	3
28	Tarka	12.33	2026-03-06	3
29	Vending	1.25	2026-03-06	6
30	Vending	2.75	2026-03-06	6
31	P Terrys	10.66	2026-03-05	3
32	Shell	37.00	2026-03-05	5
33	Starbucks	5.90	2026-03-04	3
35	Schoolcafe	73.15	2026-03-06	8
36	Kendra Scott Design	70.36	2026-03-06	1
37	Dsw	64.93	2026-03-06	9
38	Op Sout	7.43	2026-03-06	1
39	Mighty Fine Burgers	30.08	2026-03-06	3
40	Poco Loco	48.47	2026-03-07	5
41	Depop	13.95	2026-03-07	1
42	Inside	11.18	2026-03-07	1
43	Poco Loco	9.40	2026-03-07	1
44	Taco Cabana	16.82	2026-03-07	3
45	Sprouts	58.36	2026-03-07	4
46	Richardson	51.40	2026-03-07	4
47	Sunset Valley Fame	4.00	2026-03-07	3
48	Chick Fil A	23.23	2026-03-07	3
49	Fiesta Texas	238.15	2026-03-08	1
50	Cava	13.64	2026-03-08	3
51	The Brunch Spot	104.29	2026-03-08	3
52	Uncle Sharkii Poke	16.13	2026-03-08	3
53	Walmart	37.65	2026-03-08	4
54	Juiceland	10.69	2026-03-09	3
55	Bsw Health	65.00	2026-03-09	10
56	Cabelas	56.58	2026-03-08	11
57	Heb	93.40	2026-03-09	4
58	Austin Warriors	925.00	2026-03-10	12
59	Vending	2.00	2026-03-10	6
61	Amazon	3.62	2026-03-11	1
62	Vending	2.00	2026-03-11	6
63	Kindle	2.58	2026-03-11	1
13	Costco	94.22	2026-03-02	4
34	Costco	94.79	2026-03-06	4
60	Costco	99.38	2026-03-10	4
64	Instill Coffee	3.25	2026-03-11	13
65	Cava	14.29	2026-03-11	3
66	Walmart	26.09	2026-03-11	4
67	Target	3.78	2026-03-11	1
68	Slim Chickens	24.75	2026-03-11	3
69	Momentous	161.80	2026-03-12	14
70	Heb	60.00	2026-03-12	15
71	Starbucks	5.90	2026-03-12	3
72	Heb Gas	41.16	2026-03-12	5
73	Hctra Ez Tag	10.00	2026-03-12	16
74	P Terrys	10.93	2026-03-12	3
75	Heb	7.81	2026-03-12	4
76	Chapala	20.67	2026-03-12	3
77	Richardson	25.70	2026-03-14	4
78	Richardson	10.28	2026-03-14	4
79	Sprouts	42.35	2026-03-14	4
80	Heb	114.96	2026-03-14	4
81	Taco Cabana	8.41	2026-03-14	3
82	Uber	29.71	2026-03-14	1
83	The Usual	5.41	2026-03-14	1
84	Thp Basketball	700.00	2026-03-10	12
85	Heb	25.36	2026-03-15	4
86	Amazon	79.00	2026-03-15	4
87	P Terrys	15.91	2026-03-15	3
88	Costco	112.30	2026-03-15	4
89	Academy	181.24	2026-03-15	11
90	Jayjay Lunch	20.00	2026-03-15	3
91	Walmart	74.77	2026-03-16	1
92	Teapioca	9.28	2026-03-16	3
93	Hat Creek	14.59	2026-03-16	3
94	Cava	27.77	2026-03-16	3
95	Poco Loco	64.40	2026-03-16	5
96	Wheatsville	20.05	2026-03-16	3
97	Taco Cabana	9.90	2026-03-17	3
98	Arc	60.00	2026-03-17	10
99	Wheatsville	10.64	2026-03-19	3
100	Time Out Drug Store	4.32	2026-03-19	1
101	P Terrys	9.31	2026-03-19	3
102	No Manches	39.00	2026-03-19	3
103	Starbucks	6.71	2026-03-19	3
104	Sanantoniometers	3.85	2026-03-19	17
105	Popeyes	18.15	2026-03-19	3
106	Time Out Drug Store	6.58	2026-03-19	1
107	Pretzelmaker	8.99	2026-03-19	3
108	Fashion Jewelry	3.25	2026-03-19	6
109	Dollar General	12.42	2026-03-19	1
110	Mcdonalds	4.32	2026-03-19	3
111	Sharks Burger	23.63	2026-03-19	3
112	Wheatsville	20.00	2026-03-19	3
113	Heb	99.66	2026-03-19	4
114	Dollar General	8.89	2026-03-19	4
115	Costco	127.25	2026-03-20	4
116	Heb	46.52	2026-03-20	4
117	Miniso	2.69	2026-03-20	18
118	Pinkberry	8.51	2026-03-20	3
119	Heb Car Wash	13.99	2026-03-20	1
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: budget_user
--

COPY public."user" (id, username, calorie_goal, protein_goal, fiber_goal, day_start_time, day_end_time) FROM stdin;
4	raquel	1800	180	30	08:00:00	22:00:00
3	jeff	2400	180	40	08:00:00	21:00:00
\.


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: budget_user
--

SELECT pg_catalog.setval('public.categories_id_seq', 18, true);


--
-- Name: food_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: budget_user
--

SELECT pg_catalog.setval('public.food_item_id_seq', 145, true);


--
-- Name: log_entry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: budget_user
--

SELECT pg_catalog.setval('public.log_entry_id_seq', 1110, true);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: budget_user
--

SELECT pg_catalog.setval('public.transactions_id_seq', 119, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: budget_user
--

SELECT pg_catalog.setval('public.user_id_seq', 4, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: food_item food_item_name_key; Type: CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.food_item
    ADD CONSTRAINT food_item_name_key UNIQUE (name);


--
-- Name: food_item food_item_pkey; Type: CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.food_item
    ADD CONSTRAINT food_item_pkey PRIMARY KEY (id);


--
-- Name: log_entry log_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.log_entry
    ADD CONSTRAINT log_entry_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user user_username_key; Type: CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_username_key UNIQUE (username);


--
-- Name: log_entry log_entry_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.log_entry
    ADD CONSTRAINT log_entry_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.food_item(id);


--
-- Name: log_entry log_entry_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.log_entry
    ADD CONSTRAINT log_entry_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: transactions transactions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: budget_user
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 0udYF11EbI1hfDTKlwfLQ0GBZRGauX4I3ainQWJdF9jYXUg8UBFqt7RaSYVtF0b

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

\restrict MOliLp5o1YHQIYAzCeb3o0GBomvkf8zGImAqqIjoVuDa1Hc9BwAtqK8BPTZk1FQ

-- Dumped from database version 14.22 (Debian 14.22-1.pgdg13+1)
-- Dumped by pg_dump version 14.22 (Debian 14.22-1.pgdg13+1)

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
-- PostgreSQL database dump complete
--

\unrestrict MOliLp5o1YHQIYAzCeb3o0GBomvkf8zGImAqqIjoVuDa1Hc9BwAtqK8BPTZk1FQ

--
-- PostgreSQL database cluster dump complete
--


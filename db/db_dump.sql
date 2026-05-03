--
-- PostgreSQL database dump
--

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

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
-- Name: answer_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.answer_status AS ENUM (
    'correct',
    'incorrect',
    'not_attempted'
);


ALTER TYPE public.answer_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: lessons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lessons (
    lesson_id integer NOT NULL,
    name character varying(255),
    description text,
    difficulty smallint,
    "time" interval,
    progress real,
    slide_count smallint
);


ALTER TABLE public.lessons OWNER TO postgres;

--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lessons_lesson_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lessons_lesson_id_seq OWNER TO postgres;

--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lessons_lesson_id_seq OWNED BY public.lessons.lesson_id;


--
-- Name: question_response; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.question_response (
    response_id integer NOT NULL,
    question_id integer,
    response_text text,
    is_correct public.answer_status DEFAULT 'not_attempted'::public.answer_status NOT NULL
);


ALTER TABLE public.question_response OWNER TO postgres;

--
-- Name: question_response_response_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.question_response_response_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.question_response_response_id_seq OWNER TO postgres;

--
-- Name: question_response_response_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.question_response_response_id_seq OWNED BY public.question_response.response_id;


--
-- Name: slide_image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slide_image (
    image_id integer NOT NULL,
    slide_id integer,
    image_url character varying(2048)
);


ALTER TABLE public.slide_image OWNER TO postgres;

--
-- Name: slide_image_image_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slide_image_image_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slide_image_image_id_seq OWNER TO postgres;

--
-- Name: slide_image_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slide_image_image_id_seq OWNED BY public.slide_image.image_id;


--
-- Name: slide_question; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slide_question (
    question_id integer NOT NULL,
    slide_id integer,
    question text,
    result boolean
);


ALTER TABLE public.slide_question OWNER TO postgres;

--
-- Name: slide_question_question_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slide_question_question_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slide_question_question_id_seq OWNER TO postgres;

--
-- Name: slide_question_question_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slide_question_question_id_seq OWNED BY public.slide_question.question_id;


--
-- Name: slide_video; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slide_video (
    video_id integer NOT NULL,
    slide_id integer,
    video_url character varying(2048)
);


ALTER TABLE public.slide_video OWNER TO postgres;

--
-- Name: slide_video_video_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slide_video_video_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slide_video_video_id_seq OWNER TO postgres;

--
-- Name: slide_video_video_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slide_video_video_id_seq OWNED BY public.slide_video.video_id;


--
-- Name: slides; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slides (
    slide_id integer NOT NULL,
    lesson_id integer,
    count smallint,
    title character varying(255),
    body text,
    type character varying(50),
    completed boolean DEFAULT false
);


ALTER TABLE public.slides OWNER TO postgres;

--
-- Name: user_lesson_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_lesson_progress (
    user_id character varying(36) NOT NULL,
    lesson_id integer NOT NULL,
    progress real DEFAULT 0
);


ALTER TABLE public.user_lesson_progress OWNER TO postgres;

--
-- Name: user_slide_completion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_slide_completion (
    user_id character varying(36) NOT NULL,
    lesson_id integer NOT NULL,
    slide_number integer NOT NULL,
    completed boolean DEFAULT false
);


ALTER TABLE public.user_slide_completion OWNER TO postgres;

--
-- Name: slides_slide_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slides_slide_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slides_slide_id_seq OWNER TO postgres;

--
-- Name: slides_slide_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slides_slide_id_seq OWNED BY public.slides.slide_id;


--
-- Name: lessons lesson_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons ALTER COLUMN lesson_id SET DEFAULT nextval('public.lessons_lesson_id_seq'::regclass);


--
-- Name: question_response response_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_response ALTER COLUMN response_id SET DEFAULT nextval('public.question_response_response_id_seq'::regclass);


--
-- Name: slide_image image_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slide_image ALTER COLUMN image_id SET DEFAULT nextval('public.slide_image_image_id_seq'::regclass);


--
-- Name: slide_question question_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slide_question ALTER COLUMN question_id SET DEFAULT nextval('public.slide_question_question_id_seq'::regclass);


--
-- Name: slide_video video_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slide_video ALTER COLUMN video_id SET DEFAULT nextval('public.slide_video_video_id_seq'::regclass);


--
-- Name: slides slide_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slides ALTER COLUMN slide_id SET DEFAULT nextval('public.slides_slide_id_seq'::regclass);


--
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lessons (lesson_id, name, description, difficulty, "time", progress, slide_count) FROM stdin;
1	Staying Safe Online	Learn the fundamental rules of staying safe on the internet, including what to share and what to keep private.	1	00:08:00	0	4
2	Spotting Phishing Scams	Discover how to identify fake emails, suspicious links, and phishing attempts designed to steal your data.	2	00:10:00	0	4
3	Creating Strong Passwords	Understand what makes a password strong and how to manage your passwords safely across different accounts.	1	00:08:00	0	4
4	Social Media Safety	Learn how to protect your personal information and stay safe when using social media platforms.	2	00:10:00	0	4
\.


--
-- Data for Name: question_response; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.question_response (response_id, question_id, response_text, is_correct) FROM stdin;
1	1	Your home address	not_attempted
2	1	Your favourite colour	not_attempted
3	1	The name of a movie you like	not_attempted
4	2	Leave the site and do not provide the information	not_attempted
5	2	Fill it in anyway	not_attempted
6	2	Share only your first name	not_attempted
7	3	To steal your personal information or login details	not_attempted
8	3	To send you useful news updates	not_attempted
9	3	To verify your identity securely	not_attempted
10	4	An urgent request asking you to click a link	not_attempted
11	4	A message from a known contact	not_attempted
12	4	An email with your name in the subject line	not_attempted
13	5	X#9mP!qL2$vR	not_attempted
14	5	password123	not_attempted
15	5	john1990	not_attempted
16	6	To securely store and organise your passwords	not_attempted
17	6	To share passwords with friends	not_attempted
18	6	To generate usernames	not_attempted
19	7	Your location and daily routine	not_attempted
20	7	A book recommendation	not_attempted
21	7	A photo of a sunset	not_attempted
22	8	Set them to private so only trusted people can see	not_attempted
23	8	Leave them on public so more people can follow you	not_attempted
24	8	Delete your account entirely	not_attempted
\.


--
-- Data for Name: slide_image; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slide_image (image_id, slide_id, image_url) FROM stdin;
1	2	https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Nuvola_apps_proxy.png/240px-Nuvola_apps_proxy.png
2	6	https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Phishing_diagram.png/640px-Phishing_diagram.png
3	10	https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Password_strength.svg/1200px-Password_strength.svg.png
4	14	https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Social-media-apps.jpg/640px-Social-media-apps.jpg
\.


--
-- Data for Name: slide_question; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slide_question (question_id, slide_id, question, result) FROM stdin;
1	4	Which of the following is an example of personal information?	\N
2	4	What should you do if a website asks for unnecessary personal details?	\N
3	8	What is the main goal of a phishing attack?	\N
4	8	Which of these is a red flag in an email?	\N
5	12	Which of the following is the strongest password?	\N
6	12	What is a password manager used for?	\N
7	16	Which of the following should you avoid posting on social media?	\N
8	16	What should you do with your social media privacy settings?	\N
\.


--
-- Data for Name: slide_video; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slide_video (video_id, slide_id, video_url) FROM stdin;
1	3	https://www.youtube.com/watch?v=aO858HyFbKI
2	7	https://www.youtube.com/watch?v=XBkzBrXlle0
3	11	https://www.youtube.com/watch?v=aEmXfmJBHjA
4	15	https://www.youtube.com/watch?v=FX3PoAVNpko
\.


--
-- Data for Name: slides; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slides (slide_id, lesson_id, count, title, body, type, completed) FROM stdin;
1	1	1	What is Online Safety?	Online safety means protecting yourself and your personal information while using the internet.	text	f
2	1	2	Personal Information	This diagram shows what counts as personal information and why you should keep it private.	image	f
3	1	3	Online Safety Tips	Watch this short video covering the golden rules of staying safe online.	video	f
4	1	4	Online Safety Quiz	Test what you have learned about the basics of online safety.	question	f
5	2	1	What is Phishing?	Phishing is when criminals send fake messages pretending to be trusted organisations to steal your information.	text	f
6	2	2	Anatomy of a Phishing Email	Here is a visual breakdown of a typical phishing email and the red flags to look out for.	image	f
7	2	3	Real Phishing Examples	Watch this video to see real-world examples of phishing scams and how people were tricked.	video	f
8	2	4	Phishing Quiz	Can you spot the phishing attempt? Answer the questions below.	question	f
9	3	1	Why Passwords Matter	Weak passwords are one of the leading causes of account breaches. Learn why strong passwords are essential.	text	f
10	3	2	Strong vs Weak Passwords	This chart compares weak and strong passwords and explains what makes the difference.	image	f
11	3	3	How Hackers Crack Passwords	Watch this video to understand the techniques hackers use to guess or steal passwords.	video	f
12	3	4	Password Safety Quiz	Test your knowledge on creating and managing strong passwords.	question	f
13	4	1	Oversharing Online	Many people accidentally share too much on social media. Learn what information puts you at risk.	text	f
14	4	2	Privacy Settings Guide	Here is a visual guide to the privacy settings available on popular social media platforms.	image	f
15	4	3	Social Media Safety Tips	Watch this video on how to lock down your social media profiles and stay safe online.	video	f
16	4	4	Social Media Quiz	Answer these questions to see how much you know about staying safe on social media.	question	f
\.


--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lessons_lesson_id_seq', 4, true);


--
-- Name: question_response_response_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.question_response_response_id_seq', 24, true);


--
-- Name: slide_image_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slide_image_image_id_seq', 4, true);


--
-- Name: slide_question_question_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slide_question_question_id_seq', 8, true);


--
-- Name: slide_video_video_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slide_video_video_id_seq', 4, true);


--
-- Name: slides_slide_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slides_slide_id_seq', 16, true);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (lesson_id);


--
-- Name: question_response question_response_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_response
    ADD CONSTRAINT question_response_pkey PRIMARY KEY (response_id);


--
-- Name: slide_image slide_image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slide_image
    ADD CONSTRAINT slide_image_pkey PRIMARY KEY (image_id);


--
-- Name: slide_question slide_question_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slide_question
    ADD CONSTRAINT slide_question_pkey PRIMARY KEY (question_id);


--
-- Name: slide_video slide_video_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slide_video
    ADD CONSTRAINT slide_video_pkey PRIMARY KEY (video_id);


--
-- Name: slides slides_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slides
    ADD CONSTRAINT slides_pkey PRIMARY KEY (slide_id);


--
-- Name: user_lesson_progress user_lesson_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_lesson_progress
    ADD CONSTRAINT user_lesson_progress_pkey PRIMARY KEY (user_id, lesson_id);


--
-- Name: user_slide_completion user_slide_completion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_slide_completion
    ADD CONSTRAINT user_slide_completion_pkey PRIMARY KEY (user_id, lesson_id, slide_number);


--
-- Name: question_response question_response_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_response
    ADD CONSTRAINT question_response_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.slide_question(question_id);


--
-- Name: slide_image slide_image_slide_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slide_image
    ADD CONSTRAINT slide_image_slide_id_fkey FOREIGN KEY (slide_id) REFERENCES public.slides(slide_id);


--
-- Name: slide_question slide_question_slide_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slide_question
    ADD CONSTRAINT slide_question_slide_id_fkey FOREIGN KEY (slide_id) REFERENCES public.slides(slide_id);


--
-- Name: slide_video slide_video_slide_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slide_video
    ADD CONSTRAINT slide_video_slide_id_fkey FOREIGN KEY (slide_id) REFERENCES public.slides(slide_id);


--
-- Name: slides slides_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slides
    ADD CONSTRAINT slides_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(lesson_id);


--
-- Name: user_lesson_progress user_lesson_progress_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_lesson_progress
    ADD CONSTRAINT user_lesson_progress_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(lesson_id);


--
-- Name: user_slide_completion user_slide_completion_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_slide_completion
    ADD CONSTRAINT user_slide_completion_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(lesson_id);


--
-- PostgreSQL database dump complete
--
--
-- PostgreSQL database dump
--

\restrict ba3swzt6HE6shd8bY1o67n1tX4qneuOjeoe6dzsUDHdc3tBC7CG8b5CszEMc95L

-- Dumped from database version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)

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
-- Name: batch_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.batch_status AS ENUM (
    'active',
    'expired',
    'low_stock',
    'out_of_stock'
);


ALTER TYPE public.batch_status OWNER TO postgres;

--
-- Name: transaction_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.transaction_status AS ENUM (
    'completed',
    'pending',
    'cancelled'
);


ALTER TYPE public.transaction_status OWNER TO postgres;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'manager',
    'cashier',
    'warehouse',
    'seller'
);


ALTER TYPE public.user_role OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    id integer NOT NULL,
    user_id integer,
    action character varying(255),
    table_name character varying(100),
    record_id integer,
    old_values jsonb,
    new_values jsonb,
    ip_address character varying(45),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_log_id_seq OWNER TO postgres;

--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_log_id_seq OWNED BY public.audit_log.id;


--
-- Name: batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.batches (
    id integer NOT NULL,
    product_id integer NOT NULL,
    batch_number character varying(100) NOT NULL,
    quantity_in_stock integer NOT NULL,
    expiry_date date NOT NULL,
    purchase_price numeric(10,2),
    status public.batch_status DEFAULT 'active'::public.batch_status,
    received_date date DEFAULT CURRENT_DATE,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.batches OWNER TO postgres;

--
-- Name: batches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.batches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.batches_id_seq OWNER TO postgres;

--
-- Name: batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.batches_id_seq OWNED BY public.batches.id;


--
-- Name: dashboard_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dashboard_metrics (
    id integer NOT NULL,
    metric_date date,
    total_sales numeric(12,2),
    total_transactions integer,
    low_stock_items integer,
    expired_items integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.dashboard_metrics OWNER TO postgres;

--
-- Name: dashboard_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dashboard_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dashboard_metrics_id_seq OWNER TO postgres;

--
-- Name: dashboard_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dashboard_metrics_id_seq OWNED BY public.dashboard_metrics.id;


--
-- Name: inventory_adjustments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_adjustments (
    id integer NOT NULL,
    batch_id integer NOT NULL,
    adjustment_type character varying(50),
    quantity_adjusted integer,
    reason text,
    adjusted_by integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.inventory_adjustments OWNER TO postgres;

--
-- Name: inventory_adjustments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_adjustments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_adjustments_id_seq OWNER TO postgres;

--
-- Name: inventory_adjustments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_adjustments_id_seq OWNED BY public.inventory_adjustments.id;


--
-- Name: inventory_movements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_movements (
    id integer NOT NULL,
    batch_id integer NOT NULL,
    quantity_change integer NOT NULL,
    reason character varying(100) NOT NULL,
    user_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.inventory_movements OWNER TO postgres;

--
-- Name: inventory_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_movements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_movements_id_seq OWNER TO postgres;

--
-- Name: inventory_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_movements_id_seq OWNED BY public.inventory_movements.id;


--
-- Name: message_templates; Type: TABLE; Schema: public; Owner: pharmsecure_user
--

CREATE TABLE public.message_templates (
    id integer NOT NULL,
    type character varying(20),
    name character varying(100),
    subject character varying(255),
    body text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.message_templates OWNER TO pharmsecure_user;

--
-- Name: message_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: pharmsecure_user
--

CREATE SEQUENCE public.message_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.message_templates_id_seq OWNER TO pharmsecure_user;

--
-- Name: message_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pharmsecure_user
--

ALTER SEQUENCE public.message_templates_id_seq OWNED BY public.message_templates.id;


--
-- Name: pending_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pending_orders (
    id integer NOT NULL,
    seller_id integer NOT NULL,
    customer_name character varying(255),
    customer_phone character varying(20),
    items_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    subtotal numeric(12,2) DEFAULT 0,
    tax numeric(12,2) DEFAULT 0,
    total_amount numeric(12,2) DEFAULT 0,
    status character varying(50) DEFAULT 'DRAFT'::character varying,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    transferred_at timestamp without time zone,
    completed_at timestamp without time zone,
    auto_delete_at timestamp without time zone,
    refund_status character varying(50),
    refunded_at timestamp without time zone,
    refund_reason character varying(255),
    CONSTRAINT valid_status CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'READY_FOR_PAYMENT'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[])))
);


ALTER TABLE public.pending_orders OWNER TO postgres;

--
-- Name: pending_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pending_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pending_orders_id_seq OWNER TO postgres;

--
-- Name: pending_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pending_orders_id_seq OWNED BY public.pending_orders.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    sku character varying(100) NOT NULL,
    description text,
    category character varying(100),
    unit_price numeric(10,2) NOT NULL,
    reorder_level integer DEFAULT 10,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: refunds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refunds (
    id integer NOT NULL,
    order_id integer NOT NULL,
    refund_amount numeric(10,2) NOT NULL,
    refund_reason character varying(255) NOT NULL,
    refund_status character varying(50) DEFAULT 'PENDING'::character varying,
    approved_by integer,
    approved_at timestamp without time zone,
    processed_at timestamp without time zone,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.refunds OWNER TO postgres;

--
-- Name: refunds_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.refunds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.refunds_id_seq OWNER TO postgres;

--
-- Name: refunds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.refunds_id_seq OWNED BY public.refunds.id;


--
-- Name: return_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.return_items (
    id integer NOT NULL,
    refund_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    reason character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.return_items OWNER TO postgres;

--
-- Name: return_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.return_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.return_items_id_seq OWNER TO postgres;

--
-- Name: return_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.return_items_id_seq OWNED BY public.return_items.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permissions (
    id integer NOT NULL,
    role public.user_role NOT NULL,
    permission character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.role_permissions OWNER TO postgres;

--
-- Name: role_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.role_permissions_id_seq OWNER TO postgres;

--
-- Name: role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_permissions_id_seq OWNED BY public.role_permissions.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(255),
    permissions jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales (
    id integer NOT NULL,
    transaction_number character varying(100) NOT NULL,
    user_id integer NOT NULL,
    total_amount numeric(12,2),
    discount_amount numeric(10,2) DEFAULT 0,
    payment_method character varying(50),
    status public.transaction_status DEFAULT 'completed'::public.transaction_status,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sales OWNER TO postgres;

--
-- Name: sales_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sales_id_seq OWNER TO postgres;

--
-- Name: sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sales_id_seq OWNED BY public.sales.id;


--
-- Name: sales_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_items (
    id integer NOT NULL,
    sale_id integer NOT NULL,
    batch_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity_sold integer NOT NULL,
    unit_price numeric(10,2),
    line_total numeric(12,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sales_items OWNER TO postgres;

--
-- Name: sales_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sales_items_id_seq OWNER TO postgres;

--
-- Name: sales_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sales_items_id_seq OWNED BY public.sales_items.id;


--
-- Name: sent_emails; Type: TABLE; Schema: public; Owner: pharmsecure_user
--

CREATE TABLE public.sent_emails (
    id integer NOT NULL,
    order_id integer,
    recipient_email character varying(255),
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20)
);


ALTER TABLE public.sent_emails OWNER TO pharmsecure_user;

--
-- Name: sent_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: pharmsecure_user
--

CREATE SEQUENCE public.sent_emails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sent_emails_id_seq OWNER TO pharmsecure_user;

--
-- Name: sent_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pharmsecure_user
--

ALTER SEQUENCE public.sent_emails_id_seq OWNED BY public.sent_emails.id;


--
-- Name: sent_sms; Type: TABLE; Schema: public; Owner: pharmsecure_user
--

CREATE TABLE public.sent_sms (
    id integer NOT NULL,
    order_id integer,
    phone_number character varying(20),
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20)
);


ALTER TABLE public.sent_sms OWNER TO pharmsecure_user;

--
-- Name: sent_sms_id_seq; Type: SEQUENCE; Schema: public; Owner: pharmsecure_user
--

CREATE SEQUENCE public.sent_sms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sent_sms_id_seq OWNER TO pharmsecure_user;

--
-- Name: sent_sms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pharmsecure_user
--

ALTER SEQUENCE public.sent_sms_id_seq OWNED BY public.sent_sms.id;


--
-- Name: user_audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_audit_log (
    id integer NOT NULL,
    user_id integer,
    action character varying(100) NOT NULL,
    details jsonb,
    ip_address character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_audit_log OWNER TO postgres;

--
-- Name: user_audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_audit_log_id_seq OWNER TO postgres;

--
-- Name: user_audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_audit_log_id_seq OWNED BY public.user_audit_log.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role public.user_role DEFAULT 'cashier'::public.user_role,
    full_name character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone,
    role_id integer,
    status character varying(50) DEFAULT 'ACTIVE'::character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: audit_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN id SET DEFAULT nextval('public.audit_log_id_seq'::regclass);


--
-- Name: batches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches ALTER COLUMN id SET DEFAULT nextval('public.batches_id_seq'::regclass);


--
-- Name: dashboard_metrics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_metrics ALTER COLUMN id SET DEFAULT nextval('public.dashboard_metrics_id_seq'::regclass);


--
-- Name: inventory_adjustments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_adjustments ALTER COLUMN id SET DEFAULT nextval('public.inventory_adjustments_id_seq'::regclass);


--
-- Name: inventory_movements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_movements ALTER COLUMN id SET DEFAULT nextval('public.inventory_movements_id_seq'::regclass);


--
-- Name: message_templates id; Type: DEFAULT; Schema: public; Owner: pharmsecure_user
--

ALTER TABLE ONLY public.message_templates ALTER COLUMN id SET DEFAULT nextval('public.message_templates_id_seq'::regclass);


--
-- Name: pending_orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_orders ALTER COLUMN id SET DEFAULT nextval('public.pending_orders_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: refunds id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refunds ALTER COLUMN id SET DEFAULT nextval('public.refunds_id_seq'::regclass);


--
-- Name: return_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_items ALTER COLUMN id SET DEFAULT nextval('public.return_items_id_seq'::regclass);


--
-- Name: role_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions ALTER COLUMN id SET DEFAULT nextval('public.role_permissions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: sales id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales ALTER COLUMN id SET DEFAULT nextval('public.sales_id_seq'::regclass);


--
-- Name: sales_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_items ALTER COLUMN id SET DEFAULT nextval('public.sales_items_id_seq'::regclass);


--
-- Name: sent_emails id; Type: DEFAULT; Schema: public; Owner: pharmsecure_user
--

ALTER TABLE ONLY public.sent_emails ALTER COLUMN id SET DEFAULT nextval('public.sent_emails_id_seq'::regclass);


--
-- Name: sent_sms id; Type: DEFAULT; Schema: public; Owner: pharmsecure_user
--

ALTER TABLE ONLY public.sent_sms ALTER COLUMN id SET DEFAULT nextval('public.sent_sms_id_seq'::regclass);


--
-- Name: user_audit_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_audit_log ALTER COLUMN id SET DEFAULT nextval('public.user_audit_log_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_log (id, user_id, action, table_name, record_id, old_values, new_values, ip_address, created_at) FROM stdin;
\.


--
-- Data for Name: batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.batches (id, product_id, batch_number, quantity_in_stock, expiry_date, purchase_price, status, received_date, created_at, updated_at) FROM stdin;
3	3	BATCH-2024-003	75	2025-10-31	1.50	active	2026-08-25	2026-08-25 16:25:48.143794	2026-08-25 16:25:48.143794
4	4	BATCH-2024-004	150	2025-09-30	3.00	active	2026-08-25	2026-08-25 16:25:48.143794	2026-08-25 16:25:48.143794
5	5	BATCH-2024-005	60	2025-12-15	2.00	active	2026-08-25	2026-08-25 16:25:48.143794	2026-08-25 16:25:48.143794
1	1	BATCH-2024-001	97	2025-12-31	1.00	active	2026-08-25	2026-08-25 16:25:48.143794	2026-08-25 16:25:48.143794
2	2	BATCH-2024-002	17	2025-11-30	1.20	active	2026-08-25	2026-08-25 16:25:48.143794	2026-08-25 16:25:48.143794
7	2	BATCH-001	50	2027-01-01	\N	active	2026-09-15	2026-09-15 13:39:34.983435	2026-09-15 13:39:34.983435
8	4	BATCH-002	30	2027-06-01	\N	active	2026-09-15	2026-09-15 13:39:34.983435	2026-09-15 13:39:34.983435
9	3	BATCH-003	20	2027-03-01	\N	active	2026-09-15	2026-09-15 13:39:34.983435	2026-09-15 13:39:34.983435
10	1	BATCH-004	100	2027-12-01	\N	active	2026-09-15	2026-09-15 13:39:34.983435	2026-09-15 13:39:34.983435
\.


--
-- Data for Name: dashboard_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dashboard_metrics (id, metric_date, total_sales, total_transactions, low_stock_items, expired_items, created_at) FROM stdin;
\.


--
-- Data for Name: inventory_adjustments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_adjustments (id, batch_id, adjustment_type, quantity_adjusted, reason, adjusted_by, created_at) FROM stdin;
\.


--
-- Data for Name: inventory_movements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_movements (id, batch_id, quantity_change, reason, user_id, created_at) FROM stdin;
\.


--
-- Data for Name: message_templates; Type: TABLE DATA; Schema: public; Owner: pharmsecure_user
--

COPY public.message_templates (id, type, name, subject, body, created_at) FROM stdin;
\.


--
-- Data for Name: pending_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pending_orders (id, seller_id, customer_name, customer_phone, items_json, subtotal, tax, total_amount, status, notes, created_at, updated_at, transferred_at, completed_at, auto_delete_at, refund_status, refunded_at, refund_reason) FROM stdin;
1	5	John Cofi	0241234567	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-25 16:37:57.208594	2026-08-25 16:37:57.208594	\N	\N	\N	\N	\N	\N
2	5	John Cofi	0241234567	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-25 16:38:07.577117	2026-08-25 16:38:07.577117	\N	\N	\N	\N	\N	\N
3	5	John Cofi	0241234567	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-25 16:41:49.189673	2026-08-25 16:41:49.189673	\N	\N	\N	\N	\N	\N
6	6	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 1, "quantity": 3, "line_total": 7.5, "product_id": 1, "unit_price": 2.5, "product_name": "Paracetamol 500mg"}, {"batch_id": 4, "quantity": 2, "line_total": 16, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}]	26.50	3.97	30.48	COMPLETED	\N	2026-08-25 17:00:55.338995	2026-08-25 17:00:55.338995	\N	\N	\N	\N	\N	\N
12	6	Walk-in	\N	[{"batch_id": 2, "quantity": 2, "line_total": 6, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	6.00	0.90	6.90	READY_FOR_PAYMENT	\N	2026-08-25 20:30:38.713287	2026-08-25 20:30:38.713287	\N	\N	\N	\N	\N	\N
4	5	John Doe	0241234567	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 4, "quantity": 2, "line_total": 16, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 5, "quantity": 4, "line_total": 22, "product_id": 5, "unit_price": 5.5, "product_name": "Vitamin C 1000mg"}]	41.00	6.15	47.15	COMPLETED	\N	2026-08-25 16:44:43.132277	2026-08-25 16:44:43.132277	\N	\N	\N	\N	\N	\N
8	6	Walk-in	\N	[{"batch_id": 2, "quantity": 2, "line_total": 6, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	6.00	0.90	6.90	COMPLETED	\N	2026-08-25 20:06:33.908619	2026-08-25 20:06:33.908619	\N	\N	\N	\N	\N	\N
7	6	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 4, "quantity": 3, "line_total": 24, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}]	27.00	4.05	31.05	COMPLETED	\N	2026-08-25 17:24:28.998626	2026-08-25 17:24:28.998626	\N	\N	\N	\N	\N	\N
5	6	Walk-in	\N	[{"batch_id": 3, "quantity": 2, "line_total": 8, "product_id": 3, "unit_price": 4, "product_name": "Ibuprofen 400mg"}, {"batch_id": 4, "quantity": 3, "line_total": 24, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 5, "quantity": 2, "line_total": 11, "product_id": 5, "unit_price": 5.5, "product_name": "Vitamin C 1000mg"}]	43.00	6.45	49.45	COMPLETED	\N	2026-08-25 16:51:24.567285	2026-08-25 16:51:24.567285	\N	\N	\N	\N	\N	\N
30	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 12:07:21.336794	2026-08-26 12:07:21.336794	\N	\N	\N	\N	\N	\N
13	6	Walk-in	\N	[{"batch_id": 4, "quantity": 4, "line_total": 32, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}]	32.00	4.80	36.80	READY_FOR_PAYMENT	\N	2026-08-25 20:33:56.29311	2026-08-25 20:33:56.29311	\N	\N	\N	\N	\N	\N
11	6	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	3.00	0.45	3.45	READY_FOR_PAYMENT	\N	2026-08-25 20:22:11.228827	2026-08-25 20:22:11.228827	\N	\N	\N	\N	\N	\N
17	6	Walk-in	\N	[{"batch_id": 1, "quantity": 3, "line_total": 7.5, "product_id": 1, "unit_price": 2.5, "product_name": "Paracetamol 500mg"}]	7.50	1.13	8.63	COMPLETED	\N	2026-08-25 20:45:09.142358	2026-08-25 20:45:09.142358	\N	\N	\N	\N	\N	\N
14	6	Walk-in	\N	[{"batch_id": 5, "quantity": 5, "line_total": 27.5, "product_id": 5, "unit_price": 5.5, "product_name": "Vitamin C 1000mg"}]	27.50	4.13	31.63	READY_FOR_PAYMENT	\N	2026-08-25 20:35:25.447556	2026-08-25 20:35:25.447556	\N	\N	\N	\N	\N	\N
18	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-25 21:16:26.255517	2026-08-25 21:16:26.255517	\N	\N	\N	\N	\N	\N
15	6	Walk-in	\N	[{"batch_id": 5, "quantity": 3, "line_total": 16.5, "product_id": 5, "unit_price": 5.5, "product_name": "Vitamin C 1000mg"}]	16.50	2.48	18.98	READY_FOR_PAYMENT	\N	2026-08-25 20:37:25.740659	2026-08-25 20:37:25.740659	\N	\N	\N	\N	\N	\N
19	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-25 21:17:18.8648	2026-08-25 21:17:18.8648	\N	\N	\N	\N	\N	\N
16	6	Walk-in	\N	[{"batch_id": 4, "quantity": 3, "line_total": 24, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}]	24.00	3.60	27.60	READY_FOR_PAYMENT	\N	2026-08-25 20:42:34.367599	2026-08-25 20:42:34.367599	\N	\N	\N	\N	\N	\N
20	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 11:01:35.168406	2026-08-26 11:01:35.168406	\N	\N	\N	\N	\N	\N
21	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 11:02:46.827203	2026-08-26 11:02:46.827203	\N	\N	\N	\N	\N	\N
22	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 11:04:13.20767	2026-08-26 11:04:13.20767	\N	\N	\N	\N	\N	\N
23	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 11:07:46.661996	2026-08-26 11:07:46.661996	\N	\N	\N	\N	\N	\N
24	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 11:16:51.680646	2026-08-26 11:16:51.680646	\N	\N	\N	\N	\N	\N
25	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 11:17:02.793413	2026-08-26 11:17:02.793413	\N	\N	\N	\N	\N	\N
26	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 11:17:17.055484	2026-08-26 11:17:17.055484	\N	\N	\N	\N	\N	\N
27	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 11:30:20.329186	2026-08-26 11:30:20.329186	\N	\N	\N	\N	\N	\N
28	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 11:31:43.352275	2026-08-26 11:31:43.352275	\N	\N	\N	\N	\N	\N
29	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 11:51:09.968349	2026-08-26 11:51:09.968349	\N	\N	\N	\N	\N	\N
31	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-26 12:26:06.434904	2026-08-26 12:26:06.434904	\N	\N	\N	\N	\N	\N
32	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-27 15:56:27.78122	2026-08-27 15:56:27.78122	\N	\N	\N	\N	\N	\N
33	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-27 15:57:29.601459	2026-08-27 15:57:29.601459	\N	\N	\N	\N	\N	\N
34	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-30 20:23:42.830998	2026-08-30 20:23:42.830998	\N	\N	\N	\N	\N	\N
35	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-30 20:28:22.215152	2026-08-30 20:28:22.215152	\N	\N	\N	\N	\N	\N
36	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-30 20:30:12.675485	2026-08-30 20:30:12.675485	\N	\N	\N	\N	\N	\N
37	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-30 20:43:06.660264	2026-08-30 20:43:06.660264	\N	\N	\N	\N	\N	\N
38	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-30 20:43:32.818168	2026-08-30 20:43:32.818168	\N	\N	\N	\N	\N	\N
39	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-30 20:47:12.390116	2026-08-30 20:47:12.390116	\N	\N	\N	\N	\N	\N
40	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-30 20:47:52.74136	2026-08-30 20:47:52.74136	\N	\N	\N	\N	\N	\N
41	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-30 20:50:21.325429	2026-08-30 20:50:21.325429	\N	\N	\N	\N	\N	\N
42	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-30 20:52:21.789162	2026-08-30 20:52:21.789162	\N	\N	\N	\N	\N	\N
43	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-08-31 09:41:31.106307	2026-08-31 09:41:31.106307	\N	\N	\N	\N	\N	\N
10	6	Walk-in	\N	[{"batch_id": 2, "quantity": 4, "line_total": 12, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	12.00	1.80	13.80	COMPLETED	\N	2026-08-25 20:19:06.932015	2026-08-25 20:19:06.932015	\N	\N	\N	\N	\N	\N
44	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	6.00	0.90	6.90	DRAFT	\N	2026-09-09 18:35:11.775003	2026-09-09 18:35:11.775003	\N	\N	\N	\N	\N	\N
45	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-09 19:55:27.578147	2026-09-09 19:55:27.578147	\N	\N	\N	\N	\N	\N
46	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	3.00	0.45	3.45	DRAFT	\N	2026-09-09 19:55:32.275723	2026-09-09 19:55:32.275723	\N	\N	\N	\N	\N	\N
60	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	3.00	0.45	3.45	DRAFT	\N	2026-09-09 20:53:24.319167	2026-09-09 20:53:24.319167	\N	\N	\N	\N	\N	\N
47	5	Walk-in	\N	[{"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 3, "quantity": 1, "line_total": 4, "product_id": 3, "unit_price": 4, "product_name": "Ibuprofen 400mg"}]	12.00	1.80	13.80	DRAFT	\N	2026-09-09 19:55:44.064448	2026-09-09 19:55:44.064448	\N	\N	\N	\N	\N	\N
48	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-09 19:55:58.265599	2026-09-09 19:55:58.265599	\N	\N	\N	\N	\N	\N
49	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	6.00	0.90	6.90	DRAFT	\N	2026-09-09 19:59:05.395274	2026-09-09 19:59:05.395274	\N	\N	\N	\N	\N	\N
50	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	3.00	0.45	3.45	DRAFT	\N	2026-09-09 20:03:31.646153	2026-09-09 20:03:31.646153	\N	\N	\N	\N	\N	\N
51	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-09 20:04:19.715405	2026-09-09 20:04:19.715405	\N	\N	\N	\N	\N	\N
52	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-09 20:06:15.858054	2026-09-09 20:06:15.858054	\N	\N	\N	\N	\N	\N
53	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	3.00	0.45	3.45	DRAFT	\N	2026-09-09 20:06:57.311717	2026-09-09 20:06:57.311717	\N	\N	\N	\N	\N	\N
54	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	3.00	0.45	3.45	DRAFT	\N	2026-09-09 20:09:49.845663	2026-09-09 20:09:49.845663	\N	\N	\N	\N	\N	\N
55	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	3.00	0.45	3.45	DRAFT	\N	2026-09-09 20:30:26.179029	2026-09-09 20:30:26.179029	\N	\N	\N	\N	\N	\N
61	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	3.00	0.45	3.45	DRAFT	\N	2026-09-09 20:55:11.907248	2026-09-09 20:55:11.907248	\N	\N	\N	\N	\N	\N
56	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	6.00	0.90	6.90	DRAFT	\N	2026-09-09 20:30:45.093275	2026-09-09 20:30:45.093275	\N	\N	\N	\N	\N	\N
62	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 1, "quantity": 1, "line_total": 2.5, "product_id": 1, "unit_price": 2.5, "product_name": "Paracetamol 500mg"}, {"batch_id": 3, "quantity": 1, "line_total": 4, "product_id": 3, "unit_price": 4, "product_name": "Ibuprofen 400mg"}, {"batch_id": 1, "quantity": 1, "line_total": 2.5, "product_id": 1, "unit_price": 2.5, "product_name": "Paracetamol 500mg"}]	20.00	3.00	23.00	DRAFT	\N	2026-09-09 21:16:18.765551	2026-09-09 21:16:18.765551	\N	\N	\N	\N	\N	\N
57	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	9.00	1.35	10.35	DRAFT	\N	2026-09-09 20:31:26.278423	2026-09-09 20:31:26.278423	\N	\N	\N	\N	\N	\N
58	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	3.00	0.45	3.45	DRAFT	\N	2026-09-09 20:31:35.687823	2026-09-09 20:31:35.687823	\N	\N	\N	\N	\N	\N
59	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	3.00	0.45	3.45	DRAFT	\N	2026-09-09 20:53:18.278208	2026-09-09 20:53:18.278208	\N	\N	\N	\N	\N	\N
63	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	12.00	1.80	13.80	DRAFT	\N	2026-09-09 21:19:29.750648	2026-09-09 21:19:29.750648	\N	\N	\N	\N	\N	\N
64	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	21.00	3.15	24.15	DRAFT	\N	2026-09-09 21:19:54.445677	2026-09-09 21:19:54.445677	\N	\N	\N	\N	\N	\N
65	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}, {"batch_id": 4, "quantity": 1, "line_total": 8, "product_id": 4, "unit_price": 8, "product_name": "Cough Syrup"}]	91.00	13.65	104.65	DRAFT	\N	2026-09-09 21:20:23.73368	2026-09-09 21:20:23.73368	\N	\N	\N	\N	\N	\N
66	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	27.00	4.05	31.05	DRAFT	\N	2026-09-09 21:20:50.69719	2026-09-09 21:20:50.69719	\N	\N	\N	\N	\N	\N
67	5	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	6.00	0.90	6.90	DRAFT	\N	2026-09-09 21:22:08.047504	2026-09-09 21:22:08.047504	\N	\N	\N	\N	\N	\N
68	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-09 23:09:56.598108	2026-09-09 23:09:56.598108	\N	\N	\N	\N	\N	\N
69	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-09 23:12:29.517913	2026-09-09 23:12:29.517913	\N	\N	\N	\N	\N	\N
70	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-09 23:16:40.199571	2026-09-09 23:16:40.199571	\N	\N	\N	\N	\N	\N
71	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-10 08:00:50.121665	2026-09-10 08:00:50.121665	\N	\N	\N	\N	\N	\N
72	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-10 08:01:41.773285	2026-09-10 08:01:41.773285	\N	\N	\N	\N	\N	\N
78	5	Kofi Dosse	0244481514	[{"quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"quantity": 1, "line_total": 2.5, "product_id": 1, "unit_price": 2.5, "product_name": "Paracetamol 500mg"}]	5.50	0.83	6.33	COMPLETED	\N	2026-09-15 20:55:15.068451	2026-09-15 20:55:15.068451	\N	\N	\N	\N	\N	\N
73	1	Walk-in	\N	[{"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}, {"batch_id": 2, "quantity": 1, "line_total": 3, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	51.00	7.65	58.65	DRAFT	\N	2026-09-10 08:06:53.884469	2026-09-10 08:06:53.884469	\N	\N	\N	\N	\N	\N
9	6	Walk-in	\N	[{"batch_id": 2, "quantity": 3, "line_total": 9, "product_id": 2, "unit_price": 3, "product_name": "Aspirin 500mg"}]	9.00	1.35	10.35	COMPLETED	\N	2026-08-25 20:10:45.496551	2026-08-25 20:10:45.496551	\N	\N	\N	\N	\N	\N
74	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-11 19:12:21.824557	2026-09-11 19:12:21.824557	\N	\N	\N	\N	\N	\N
75	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-15 20:21:53.258275	2026-09-15 20:21:53.258275	\N	\N	\N	\N	\N	\N
76	5	Walk-in	\N	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-15 20:32:58.36076	2026-09-15 20:32:58.36076	\N	\N	\N	\N	\N	\N
77	5	Kofi Akpabie	0558209706	[]	0.00	0.00	0.00	DRAFT	\N	2026-09-15 20:35:36.935184	2026-09-15 20:35:36.935184	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, sku, description, category, unit_price, reorder_level, is_active, created_at, updated_at) FROM stdin;
1	Paracetamol 500mg	PARA-500	Pain reliever	Pain Relief	2.50	10	t	2026-08-25 15:36:23.531616	2026-08-25 15:36:23.531616
2	Aspirin 500mg	ASPI-500	Fever reducer	Pain Relief	3.00	10	t	2026-08-25 15:36:23.531616	2026-08-25 15:36:23.531616
3	Ibuprofen 400mg	IBUP-400	Anti-inflammatory	Pain Relief	4.00	10	t	2026-08-25 15:36:23.531616	2026-08-25 15:36:23.531616
4	Cough Syrup	COUGH-SYR	Cough relief	Cough & Cold	8.00	10	t	2026-08-25 15:36:23.531616	2026-08-25 15:36:23.531616
5	Vitamin C 1000mg	VITC-1000	Immune booster	Vitamins	5.50	10	t	2026-08-25 15:36:23.531616	2026-08-25 15:36:23.531616
\.


--
-- Data for Name: refunds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refunds (id, order_id, refund_amount, refund_reason, refund_status, approved_by, approved_at, processed_at, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: return_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.return_items (id, refund_id, product_id, quantity, reason, created_at) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permissions (id, role, permission, created_at) FROM stdin;
1	admin	view_dashboard	2026-08-23 22:50:15.244407
2	admin	manage_users	2026-08-23 22:50:15.244407
3	admin	manage_inventory	2026-08-23 22:50:15.244407
4	admin	manage_sales	2026-08-23 22:50:15.244407
5	admin	view_reports	2026-08-23 22:50:15.244407
6	manager	view_dashboard	2026-08-23 22:50:15.244407
7	manager	manage_inventory	2026-08-23 22:50:15.244407
8	manager	manage_sales	2026-08-23 22:50:15.244407
9	cashier	view_dashboard	2026-08-23 22:50:15.244407
10	cashier	manage_sales	2026-08-23 22:50:15.244407
11	warehouse	manage_inventory	2026-08-23 22:50:15.244407
12	warehouse	view_inventory	2026-08-23 22:50:15.244407
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, description, permissions, created_at, updated_at) FROM stdin;
1	Admin	Full system access	{"pos": true, "staff": true, "refunds": true, "reports": true, "printing": true, "dashboard": true, "inventory": true}	2026-08-27 11:56:14.521599	2026-08-27 11:56:14.521599
2	Manager	Dashboard, reports, inventory management	{"pos": false, "staff": false, "refunds": true, "reports": true, "printing": true, "dashboard": true, "inventory": true}	2026-08-27 11:56:14.521599	2026-08-27 11:56:14.521599
3	Seller	POS access for selling products	{"pos": true, "staff": false, "refunds": false, "reports": false, "printing": false, "dashboard": false, "inventory": true}	2026-08-27 11:56:14.521599	2026-08-27 11:56:14.521599
4	Cashier	Payment processing and receipts	{"pos": true, "staff": false, "refunds": false, "reports": false, "printing": true, "dashboard": false, "inventory": false}	2026-08-27 11:56:14.521599	2026-08-27 11:56:14.521599
5	Pharmacist	Inventory and drug management	{"pos": false, "staff": false, "refunds": true, "reports": true, "printing": false, "dashboard": true, "inventory": true}	2026-08-27 11:56:14.521599	2026-08-27 16:37:58.520849
\.


--
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales (id, transaction_number, user_id, total_amount, discount_amount, payment_method, status, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sales_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_items (id, sale_id, batch_id, product_id, quantity_sold, unit_price, line_total, created_at) FROM stdin;
\.


--
-- Data for Name: sent_emails; Type: TABLE DATA; Schema: public; Owner: pharmsecure_user
--

COPY public.sent_emails (id, order_id, recipient_email, sent_at, status) FROM stdin;
1	4	kofierasmus2018@gmail.com	2026-09-01 19:59:24.965659	sent
2	4	kofierasmus2018@gmail.com	2026-09-01 20:15:56.079812	sent
\.


--
-- Data for Name: sent_sms; Type: TABLE DATA; Schema: public; Owner: pharmsecure_user
--

COPY public.sent_sms (id, order_id, phone_number, sent_at, status) FROM stdin;
\.


--
-- Data for Name: user_audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_audit_log (id, user_id, action, details, ip_address, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, password_hash, role, full_name, is_active, created_at, updated_at, last_login, role_id, status) FROM stdin;
5	seller1	seller1@pharmacy.local	$2b$10$5nTsGZ6fPE0nIn0QayZJceCe1TPUpNYUZEuzD8YyknliS027JlH6O	seller	\N	t	2026-08-25 12:06:06.915474	2026-08-25 12:06:06.915474	\N	1	ACTIVE
4	manager	manager@pharmsecure.com	PASTE_HASH_HERE	manager	Manager User	t	2026-08-24 11:04:54.81464	2026-08-24 11:04:54.81464	\N	2	ACTIVE
3	testuser	test@pharmacy.com	$2a$10$rdD32PYu5wwJwyWH0tFOTOCYIQtB56FT0jikO1AJdndVJBIe1cb.C	cashier	Test User	t	2026-08-24 10:44:36.723531	2026-08-24 10:44:36.723531	2026-08-24 11:44:15.072511	3	ACTIVE
6	cashier1	cashier1@pharmacy.local	$2b$10$TvqZZgPkOqFfqGNc4wt5iOUSGvvBpOgmEUFpArl7bMaeLHMuV6i2e	cashier	\N	t	2026-08-25 12:06:06.915474	2026-08-25 12:06:06.915474	\N	4	ACTIVE
1	admin	admin@pharmsecure.com	$2b$10$mVgPmEejuLlW.ZcGCeIjKehn94Fgz2Ptoazx2sChlHpWNyWf4Qj7q	admin	Admin User	t	2026-08-24 08:50:04.597865	2026-08-24 08:50:04.597865	2026-08-24 12:09:15.449221	1	ACTIVE
\.


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 1, false);


--
-- Name: batches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.batches_id_seq', 10, true);


--
-- Name: dashboard_metrics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dashboard_metrics_id_seq', 1, false);


--
-- Name: inventory_adjustments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_adjustments_id_seq', 1, false);


--
-- Name: inventory_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_movements_id_seq', 1, false);


--
-- Name: message_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pharmsecure_user
--

SELECT pg_catalog.setval('public.message_templates_id_seq', 1, false);


--
-- Name: pending_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pending_orders_id_seq', 78, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 5, true);


--
-- Name: refunds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refunds_id_seq', 1, false);


--
-- Name: return_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.return_items_id_seq', 1, false);


--
-- Name: role_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_permissions_id_seq', 24, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 5, true);


--
-- Name: sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sales_id_seq', 1, false);


--
-- Name: sales_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sales_items_id_seq', 1, false);


--
-- Name: sent_emails_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pharmsecure_user
--

SELECT pg_catalog.setval('public.sent_emails_id_seq', 2, true);


--
-- Name: sent_sms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pharmsecure_user
--

SELECT pg_catalog.setval('public.sent_sms_id_seq', 1, false);


--
-- Name: user_audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_audit_log_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 6, true);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: batches batches_batch_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_batch_number_key UNIQUE (batch_number);


--
-- Name: batches batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_pkey PRIMARY KEY (id);


--
-- Name: dashboard_metrics dashboard_metrics_metric_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_metrics
    ADD CONSTRAINT dashboard_metrics_metric_date_key UNIQUE (metric_date);


--
-- Name: dashboard_metrics dashboard_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_metrics
    ADD CONSTRAINT dashboard_metrics_pkey PRIMARY KEY (id);


--
-- Name: inventory_adjustments inventory_adjustments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_adjustments
    ADD CONSTRAINT inventory_adjustments_pkey PRIMARY KEY (id);


--
-- Name: inventory_movements inventory_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_pkey PRIMARY KEY (id);


--
-- Name: message_templates message_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: pharmsecure_user
--

ALTER TABLE ONLY public.message_templates
    ADD CONSTRAINT message_templates_pkey PRIMARY KEY (id);


--
-- Name: pending_orders pending_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_orders
    ADD CONSTRAINT pending_orders_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);


--
-- Name: return_items return_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_items
    ADD CONSTRAINT return_items_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_role_permission_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_permission_key UNIQUE (role, permission);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sales_items sales_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_items
    ADD CONSTRAINT sales_items_pkey PRIMARY KEY (id);


--
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);


--
-- Name: sales sales_transaction_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_transaction_number_key UNIQUE (transaction_number);


--
-- Name: sent_emails sent_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: pharmsecure_user
--

ALTER TABLE ONLY public.sent_emails
    ADD CONSTRAINT sent_emails_pkey PRIMARY KEY (id);


--
-- Name: sent_sms sent_sms_pkey; Type: CONSTRAINT; Schema: public; Owner: pharmsecure_user
--

ALTER TABLE ONLY public.sent_sms
    ADD CONSTRAINT sent_sms_pkey PRIMARY KEY (id);


--
-- Name: user_audit_log user_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_audit_log
    ADD CONSTRAINT user_audit_log_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_audit_action; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_action ON public.user_audit_log USING btree (action);


--
-- Name: idx_audit_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_date ON public.user_audit_log USING btree (created_at);


--
-- Name: idx_audit_log_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_log_user_id ON public.audit_log USING btree (user_id);


--
-- Name: idx_audit_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_user ON public.user_audit_log USING btree (user_id);


--
-- Name: idx_batches_expiry; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_batches_expiry ON public.batches USING btree (expiry_date);


--
-- Name: idx_batches_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_batches_product_id ON public.batches USING btree (product_id);


--
-- Name: idx_movements_batch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_movements_batch ON public.inventory_movements USING btree (batch_id);


--
-- Name: idx_movements_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_movements_date ON public.inventory_movements USING btree (created_at);


--
-- Name: idx_pending_orders_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pending_orders_created_at ON public.pending_orders USING btree (created_at);


--
-- Name: idx_pending_orders_seller_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pending_orders_seller_id ON public.pending_orders USING btree (seller_id);


--
-- Name: idx_pending_orders_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pending_orders_status ON public.pending_orders USING btree (status);


--
-- Name: idx_products_sku; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_sku ON public.products USING btree (sku);


--
-- Name: idx_refunds_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refunds_created ON public.refunds USING btree (created_at);


--
-- Name: idx_refunds_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refunds_order ON public.refunds USING btree (order_id);


--
-- Name: idx_refunds_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refunds_status ON public.refunds USING btree (refund_status);


--
-- Name: idx_return_items_refund; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_return_items_refund ON public.return_items USING btree (refund_id);


--
-- Name: idx_sales_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_created_at ON public.sales USING btree (created_at);


--
-- Name: idx_sales_items_sale_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_items_sale_id ON public.sales_items USING btree (sale_id);


--
-- Name: idx_sales_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_user_id ON public.sales USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role_id);


--
-- Name: idx_users_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_status ON public.users USING btree (status);


--
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_username ON public.users USING btree (username);


--
-- Name: audit_log audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: batches batches_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: inventory_adjustments inventory_adjustments_adjusted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_adjustments
    ADD CONSTRAINT inventory_adjustments_adjusted_by_fkey FOREIGN KEY (adjusted_by) REFERENCES public.users(id);


--
-- Name: inventory_adjustments inventory_adjustments_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_adjustments
    ADD CONSTRAINT inventory_adjustments_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);


--
-- Name: inventory_movements inventory_movements_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);


--
-- Name: inventory_movements inventory_movements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pending_orders pending_orders_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_orders
    ADD CONSTRAINT pending_orders_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.users(id);


--
-- Name: refunds refunds_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT refunds_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: refunds refunds_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT refunds_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.pending_orders(id);


--
-- Name: return_items return_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_items
    ADD CONSTRAINT return_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: return_items return_items_refund_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_items
    ADD CONSTRAINT return_items_refund_id_fkey FOREIGN KEY (refund_id) REFERENCES public.refunds(id);


--
-- Name: sales_items sales_items_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_items
    ADD CONSTRAINT sales_items_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);


--
-- Name: sales_items sales_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_items
    ADD CONSTRAINT sales_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: sales_items sales_items_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_items
    ADD CONSTRAINT sales_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- Name: sales sales_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_audit_log user_audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_audit_log
    ADD CONSTRAINT user_audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: TABLE audit_log; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.audit_log TO pharmsecure_user;


--
-- Name: SEQUENCE audit_log_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.audit_log_id_seq TO pharmsecure_user;


--
-- Name: TABLE batches; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.batches TO pharmsecure_user;


--
-- Name: SEQUENCE batches_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.batches_id_seq TO pharmsecure_user;


--
-- Name: TABLE dashboard_metrics; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.dashboard_metrics TO pharmsecure_user;


--
-- Name: SEQUENCE dashboard_metrics_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.dashboard_metrics_id_seq TO pharmsecure_user;


--
-- Name: TABLE inventory_adjustments; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inventory_adjustments TO pharmsecure_user;


--
-- Name: SEQUENCE inventory_adjustments_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.inventory_adjustments_id_seq TO pharmsecure_user;


--
-- Name: TABLE pending_orders; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.pending_orders TO pharmsecure_user;


--
-- Name: SEQUENCE pending_orders_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.pending_orders_id_seq TO pharmsecure_user;


--
-- Name: TABLE products; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.products TO pharmsecure_user;


--
-- Name: SEQUENCE products_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.products_id_seq TO pharmsecure_user;


--
-- Name: TABLE role_permissions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.role_permissions TO pharmsecure_user;


--
-- Name: SEQUENCE role_permissions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.role_permissions_id_seq TO pharmsecure_user;


--
-- Name: TABLE roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,UPDATE ON TABLE public.roles TO pharmsecure_user;


--
-- Name: TABLE sales; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.sales TO pharmsecure_user;


--
-- Name: SEQUENCE sales_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.sales_id_seq TO pharmsecure_user;


--
-- Name: TABLE sales_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.sales_items TO pharmsecure_user;


--
-- Name: SEQUENCE sales_items_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.sales_items_id_seq TO pharmsecure_user;


--
-- Name: TABLE user_audit_log; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.user_audit_log TO pharmsecure_user;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.users TO pharmsecure_user;


--
-- Name: SEQUENCE users_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.users_id_seq TO pharmsecure_user;


--
-- PostgreSQL database dump complete
--

\unrestrict ba3swzt6HE6shd8bY1o67n1tX4qneuOjeoe6dzsUDHdc3tBC7CG8b5CszEMc95L


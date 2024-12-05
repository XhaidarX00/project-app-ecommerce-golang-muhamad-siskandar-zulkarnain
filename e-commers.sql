--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

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
-- Name: calculate_distance(numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_distance(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric) RETURNS numeric
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    distance NUMERIC;
BEGIN
    distance := 6371 * acos(
        cos(radians(lat1)) * cos(radians(lat2)) *
        cos(radians(lon2) - radians(lon1)) +
        sin(radians(lat1)) * sin(radians(lat2))
    );
    RETURN distance;
END;
$$;


ALTER FUNCTION public.calculate_distance(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric) OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_items (
    cart_item_id integer NOT NULL,
    cart_id integer,
    product_id integer,
    quantity integer DEFAULT 1,
    shipping_cost numeric(10,2) DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT cart_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT cart_items_shipping_cost_check CHECK ((shipping_cost >= (0)::numeric))
);


ALTER TABLE public.cart_items OWNER TO postgres;

--
-- Name: cart_items_cart_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_items_cart_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_items_cart_item_id_seq OWNER TO postgres;

--
-- Name: cart_items_cart_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_items_cart_item_id_seq OWNED BY public.cart_items.cart_item_id;


--
-- Name: carts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carts (
    cart_id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.carts OWNER TO postgres;

--
-- Name: carts_cart_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.carts_cart_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.carts_cart_id_seq OWNER TO postgres;

--
-- Name: carts_cart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.carts_cart_id_seq OWNED BY public.carts.cart_id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_category_id_seq OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- Name: customer_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_addresses (
    address_id integer NOT NULL,
    user_id integer,
    recipient_name character varying(100) NOT NULL,
    phone_number character varying(20) NOT NULL,
    address_line text NOT NULL,
    city character varying(50) NOT NULL,
    province character varying(50) NOT NULL,
    postal_code character varying(10) NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL,
    is_default boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.customer_addresses OWNER TO postgres;

--
-- Name: customer_addresses_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_addresses_address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_addresses_address_id_seq OWNER TO postgres;

--
-- Name: customer_addresses_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_addresses_address_id_seq OWNED BY public.customer_addresses.address_id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_item_id integer NOT NULL,
    order_id integer,
    product_id integer,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_order_item_id_seq OWNER TO postgres;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_order_item_id_seq OWNED BY public.order_items.order_item_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    user_id integer,
    total_price numeric(10,2) NOT NULL,
    status character varying(50) DEFAULT 'Pending'::character varying,
    payment_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    payment_id integer NOT NULL,
    payment_name character varying(50),
    payment_status character varying(50) DEFAULT 'Pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_payment_id_seq OWNER TO postgres;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_payment_id_seq OWNED BY public.payments.payment_id;


--
-- Name: product_banners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_banners (
    banner_id integer NOT NULL,
    product_id integer,
    banner_name character varying(100) NOT NULL,
    banner_description text,
    banner_photo_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    delete_at timestamp without time zone
);


ALTER TABLE public.product_banners OWNER TO postgres;

--
-- Name: product_banners_banner_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_banners_banner_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_banners_banner_id_seq OWNER TO postgres;

--
-- Name: product_banners_banner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_banners_banner_id_seq OWNED BY public.product_banners.banner_id;


--
-- Name: product_colors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_colors (
    color_id integer NOT NULL,
    product_id integer,
    color_name character varying(50) NOT NULL,
    stock integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.product_colors OWNER TO postgres;

--
-- Name: product_colors_color_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_colors_color_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_colors_color_id_seq OWNER TO postgres;

--
-- Name: product_colors_color_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_colors_color_id_seq OWNED BY public.product_colors.color_id;


--
-- Name: product_gallery; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_gallery (
    gallery_id integer NOT NULL,
    product_id integer,
    color_id integer,
    image_url text NOT NULL
);


ALTER TABLE public.product_gallery OWNER TO postgres;

--
-- Name: product_gallery_gallery_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_gallery_gallery_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_gallery_gallery_id_seq OWNER TO postgres;

--
-- Name: product_gallery_gallery_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_gallery_gallery_id_seq OWNED BY public.product_gallery.gallery_id;


--
-- Name: product_promo_weekly; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_promo_weekly (
    promo_weekly_id integer NOT NULL,
    product_id integer,
    promo_weekly_name character varying(100) NOT NULL,
    promo_weekly_description text,
    promo_weekly_photo_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    delete_at timestamp without time zone
);


ALTER TABLE public.product_promo_weekly OWNER TO postgres;

--
-- Name: product_promo_weekly_promo_weekly_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_promo_weekly_promo_weekly_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_promo_weekly_promo_weekly_id_seq OWNER TO postgres;

--
-- Name: product_promo_weekly_promo_weekly_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_promo_weekly_promo_weekly_id_seq OWNED BY public.product_promo_weekly.promo_weekly_id;


--
-- Name: product_recomments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_recomments (
    recomment_id integer NOT NULL,
    product_id integer,
    recomment_name character varying(100) NOT NULL,
    recomment_description text,
    recomment_photo_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    delete_at timestamp without time zone
);


ALTER TABLE public.product_recomments OWNER TO postgres;

--
-- Name: product_recomments_recomment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_recomments_recomment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_recomments_recomment_id_seq OWNER TO postgres;

--
-- Name: product_recomments_recomment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_recomments_recomment_id_seq OWNED BY public.product_recomments.recomment_id;


--
-- Name: product_variants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variants (
    variant_id integer NOT NULL,
    product_id integer,
    size character varying(10),
    type character varying(50),
    stock integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.product_variants OWNER TO postgres;

--
-- Name: product_variants_variant_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_variants_variant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_variants_variant_id_seq OWNER TO postgres;

--
-- Name: product_variants_variant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_variants_variant_id_seq OWNED BY public.product_variants.variant_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    discount numeric(5,2) DEFAULT NULL::numeric,
    stock integer NOT NULL,
    category_id integer,
    photo_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    discount_price numeric(10,2) GENERATED ALWAYS AS (
CASE
    WHEN (discount IS NOT NULL) THEN (price * ((1)::numeric - (discount / (100)::numeric)))
    ELSE price
END) STORED
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_product_id_seq OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviews (
    review_id integer NOT NULL,
    user_id integer,
    product_id integer,
    rating numeric(2,1),
    review_text text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1.0) AND (rating <= 5.0)))
);


ALTER TABLE public.reviews OWNER TO postgres;

--
-- Name: reviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reviews_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_review_id_seq OWNER TO postgres;

--
-- Name: reviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reviews_review_id_seq OWNED BY public.reviews.review_id;


--
-- Name: seller_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seller_addresses (
    address_id integer NOT NULL,
    user_id integer,
    order_id integer,
    recipient_name character varying(100) NOT NULL,
    phone_number character varying(20) NOT NULL,
    address_line text NOT NULL,
    city character varying(50) NOT NULL,
    province character varying(50) NOT NULL,
    postal_code character varying(10) NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.seller_addresses OWNER TO postgres;

--
-- Name: seller_addresses_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seller_addresses_address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seller_addresses_address_id_seq OWNER TO postgres;

--
-- Name: seller_addresses_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seller_addresses_address_id_seq OWNED BY public.seller_addresses.address_id;


--
-- Name: shipping_costs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_costs (
    shipping_cost_id integer NOT NULL,
    order_id integer,
    distance_km numeric(10,2) NOT NULL,
    cost numeric(10,2) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.shipping_costs OWNER TO postgres;

--
-- Name: shipping_costs_shipping_cost_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shipping_costs_shipping_cost_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shipping_costs_shipping_cost_id_seq OWNER TO postgres;

--
-- Name: shipping_costs_shipping_cost_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shipping_costs_shipping_cost_id_seq OWNED BY public.shipping_costs.shipping_cost_id;


--
-- Name: shippings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shippings (
    shipping_id integer NOT NULL,
    courier_name character varying(100) NOT NULL,
    service_type character varying(50) NOT NULL,
    base_cost numeric(10,2) NOT NULL,
    cost_per_km numeric(10,2) NOT NULL,
    max_weight_kg numeric(5,2) NOT NULL,
    estimated_time text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.shippings OWNER TO postgres;

--
-- Name: shippings_shipping_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shippings_shipping_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shippings_shipping_id_seq OWNER TO postgres;

--
-- Name: shippings_shipping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shippings_shipping_id_seq OWNED BY public.shippings.shipping_id;


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tokens (
    token_id integer NOT NULL,
    user_id integer,
    token character varying(255) NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


ALTER TABLE public.tokens OWNER TO postgres;

--
-- Name: tokens_token_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tokens_token_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tokens_token_id_seq OWNER TO postgres;

--
-- Name: tokens_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tokens_token_id_seq OWNED BY public.tokens.token_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(100),
    phone_number character varying(15),
    password character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: cart_items cart_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN cart_item_id SET DEFAULT nextval('public.cart_items_cart_item_id_seq'::regclass);


--
-- Name: carts cart_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts ALTER COLUMN cart_id SET DEFAULT nextval('public.carts_cart_id_seq'::regclass);


--
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- Name: customer_addresses address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_addresses ALTER COLUMN address_id SET DEFAULT nextval('public.customer_addresses_address_id_seq'::regclass);


--
-- Name: order_items order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_items_order_item_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: payments payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN payment_id SET DEFAULT nextval('public.payments_payment_id_seq'::regclass);


--
-- Name: product_banners banner_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_banners ALTER COLUMN banner_id SET DEFAULT nextval('public.product_banners_banner_id_seq'::regclass);


--
-- Name: product_colors color_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_colors ALTER COLUMN color_id SET DEFAULT nextval('public.product_colors_color_id_seq'::regclass);


--
-- Name: product_gallery gallery_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_gallery ALTER COLUMN gallery_id SET DEFAULT nextval('public.product_gallery_gallery_id_seq'::regclass);


--
-- Name: product_promo_weekly promo_weekly_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_promo_weekly ALTER COLUMN promo_weekly_id SET DEFAULT nextval('public.product_promo_weekly_promo_weekly_id_seq'::regclass);


--
-- Name: product_recomments recomment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_recomments ALTER COLUMN recomment_id SET DEFAULT nextval('public.product_recomments_recomment_id_seq'::regclass);


--
-- Name: product_variants variant_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants ALTER COLUMN variant_id SET DEFAULT nextval('public.product_variants_variant_id_seq'::regclass);


--
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- Name: reviews review_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews ALTER COLUMN review_id SET DEFAULT nextval('public.reviews_review_id_seq'::regclass);


--
-- Name: seller_addresses address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seller_addresses ALTER COLUMN address_id SET DEFAULT nextval('public.seller_addresses_address_id_seq'::regclass);


--
-- Name: shipping_costs shipping_cost_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_costs ALTER COLUMN shipping_cost_id SET DEFAULT nextval('public.shipping_costs_shipping_cost_id_seq'::regclass);


--
-- Name: shippings shipping_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings ALTER COLUMN shipping_id SET DEFAULT nextval('public.shippings_shipping_id_seq'::regclass);


--
-- Name: tokens token_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens ALTER COLUMN token_id SET DEFAULT nextval('public.tokens_token_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_items (cart_item_id, cart_id, product_id, quantity, shipping_cost, created_at, updated_at) FROM stdin;
2	1	4	1	0.00	2024-11-23 14:24:29.767523	2024-11-23 20:03:42.674204
\.


--
-- Data for Name: carts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carts (cart_id, user_id, created_at) FROM stdin;
1	1	2024-11-18 21:36:44.677919
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (category_id, name, description, created_at, updated_at) FROM stdin;
1	Electronics	Electronic devices and gadgets	2024-11-18 21:36:36.909968	2024-11-18 21:36:36.909968
2	Fashion	Clothing and accessories	2024-11-18 21:36:36.909968	2024-11-18 21:36:36.909968
3	Books	Books of various genres	2024-11-18 21:36:36.909968	2024-11-18 21:36:36.909968
4	Home Appliances	Household items and appliances	2024-11-18 21:36:36.909968	2024-11-18 21:36:36.909968
\.


--
-- Data for Name: customer_addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_addresses (address_id, user_id, recipient_name, phone_number, address_line, city, province, postal_code, latitude, longitude, is_default, created_at) FROM stdin;
1	1	Ucup	081234567890	Jl. Sudirman No.1	Jakarta	DKI Jakarta	10110	-6.200000	106.816600	t	2024-11-23 16:56:32.676467
3	1	Susi	083456789012	Jl. MH Thamrin No.3	Jakarta	DKI Jakarta	10330	-6.200200	106.816800	f	2024-11-23 16:56:40.691245
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (order_item_id, order_id, product_id, quantity, price, created_at, updated_at) FROM stdin;
22	1	1	2	3000000.00	2024-11-23 19:13:55.701467	2024-11-23 19:13:55.701467
23	1	7	1	75000.00	2024-11-23 19:13:55.701467	2024-11-23 19:13:55.701467
24	2	2	3	1500000.00	2024-11-23 19:13:55.701467	2024-11-23 19:13:55.701467
25	2	6	2	350000.00	2024-11-23 19:13:55.701467	2024-11-23 19:13:55.701467
26	3	4	5	500000.00	2024-11-23 19:13:55.701467	2024-11-23 19:13:55.701467
27	4	8	1	125000.00	2024-11-23 19:13:55.701467	2024-11-23 19:13:55.701467
28	5	10	1	2500000.00	2024-11-23 19:13:55.701467	2024-11-23 19:13:55.701467
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, user_id, total_price, status, payment_id, created_at, updated_at) FROM stdin;
1	1	6150000.00	Completed	1	2024-11-23 19:13:42.677444	2024-11-23 19:13:42.677444
2	2	7350000.00	Completed	2	2024-11-23 19:13:42.677444	2024-11-23 19:13:42.677444
3	3	4500000.00	Pending	3	2024-11-23 19:13:42.677444	2024-11-23 19:13:42.677444
4	4	125000.00	Completed	4	2024-11-23 19:13:42.677444	2024-11-23 19:13:42.677444
5	5	2500000.00	Processing	5	2024-11-23 19:13:42.677444	2024-11-23 19:13:42.677444
6	1	6150000.00	1	1	2024-11-23 19:54:31.194727	2024-11-23 19:54:31.194727
8	1	6150000.00	1	2	2024-11-23 19:56:53.635764	2024-11-23 19:56:53.635764
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (payment_id, payment_name, payment_status, created_at) FROM stdin;
1	Credit Card	Completed	2024-11-23 19:10:11.26215
2	Bank Transfer	Completed	2024-11-23 19:10:11.26215
3	Credit Card	Pending	2024-11-23 19:10:11.26215
4	Cash on Delivery	Completed	2024-11-23 19:10:11.26215
5	Bank Transfer	Pending	2024-11-23 19:10:11.26215
\.


--
-- Data for Name: product_banners; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_banners (banner_id, product_id, banner_name, banner_description, banner_photo_url, created_at, delete_at) FROM stdin;
1	1	Smartphone A	Limited time offer!	https://example.com/banner-smartphone-x.jpg	2024-11-20 13:48:48.020218	2024-11-30 23:59:59
2	2	Smartphone B	Huge savings on high-performance Smartphone	https://example.com/banner-laptop-z.jpg	2024-11-20 13:48:48.020218	2024-11-25 23:59:59
3	3	Laptop X	High-performance laptop for gaming and work	https://example.com/images/laptop_x.jpg	2024-11-20 13:48:48.020218	2024-11-27 23:59:59
\.


--
-- Data for Name: product_colors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_colors (color_id, product_id, color_name, stock) FROM stdin;
1	1	White	20
2	1	Black	20
3	1	Blue	10
4	2	Silver	40
5	2	Gold	40
6	2	Gray	20
7	3	Black	10
8	3	Gray	5
9	3	Red	5
10	4	Black	100
11	4	White	50
12	4	Blue	50
13	5	White	200
14	5	Black	150
15	5	Gray	150
16	6	Red	100
17	6	Blue	100
18	6	White	100
19	7	Blue	30
20	7	Black	30
21	7	Gray	40
22	8	White	20
23	8	Yellow	20
24	8	Red	10
25	9	Gray	20
26	9	Black	30
27	9	Blue	30
28	10	White	20
29	10	Gray	20
30	10	Black	20
\.


--
-- Data for Name: product_gallery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_gallery (gallery_id, product_id, color_id, image_url) FROM stdin;
31	1	1	https://example.com/images/smartphone_a_white.jpg
32	1	2	https://example.com/images/smartphone_a_black.jpg
33	1	3	https://example.com/images/smartphone_a_blue.jpg
34	2	4	https://example.com/images/smartphone_b_silver.jpg
35	2	5	https://example.com/images/smartphone_b_gold.jpg
36	2	6	https://example.com/images/smartphone_b_gray.jpg
37	3	7	https://example.com/images/laptop_x_black.jpg
38	3	8	https://example.com/images/laptop_x_gray.jpg
39	3	9	https://example.com/images/laptop_x_red.jpg
40	4	10	https://example.com/images/headphones_z_black.jpg
41	4	11	https://example.com/images/headphones_z_white.jpg
42	4	12	https://example.com/images/headphones_z_blue.jpg
43	5	13	https://example.com/images/tshirt_classic_white.jpg
44	5	14	https://example.com/images/tshirt_classic_black.jpg
45	5	15	https://example.com/images/tshirt_classic_gray.jpg
46	6	16	https://example.com/images/sneakers_pro_red.jpg
47	6	17	https://example.com/images/sneakers_pro_blue.jpg
48	6	18	https://example.com/images/sneakers_pro_white.jpg
49	7	19	https://example.com/images/mystery_novel_blue.jpg
50	7	20	https://example.com/images/mystery_novel_black.jpg
51	7	21	https://example.com/images/mystery_novel_gray.jpg
52	8	22	https://example.com/images/cookbook_deluxe_white.jpg
53	8	23	https://example.com/images/cookbook_deluxe_yellow.jpg
54	8	24	https://example.com/images/cookbook_deluxe_red.jpg
55	9	25	https://example.com/images/vacuum_cleaner_v_gray.jpg
56	9	26	https://example.com/images/vacuum_cleaner_v_black.jpg
57	9	27	https://example.com/images/vacuum_cleaner_v_blue.jpg
58	10	28	https://example.com/images/air_purifier_white.jpg
59	10	29	https://example.com/images/air_purifier_gray.jpg
60	10	30	https://example.com/images/air_purifier_black.jpg
\.


--
-- Data for Name: product_promo_weekly; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_promo_weekly (promo_weekly_id, product_id, promo_weekly_name, promo_weekly_description, promo_weekly_photo_url, created_at, delete_at) FROM stdin;
1	4	Headphones Z	Noise-cancelling headphones for clear audio	https://example.com/images/headphones_z.jpg	2024-11-20 14:18:47.306127	2024-11-30 23:59:59
2	5	T-shirt Classic	Comfortable cotton t-shirt in multiple sizes	https://example.com/images/tshirt_classic.jpg	2024-11-20 14:18:47.306127	2024-11-25 23:59:59
3	6	Sneakers Pro	Lightweight and durable sneakers for sports	https://example.com/images/sneakers_pro.jpg	2024-11-20 14:18:47.306127	2024-11-25 23:59:59
4	7	Mystery Novel	Bestselling mystery novel by famous author	https://example.com/images/mystery_novel.jpg	2024-11-20 14:18:47.306127	2024-11-25 23:59:59
\.


--
-- Data for Name: product_recomments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_recomments (recomment_id, product_id, recomment_name, recomment_description, recomment_photo_url, created_at, delete_at) FROM stdin;
1	8	Cookbook Deluxe	A collection of gourmet recipes	https://example.com/images/cookbook_deluxe.jpg	2024-11-21 17:24:30.16171	2024-11-30 23:59:59
2	9	Vacuum Cleaner V	Powerful and compact vacuum cleaner	https://example.com/images/vacuum_cleaner_v.jpg	2024-11-21 17:24:30.16171	2024-11-30 23:59:59
3	10	Air Purifier	Improves air quality and reduces allergens	https://example.com/images/air_purifier.jpg	2024-11-21 17:24:30.16171	2024-11-30 23:59:59
\.


--
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variants (variant_id, product_id, size, type, stock) FROM stdin;
1	1	5.5	Storage: 64GB, Screen 	20
2	1	5.5	Storage: 128GB, Screen 	20
3	1	5.5	Storage: 256GB, Screen 	10
4	2	6.1	Storage: 32GB, Screen 	40
5	2	6.1	Storage: 64GB, Screen 	40
6	2	6.1	Storage: 128GB, Screen 	20
7	3	14	Storage: 256GB SSD, RAM: 8GB	5
8	3	20	Storage: 512GB SSD, RAM: 16GB	10
9	3	18	Storage: 1TB SSD, RAM: 32GB	5
10	4	ONE SIZE	Color: Black, Noise Cancellation: Yes	100
11	4	ONE SIZE	Color: White, Noise Cancellation: Yes	50
12	4	ONE SIZE	Color: Blue, Noise Cancellation: Yes	50
13	5	S	ONE TYPE	150
14	5	M	ONE TYPE	200
15	5	L	ONE TYPE	150
16	6	39	ONE TYPE	100
17	6	40	ONE TYPE	150
18	6	41	ONE TYPE	50
19	7	ONE SIZE	Format: Hardcover	20
20	7	ONE SIZE	Format: Paperback	30
21	7	ONE SIZE	Format: Ebook	50
22	8	ONE SIZE	Format: Hardcover	15
23	8	ONE SIZE	Format: Paperback	20
24	8	ONE SIZE	Format: Ebook	15
25	9	ONE SIZE	Capacity: 2L, Type: Compact	10
26	9	ONE SIZE	Capacity: 3L, Type: Standard	30
27	9	ONE SIZE	Capacity: 5L, Type: Premium	40
28	10	ONE SIZE	Room Size: Small (up to 150 sq ft)	20
29	10	ONE SIZE	Room Size: Medium (up to 300 sq ft)	25
30	10	ONE SIZE	Room Size: Large (up to 500 sq ft)	15
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (product_id, name, description, price, discount, stock, category_id, photo_url, created_at, updated_at) FROM stdin;
1	Smartphone A	Latest model smartphone with 128GB storage	3000000.00	10.00	50	1	https://example.com/images/smartphone_a.jpg	2024-11-21 21:31:23.641828	2024-11-21 21:31:23.641828
2	Smartphone B	Budget-friendly smartphone with dual cameras	1500000.00	\N	100	1	https://example.com/images/smartphone_b.jpg	2024-11-21 21:31:23.641828	2024-11-21 21:31:23.641828
3	Laptop X	High-performance laptop for gaming and work	10000000.00	5.00	20	1	https://example.com/images/laptop_x.jpg	2024-11-21 21:31:23.641828	2024-11-21 21:31:23.641828
4	Headphones Z	Noise-cancelling headphones for clear audio	500000.00	10.00	200	1	https://example.com/images/headphones_z.jpg	2024-11-21 21:31:23.641828	2024-11-21 21:31:23.641828
5	T-shirt Classic	Comfortable cotton t-shirt in multiple sizes	100000.00	5.00	500	2	https://example.com/images/tshirt_classic.jpg	2024-11-21 21:31:23.641828	2024-11-21 21:31:23.641828
6	Sneakers Pro	Lightweight and durable sneakers for sports	350000.00	14.29	300	2	https://example.com/images/sneakers_pro.jpg	2024-11-21 21:31:23.641828	2024-11-21 21:31:23.641828
7	Mystery Novel	Bestselling mystery novel by famous author	75000.00	6.67	100	3	https://example.com/images/mystery_novel.jpg	2024-11-21 21:31:23.641828	2024-11-21 21:31:23.641828
8	Cookbook Deluxe	A collection of gourmet recipes	125000.00	\N	50	3	https://example.com/images/cookbook_deluxe.jpg	2024-11-21 21:31:23.641828	2024-11-21 21:31:23.641828
9	Vacuum Cleaner V	Powerful and compact vacuum cleaner	1500000.00	6.67	80	4	https://example.com/images/vacuum_cleaner_v.jpg	2024-11-21 21:31:23.641828	2024-11-21 21:31:23.641828
10	Air Purifier	Improves air quality and reduces allergens	2500000.00	\N	60	4	https://example.com/images/air_purifier.jpg	2024-11-21 21:31:23.641828	2024-11-21 21:31:23.641828
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviews (review_id, user_id, product_id, rating, review_text, created_at, updated_at) FROM stdin;
1	1	1	5.0	Great smartphone with amazing performance!	2024-11-18 21:36:55.454051	2024-11-18 21:36:55.454051
2	1	7	4.5	Enjoyed the book, but the ending felt rushed.	2024-11-18 21:36:55.454051	2024-11-18 21:36:55.454051
3	1	2	3.0	Good value for money, but could be improved.	2024-11-18 21:36:55.454051	2024-11-18 21:36:55.454051
4	1	3	5.0	Perfect laptop for work and gaming. Highly recommend!	2024-11-18 21:36:55.454051	2024-11-18 21:36:55.454051
5	1	4	4.0	Great headphones, but a bit tight for long hours of use.	2024-11-18 21:36:55.454051	2024-11-18 21:36:55.454051
\.


--
-- Data for Name: seller_addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.seller_addresses (address_id, user_id, order_id, recipient_name, phone_number, address_line, city, province, postal_code, latitude, longitude, created_at) FROM stdin;
21	2	\N	Tech Store - Jakarta	081234567890	Jl. Sudirman No.1	Jakarta	DKI Jakarta	10110	-6.208800	106.845600	2024-11-22 09:15:04.970054
22	3	\N	Fashion Hub - Bandung	081345678901	Jl. Braga No.99	Bandung	Jawa Barat	40111	-6.917500	107.619100	2024-11-22 09:15:04.970054
23	4	\N	Book World - Surabaya	081456789012	Jl. Basuki Rahmat No.123	Surabaya	Jawa Timur	60271	-7.257500	112.752100	2024-11-22 09:15:04.970054
24	5	\N	Home Essentials - Semarang	081567890123	Jl. Pemuda No.45	Semarang	Jawa Tengah	50132	-6.966700	110.416700	2024-11-22 09:15:04.970054
25	6	\N	Gadget Corner - Medan	081678901234	Jl. Sisingamangaraja No.77	Medan	Sumatera Utara	20217	3.595200	98.672200	2024-11-22 09:15:04.970054
26	7	\N	Trendy Wear - Yogyakarta	081789012345	Jl. Malioboro No.10	Yogyakarta	DI Yogyakarta	55271	-7.795600	110.369500	2024-11-22 09:15:04.970054
27	8	\N	Knowledge Books - Malang	081890123456	Jl. Ijen No.25	Malang	Jawa Timur	65119	-7.977800	112.634900	2024-11-22 09:15:04.970054
28	9	\N	Home Care Essentials - Bali	081901234567	Jl. Sunset Road No.88	Denpasar	Bali	80113	-8.650000	115.216700	2024-11-22 09:15:04.970054
29	10	\N	Sports Gear - Makassar	081012345678	Jl. Ahmad Yani No.12	Makassar	Sulawesi Selatan	90122	-5.147700	119.432700	2024-11-22 09:15:04.970054
30	11	\N	Air Quality Experts - Balikpapan	081112345678	Jl. Soekarno Hatta No.5	Balikpapan	Kalimantan Timur	76112	-1.267500	116.831200	2024-11-22 09:15:04.970054
\.


--
-- Data for Name: shipping_costs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_costs (shipping_cost_id, order_id, distance_km, cost, created_at) FROM stdin;
\.


--
-- Data for Name: shippings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shippings (shipping_id, courier_name, service_type, base_cost, cost_per_km, max_weight_kg, estimated_time, created_at) FROM stdin;
1	JNE	Regular	10000.00	2000.00	30.00	3-5 business days	2024-11-26 13:47:12.192366
2	JNE	Express	20000.00	2500.00	30.00	1-2 business days	2024-11-26 13:47:12.192366
3	POS Indonesia	Standard	8000.00	1500.00	20.00	5-7 business days	2024-11-26 13:47:12.192366
4	POS Indonesia	Express	15000.00	1800.00	20.00	2-3 business days	2024-11-26 13:47:12.192366
5	TIKI	Economy	9000.00	1800.00	25.00	4-6 business days	2024-11-26 13:47:12.192366
6	TIKI	Express	18000.00	2200.00	25.00	1-3 business days	2024-11-26 13:47:12.192366
7	J&T	Regular	9000.00	1700.00	25.00	3-5 business days	2024-11-26 13:47:12.192366
8	J&T	Express	19000.00	2100.00	25.00	1-2 business days	2024-11-26 13:47:12.192366
9	Shopee Express	Standard	7000.00	1600.00	20.00	4-6 business days	2024-11-26 13:47:12.192366
10	Shopee Express	Next-Day	14000.00	2000.00	20.00	1-2 business days	2024-11-26 13:47:12.192366
11	Parcel	Basic	8500.00	1800.00	30.00	3-5 business days	2024-11-26 13:47:12.192366
12	Parcel	Priority	17000.00	2200.00	30.00	1-2 business days	2024-11-26 13:47:12.192366
\.


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tokens (token_id, user_id, token, expires_at) FROM stdin;
1	1	token_admin_1	2024-12-22 10:29:49.645273
2	12	7a7c2b63-e4c9-4e6b-a49a-cc8dcf8de498	2024-12-23 20:06:09.912368
3	16	523db5eb-2b8c-4e5e-8d83-4c595a608199	2024-12-23 20:37:51.411029
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, name, email, phone_number, password, created_at, updated_at) FROM stdin;
1	Iskandar	iskandar@example.com	081234567890	pass123	2024-11-22 09:14:54.323381	2024-11-22 09:14:54.323381
2	Tech Store	techstore@example.com	081234567891	pass123	2024-11-22 09:14:55.571701	2024-11-22 09:14:55.571701
3	Fashion Hub	fashionhub@example.com	081345678901	pass123	2024-11-22 09:14:55.571701	2024-11-22 09:14:55.571701
4	Book World	bookworld@example.com	081456789012	pass123	2024-11-22 09:14:55.571701	2024-11-22 09:14:55.571701
5	Home Essentials	homeessentials@example.com	081567890123	pass123	2024-11-22 09:14:55.571701	2024-11-22 09:14:55.571701
6	Gadget Corner	gadgetcorner@example.com	081678901234	pass123	2024-11-22 09:14:55.571701	2024-11-22 09:14:55.571701
7	Trendy Wear	trendywear@example.com	081789012345	pass123	2024-11-22 09:14:55.571701	2024-11-22 09:14:55.571701
8	Knowledge Books	knowledgebooks@example.com	081890123456	pass123	2024-11-22 09:14:55.571701	2024-11-22 09:14:55.571701
9	Home Care Essentials	homecareessentials@example.com	081901234567	pass123	2024-11-22 09:14:55.571701	2024-11-22 09:14:55.571701
10	Sports Gear	sportsgear@example.com	081012345678	pass123	2024-11-22 09:14:55.571701	2024-11-22 09:14:55.571701
11	Air Quality Experts	airqualityexperts@example.com	081112345678	pass123	2024-11-22 09:14:55.571701	2024-11-22 09:14:55.571701
12	Haidar1	\N	087774247633	pass123	2024-11-23 20:06:09.911171	2024-11-23 20:06:09.911171
16	Haidar2	\N	0877742476333	pass123	2024-11-23 20:37:51.410089	2024-11-23 20:37:51.410089
\.


--
-- Name: cart_items_cart_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_items_cart_item_id_seq', 4, true);


--
-- Name: carts_cart_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.carts_cart_id_seq', 1, true);


--
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_category_id_seq', 4, true);


--
-- Name: customer_addresses_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_addresses_address_id_seq', 3, true);


--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_order_item_id_seq', 28, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 8, true);


--
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_payment_id_seq', 5, true);


--
-- Name: product_banners_banner_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_banners_banner_id_seq', 3, true);


--
-- Name: product_colors_color_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_colors_color_id_seq', 30, true);


--
-- Name: product_gallery_gallery_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_gallery_gallery_id_seq', 60, true);


--
-- Name: product_promo_weekly_promo_weekly_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_promo_weekly_promo_weekly_id_seq', 4, true);


--
-- Name: product_recomments_recomment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_recomments_recomment_id_seq', 3, true);


--
-- Name: product_variants_variant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_variants_variant_id_seq', 30, true);


--
-- Name: products_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_product_id_seq', 10, true);


--
-- Name: reviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reviews_review_id_seq', 5, true);


--
-- Name: seller_addresses_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seller_addresses_address_id_seq', 30, true);


--
-- Name: shipping_costs_shipping_cost_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shipping_costs_shipping_cost_id_seq', 1, false);


--
-- Name: shippings_shipping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shippings_shipping_id_seq', 12, true);


--
-- Name: tokens_token_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tokens_token_id_seq', 3, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 16, true);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (cart_item_id);


--
-- Name: carts carts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (cart_id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: customer_addresses customer_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_addresses
    ADD CONSTRAINT customer_addresses_pkey PRIMARY KEY (address_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: product_banners product_banners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_banners
    ADD CONSTRAINT product_banners_pkey PRIMARY KEY (banner_id);


--
-- Name: product_colors product_colors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_colors
    ADD CONSTRAINT product_colors_pkey PRIMARY KEY (color_id);


--
-- Name: product_gallery product_gallery_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_gallery
    ADD CONSTRAINT product_gallery_pkey PRIMARY KEY (gallery_id);


--
-- Name: product_promo_weekly product_promo_weekly_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_promo_weekly
    ADD CONSTRAINT product_promo_weekly_pkey PRIMARY KEY (promo_weekly_id);


--
-- Name: product_recomments product_recomments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_recomments
    ADD CONSTRAINT product_recomments_pkey PRIMARY KEY (recomment_id);


--
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_pkey PRIMARY KEY (variant_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (review_id);


--
-- Name: seller_addresses seller_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seller_addresses
    ADD CONSTRAINT seller_addresses_pkey PRIMARY KEY (address_id);


--
-- Name: shipping_costs shipping_costs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_costs
    ADD CONSTRAINT shipping_costs_pkey PRIMARY KEY (shipping_cost_id);


--
-- Name: shippings shippings_courier_name_service_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings
    ADD CONSTRAINT shippings_courier_name_service_type_key UNIQUE (courier_name, service_type);


--
-- Name: shippings shippings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings
    ADD CONSTRAINT shippings_pkey PRIMARY KEY (shipping_id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (token_id);


--
-- Name: cart_items unique_cart_product; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT unique_cart_product UNIQUE (cart_id, product_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: unique_default_address_per_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_default_address_per_user ON public.customer_addresses USING btree (user_id) WHERE (is_default = true);


--
-- Name: cart_items set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.cart_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: cart_items cart_items_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.carts(cart_id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: customer_addresses customer_addresses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_addresses
    ADD CONSTRAINT customer_addresses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: orders orders_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payments(payment_id) ON DELETE CASCADE;


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: product_colors product_colors_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_colors
    ADD CONSTRAINT product_colors_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: product_gallery product_gallery_color_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_gallery
    ADD CONSTRAINT product_gallery_color_id_fkey FOREIGN KEY (color_id) REFERENCES public.product_colors(color_id) ON DELETE CASCADE;


--
-- Name: product_gallery product_gallery_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_gallery
    ADD CONSTRAINT product_gallery_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: product_variants product_variants_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id) ON DELETE SET NULL;


--
-- Name: tokens tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


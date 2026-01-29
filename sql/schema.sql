-- =========================
-- ARTIST
-- =========================
CREATE TABLE public.artist (
    artist_id VARCHAR(30) PRIMARY KEY,
    name VARCHAR(150)
);

-- =========================
-- ALBUM
-- =========================
CREATE TABLE public.album (
    album_id VARCHAR(30) PRIMARY KEY,
    title VARCHAR(150),
    artist_id VARCHAR(30),
    CONSTRAINT fk_album_artist
        FOREIGN KEY (artist_id)
        REFERENCES public.artist (artist_id)
        ON DELETE CASCADE
);

-- =========================
-- EMPLOYEE
-- =========================
CREATE TABLE public.employee (
    employee_id VARCHAR(30) PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(250),
    reports_to VARCHAR(30),
    levels VARCHAR(10),
    birth_date Text,
    hire_date Text,
    address VARCHAR(120),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(30),
    postal_code VARCHAR(30),
    phone VARCHAR(30),
    fax VARCHAR(30),
    email VARCHAR(30),
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (reports_to)
        REFERENCES public.employee (employee_id)
        ON DELETE CASCADE
);
alter table employee
-- =========================
-- CUSTOMER
-- =========================
CREATE TABLE public.customer (
    customer_id VARCHAR(30) PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    company VARCHAR(150),
    address VARCHAR(250),
    city VARCHAR(30),
    state VARCHAR(30),
    country VARCHAR(30),
    postal_code VARCHAR(30),
    phone VARCHAR(30),
    fax VARCHAR(30),
    email VARCHAR(30),
    support_rep_id VARCHAR(30),
    CONSTRAINT fk_customer_employee
        FOREIGN KEY (support_rep_id)
        REFERENCES public.employee (employee_id)
        ON DELETE CASCADE
);

-- =========================
-- GENRE
-- =========================
CREATE TABLE public.genre (
    genre_id VARCHAR(30) PRIMARY KEY,
    name VARCHAR(50)
);

-- =========================
-- MEDIA TYPE
-- =========================
CREATE TABLE public.media_type (
    media_type_id VARCHAR(30) PRIMARY KEY,
    name VARCHAR(30)
);

-- =========================
-- TRACK
-- =========================
CREATE TABLE public.track (
    track_id VARCHAR(30) PRIMARY KEY,
    name VARCHAR(250),
    album_id VARCHAR(30),
    media_type_id VARCHAR(30),
    genre_id VARCHAR(30),
    composer VARCHAR(250),
    milliseconds BIGINT,
    bytes INTEGER,
    unit_price NUMERIC,
    CONSTRAINT fk_track_album
        FOREIGN KEY (album_id)
        REFERENCES public.album (album_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_track_media_type
        FOREIGN KEY (media_type_id)
        REFERENCES public.media_type (media_type_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_track_genre
        FOREIGN KEY (genre_id)
        REFERENCES public.genre (genre_id)
        ON DELETE CASCADE
);

-- =========================
-- PLAYLIST
-- =========================
CREATE TABLE public.playlist (
    playlist_id VARCHAR(30) PRIMARY KEY,
    name VARCHAR(50)
);

-- =========================
-- PLAYLIST_TRACK (JUNCTION TABLE)
-- =========================
CREATE TABLE public.playlist_track (
    playlist_id VARCHAR(30),
    track_id VARCHAR(30),
    CONSTRAINT pk_playlist_track
        PRIMARY KEY (playlist_id, track_id),
    CONSTRAINT fk_playlist_track_playlist
        FOREIGN KEY (playlist_id)
        REFERENCES public.playlist (playlist_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_playlist_track_track
        FOREIGN KEY (track_id)
        REFERENCES public.track (track_id)
        ON DELETE CASCADE
);

-- =========================
-- INVOICE
-- =========================
CREATE TABLE public.invoice (
    invoice_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(30),
    invoice_date TIMESTAMP,
    billing_address VARCHAR(120),
    billing_city VARCHAR(30),
    billing_state VARCHAR(30),
    billing_country VARCHAR(30),
    billing_postal VARCHAR(30),
    total DOUBLE PRECISION,
    CONSTRAINT fk_invoice_customer
        FOREIGN KEY (customer_id)
        REFERENCES public.customer (customer_id)
        ON DELETE CASCADE
);

-- =========================
-- INVOICE_LINE
-- =========================
CREATE TABLE public.invoice_line (
    invoice_line_id VARCHAR(30) PRIMARY KEY,
    invoice_id VARCHAR(30),
    track_id VARCHAR(30),
    unit_price NUMERIC,
    quantity INTEGER,
    CONSTRAINT fk_invoice_line_invoice
        FOREIGN KEY (invoice_id)
        REFERENCES public.invoice (invoice_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_invoice_line_track
        FOREIGN KEY (track_id)
        REFERENCES public.track (track_id)
        ON DELETE CASCADE
);




SELECT employee_id, birth_date, hire_date
FROM public.employee
WHERE birth_date IS NOT NULL
  AND birth_date !~ '^\d{2}-\d{2}-\d{4}';
  ALTER TABLE public.employee
    ALTER COLUMN birth_date TYPE TEXT,
    ALTER COLUMN hire_date TYPE TEXT;


ALTER TABLE public.employee
    ALTER COLUMN birth_date TYPE DATE
        USING TO_DATE(birth_date, 'DD-MM-YYYY'),
    ALTER COLUMN hire_date TYPE DATE
        USING TO_DATE(hire_date, 'DD-MM-YYYY');
TRUNCATE TABLE public.playlist CASCADE;

select * from playlist

INSERT INTO public.playlist (playlist_id, name)
SELECT playlist_id, name
FROM playlist_stage
ON CONFLICT (playlist_id) DO NOTHING;

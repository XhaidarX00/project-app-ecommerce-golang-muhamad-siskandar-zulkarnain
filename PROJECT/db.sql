-- Active: 1730083286169@@127.0.0.1@5432@e_commerce@public

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(15) UNIQUE,
    password VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE tokens (
    token_id SERIAL PRIMARY KEY,
    user_id INT,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT category_id, name, description FROM categories;


CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    discount NUMERIC(5, 2) DEFAULT NULL, -- Persentase diskon (0-100)
    stock INT NOT NULL,
    category_id INT REFERENCES categories(category_id) ON DELETE SET NULL,
    photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    discount_price NUMERIC(10, 2) GENERATED ALWAYS AS 
        (CASE 
            WHEN discount IS NOT NULL THEN price * (1 - discount / 100) 
            ELSE price 
        END) STORED -- Diskon otomatis dihitung
);



CREATE TABLE product_banners (
    banner_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    banner_name VARCHAR(100) NOT NULL,
    banner_description TEXT,
    banner_photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delete_at TIMESTAMP
);


CREATE TABLE product_promo_weekly (
    promo_weekly_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    promo_weekly_name VARCHAR(100) NOT NULL,
    promo_weekly_description TEXT,
    promo_weekly_photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delete_at TIMESTAMP
);


CREATE TABLE product_recomments (
    recomment_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    recomment_name VARCHAR(100) NOT NULL,
    recomment_description TEXT,
    recomment_photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delete_at TIMESTAMP
);


CREATE TABLE carts (
    cart_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE cart_items (
    cart_item_id SERIAL PRIMARY KEY,
    cart_id INT REFERENCES carts(cart_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    shipping_cost NUMERIC(10, 2) DEFAULT 0 CHECK (shipping_cost >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_cart_product UNIQUE (cart_id, product_id)
);

-- Trigger function untuk memperbarui kolom updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk tabel cart_items
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON cart_items
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


CREATE TABLE product_variants (
    variant_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    size VARCHAR(10), -- Ukuran produk (XS, S, M, L, XL, dll.)
    type VARCHAR(50), -- Tipe produk jika ada (opsional)
    stock INT NOT NULL DEFAULT 0
);

CREATE TABLE product_colors (
    color_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    color_name VARCHAR(50) NOT NULL, -- Nama warna (e.g., White, Black, Blue, dll.)
    stock INT NOT NULL DEFAULT 0
);

CREATE TABLE product_gallery (
    gallery_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    color_id INT REFERENCES product_colors(color_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL
);


-- Tabel orders
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    total_price NUMERIC(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    payment_id INT NOT NULL REFERENCES payments(payment_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel payments
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    payment_name VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel order_items
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    quantity INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    rating DECIMAL(2, 1) CHECK (rating BETWEEN 1.0 AND 5.0),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE seller_addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    recipient_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address_line TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    province VARCHAR(50) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    latitude NUMERIC(9, 6) NOT NULL,
    longitude NUMERIC(9, 6) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer_addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    recipient_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address_line TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    province VARCHAR(50) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    latitude NUMERIC(9, 6) NOT NULL,
    longitude NUMERIC(9, 6) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create a partial unique index to ensure only one default address per user
CREATE UNIQUE INDEX unique_default_address_per_user
ON customer_addresses (user_id)
WHERE is_default = TRUE;



-- default
INSERT INTO customer_addresses (user_id, recipient_name, phone_number, address_line, city, province, postal_code, latitude, longitude, is_default)
VALUES (1, 'Ucup', '081234567890', 'Jl. Sudirman No.1', 'Jakarta', 'DKI Jakarta', '10110', -6.2000, 106.8166, TRUE);

INSERT INTO customer_addresses (user_id, recipient_name, phone_number, address_line, city, province, postal_code, latitude, longitude, is_default)
VALUES (1, 'Susi', '083456789012', 'Jl. MH Thamrin No.3', 'Jakarta', 'DKI Jakarta', '10330', -6.2002, 106.8168, FALSE);


INSERT INTO seller_addresses (
    user_id,
    order_id,
    recipient_name,
    phone_number,
    address_line,
    city,
    province,
    postal_code,
    latitude,
    longitude,
    created_at
)
VALUES
-- Seller 1: Tech Store - Jakarta
(2, NULL, 'Tech Store - Jakarta', '081234567890', 'Jl. Sudirman No.1', 'Jakarta', 'DKI Jakarta', '10110', -6.2088, 106.8456, CURRENT_TIMESTAMP),
-- Seller 2: Fashion Hub - Bandung
(3, NULL, 'Fashion Hub - Bandung', '081345678901', 'Jl. Braga No.99', 'Bandung', 'Jawa Barat', '40111', -6.9175, 107.6191, CURRENT_TIMESTAMP),
-- Seller 3: Book World - Surabaya
(4, NULL, 'Book World - Surabaya', '081456789012', 'Jl. Basuki Rahmat No.123', 'Surabaya', 'Jawa Timur', '60271', -7.2575, 112.7521, CURRENT_TIMESTAMP),
-- Seller 4: Home Essentials - Semarang
(5, NULL, 'Home Essentials - Semarang', '081567890123', 'Jl. Pemuda No.45', 'Semarang', 'Jawa Tengah', '50132', -6.9667, 110.4167, CURRENT_TIMESTAMP),
-- Seller 5: Gadget Corner - Medan
(6, NULL, 'Gadget Corner - Medan', '081678901234', 'Jl. Sisingamangaraja No.77', 'Medan', 'Sumatera Utara', '20217', 3.5952, 98.6722, CURRENT_TIMESTAMP),
-- Seller 6: Trendy Wear - Yogyakarta
(7, NULL, 'Trendy Wear - Yogyakarta', '081789012345', 'Jl. Malioboro No.10', 'Yogyakarta', 'DI Yogyakarta', '55271', -7.7956, 110.3695, CURRENT_TIMESTAMP),
-- Seller 7: Knowledge Books - Malang
(8, NULL, 'Knowledge Books - Malang', '081890123456', 'Jl. Ijen No.25', 'Malang', 'Jawa Timur', '65119', -7.9778, 112.6349, CURRENT_TIMESTAMP),
-- Seller 8: Home Care Essentials - Bali
(9, NULL, 'Home Care Essentials - Bali', '081901234567', 'Jl. Sunset Road No.88', 'Denpasar', 'Bali', '80113', -8.6500, 115.2167, CURRENT_TIMESTAMP),
-- Seller 9: Sports Gear - Makassar
(10, NULL, 'Sports Gear - Makassar', '081012345678', 'Jl. Ahmad Yani No.12', 'Makassar', 'Sulawesi Selatan', '90122', -5.1477, 119.4327, CURRENT_TIMESTAMP),
-- Seller 10: Air Quality Experts - Balikpapan
(11, NULL, 'Air Quality Experts - Balikpapan', '081112345678', 'Jl. Soekarno Hatta No.5', 'Balikpapan', 'Kalimantan Timur', '76112', -1.2675, 116.8312, CURRENT_TIMESTAMP);



CREATE TABLE shipping_costs (
    shipping_cost_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    distance_km NUMERIC(10, 2) NOT NULL, -- Jarak antara seller dan customer
    cost NUMERIC(10, 2) NOT NULL,       -- Biaya pengiriman
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION calculate_distance(lat1 NUMERIC, lon1 NUMERIC, lat2 NUMERIC, lon2 NUMERIC)
RETURNS NUMERIC AS $$
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
$$ LANGUAGE plpgsql IMMUTABLE;


WITH distance_calculation AS (
    SELECT 
        o.order_id,
        sa.city AS customer_city,
        ca.city AS seller_city,
        calculate_distance(ca.latitude, ca.longitude, sa.latitude, sa.longitude) AS distance_km
    FROM 
        orders o
    JOIN 
        seller_addresses sa ON o.order_id = sa.order_id
    JOIN 
        customer_addresses ca ON o.user_id = ca.user_id 
)
INSERT INTO shipping_costs (order_id, distance_km, cost)
SELECT 
    dc.order_id,
    dc.distance_km,
    CASE
        WHEN dc.customer_city = dc.seller_city THEN 0 -- Gratis jika dalam satu kota
        ELSE dc.distance_km * 5000 -- Biaya 5000 per km jika beda kota
    END AS cost
FROM 
    distance_calculation dc;


INSERT INTO users (name, email, password, phone_number) 
VALUES 
('Iskandar', 'iskandar@example.com', 'pass123', '081234567890');

INSERT INTO users (name, email, password, phone_number) 
VALUES 
('Tech Store', 'techstore@example.com', 'pass123', '081234567891'),
('Fashion Hub', 'fashionhub@example.com', 'pass123', '081345678901'),
('Book World', 'bookworld@example.com', 'pass123', '081456789012'),
('Home Essentials', 'homeessentials@example.com', 'pass123', '081567890123'),
('Gadget Corner', 'gadgetcorner@example.com', 'pass123', '081678901234'),
('Trendy Wear', 'trendywear@example.com', 'pass123', '081789012345'),
('Knowledge Books', 'knowledgebooks@example.com', 'pass123', '081890123456'),
('Home Care Essentials', 'homecareessentials@example.com', 'pass123', '081901234567'),
('Sports Gear', 'sportsgear@example.com', 'pass123', '081012345678'),
('Air Quality Experts', 'airqualityexperts@example.com', 'pass123', '081112345678');


INSERT INTO tokens (user_id, token, expires_at)
VALUES
    (1, 'token_admin_1', NOW() + INTERVAL '30 day');

INSERT INTO categories (name, description) 
VALUES
('Electronics', 'Electronic devices and gadgets'),
('Fashion', 'Clothing and accessories'),
('Books', 'Books of various genres'),
('Home Appliances', 'Household items and appliances');


INSERT INTO products (name, description, price, discount, stock, category_id, photo_url) 
VALUES
('Smartphone A', 'Latest model smartphone with 128GB storage', 3000000.00, 10.00, 50, 1, 'https://example.com/images/smartphone_a.jpg'),
('Smartphone B', 'Budget-friendly smartphone with dual cameras', 1500000.00, NULL, 100, 1, 'https://example.com/images/smartphone_b.jpg'),
('Laptop X', 'High-performance laptop for gaming and work', 10000000.00, 5.00, 20, 1, 'https://example.com/images/laptop_x.jpg'),
('Headphones Z', 'Noise-cancelling headphones for clear audio', 500000.00, 10.00, 200, 1, 'https://example.com/images/headphones_z.jpg'),
('T-shirt Classic', 'Comfortable cotton t-shirt in multiple sizes', 100000.00, 5.00, 500, 2, 'https://example.com/images/tshirt_classic.jpg'),
('Sneakers Pro', 'Lightweight and durable sneakers for sports', 350000.00, 14.29, 300, 2, 'https://example.com/images/sneakers_pro.jpg'),
('Mystery Novel', 'Bestselling mystery novel by famous author', 75000.00, 6.67, 100, 3, 'https://example.com/images/mystery_novel.jpg'),
('Cookbook Deluxe', 'A collection of gourmet recipes', 125000.00, NULL, 50, 3, 'https://example.com/images/cookbook_deluxe.jpg'),
('Vacuum Cleaner V', 'Powerful and compact vacuum cleaner', 1500000.00, 6.67, 80, 4, 'https://example.com/images/vacuum_cleaner_v.jpg'),
('Air Purifier', 'Improves air quality and reduces allergens', 2500000.00, NULL, 60, 4, 'https://example.com/images/air_purifier.jpg');


INSERT INTO product_banners (product_id, banner_name, banner_description, banner_photo_url, delete_at)
VALUES 
(1, 'Smartphone A', 'Limited time offer!', 'https://example.com/banner-smartphone-x.jpg', '2024-11-30 23:59:59'),
(2, 'Smartphone B', 'Huge savings on high-performance Smartphone', 'https://example.com/banner-laptop-z.jpg', '2024-11-25 23:59:59'),
(3, 'Laptop X', 'High-performance laptop for gaming and work', 'https://example.com/images/laptop_x.jpg', '2024-11-27 23:59:59');


INSERT INTO product_promo_weekly (product_id, promo_weekly_name, promo_weekly_description, promo_weekly_photo_url, delete_at)
VALUES 
(4, 'Headphones Z', 'Noise-cancelling headphones for clear audio', 'https://example.com/images/headphones_z.jpg', '2024-11-30 23:59:59'),
(5, 'T-shirt Classic', 'Comfortable cotton t-shirt in multiple sizes', 'https://example.com/images/tshirt_classic.jpg', '2024-11-25 23:59:59'),
(6, 'Sneakers Pro', 'Lightweight and durable sneakers for sports', 'https://example.com/images/sneakers_pro.jpg', '2024-11-25 23:59:59'),
(7, 'Mystery Novel', 'Bestselling mystery novel by famous author', 'https://example.com/images/mystery_novel.jpg', '2024-11-25 23:59:59');


INSERT INTO product_recomments (product_id, recomment_name, recomment_description, recomment_photo_url, delete_at)
VALUES 
(8, 'Cookbook Deluxe', 'A collection of gourmet recipes', 'https://example.com/images/cookbook_deluxe.jpg', '2024-11-30 23:59:59'),
(9, 'Vacuum Cleaner V', 'Powerful and compact vacuum cleaner', 'https://example.com/images/vacuum_cleaner_v.jpg', '2024-11-30 23:59:59'),
(10, 'Air Purifier', 'Improves air quality and reduces allergens', 'https://example.com/images/air_purifier.jpg', '2024-11-30 23:59:59');


INSERT INTO carts (user_id) 
VALUES (1);


INSERT INTO cart_items (cart_id, product_id, quantity) 
VALUES
(1, 1, 2),
(1, 7, 1);

-- Insert data ke tabel orders
INSERT INTO orders (user_id, total_price, status, payment_id) 
VALUES 
(1, 6150000, 'Completed', 1),
(2, 7350000, 'Completed', 2),
(3, 4500000, 'Pending', 3),
(4, 125000, 'Completed', 4),
(5, 2500000, 'Processing', 5);


-- Insert data ke tabel payments
INSERT INTO payments (payment_name, payment_status) 
VALUES
('Credit Card', 'Completed'),
('Bank Transfer', 'Completed'),
('Credit Card', 'Pending'),
('Cash on Delivery', 'Completed'),
('Bank Transfer', 'Pending');

-- Insert data ke tabel order_items
INSERT INTO order_items (order_id, product_id, quantity, price) 
VALUES
(1, 1, 2, 3000000), 
(1, 7, 1, 75000),  
(2, 2, 3, 1500000),
(2, 6, 2, 350000), 
(3, 4, 5, 500000),
(4, 8, 1, 125000),
(5, 10, 1, 2500000);




INSERT INTO reviews (user_id, product_id, rating, review_text) 
VALUES
(1, 1, 5.0, 'Great smartphone with amazing performance!'),
(1, 7, 4.5, 'Enjoyed the book, but the ending felt rushed.'),
(1, 2, 3.0, 'Good value for money, but could be improved.'),
(1, 3, 5.0, 'Perfect laptop for work and gaming. Highly recommend!'),
(1, 4, 4.0, 'Great headphones, but a bit tight for long hours of use.');


INSERT INTO product_variants (product_id, type, size, stock) 
VALUES
-- Smartphone A
(1, 'Storage: 64GB, Screen ', '5.5', 20),
(1, 'Storage: 128GB, Screen ', '5.5', 20),
(1, 'Storage: 256GB, Screen ', '5.5', 10),
-- Smartphone B
(2, 'Storage: 32GB, Screen ', '6.1', 40),
(2, 'Storage: 64GB, Screen ', '6.1', 40),
(2, 'Storage: 128GB, Screen ', '6.1', 20),
-- Laptop X
(3, 'Storage: 256GB SSD, RAM: 8GB', '14', 5),
(3, 'Storage: 512GB SSD, RAM: 16GB', '20', 10),
(3, 'Storage: 1TB SSD, RAM: 32GB', '18', 5),
-- Headphones Z
(4, 'Color: Black, Noise Cancellation: Yes', 'ONE SIZE', 100),
(4, 'Color: White, Noise Cancellation: Yes', 'ONE SIZE', 50),
(4, 'Color: Blue, Noise Cancellation: Yes', 'ONE SIZE', 50),
-- T-shirt Classic
(5, 'ONE TYPE', 'S', 150),
(5, 'ONE TYPE', 'M', 200),
(5, 'ONE TYPE', 'L', 150),
-- Sneakers Pro
(6, 'ONE TYPE', '39', 100),
(6, 'ONE TYPE', '40', 150),
(6, 'ONE TYPE', '41', 50),
-- Mystery Novel
(7, 'Format: Hardcover', 'ONE SIZE', 20),
(7, 'Format: Paperback', 'ONE SIZE', 30),
(7, 'Format: Ebook', 'ONE SIZE', 50),
-- Cookbook Deluxe
(8, 'Format: Hardcover', 'ONE SIZE', 15),
(8, 'Format: Paperback', 'ONE SIZE', 20),
(8, 'Format: Ebook', 'ONE SIZE', 15),
-- Vacuum Cleaner V
(9, 'Capacity: 2L, Type: Compact', 'ONE SIZE', 10),
(9, 'Capacity: 3L, Type: Standard', 'ONE SIZE', 30),
(9, 'Capacity: 5L, Type: Premium', 'ONE SIZE', 40),
-- Air Purifier
(10, 'Room Size: Small (up to 150 sq ft)', 'ONE SIZE', 20),
(10, 'Room Size: Medium (up to 300 sq ft)', 'ONE SIZE', 25),
(10, 'Room Size: Large (up to 500 sq ft)', 'ONE SIZE', 15);



INSERT INTO product_colors (product_id, color_name, stock) 
VALUES
-- Smartphone A
(1, 'White', 20),
(1, 'Black', 20),
(1, 'Blue', 10),
-- Smartphone B
(2, 'Silver', 40),
(2, 'Gold', 40),
(2, 'Gray', 20),
-- Laptop X
(3, 'Black', 10),
(3, 'Gray', 5),
(3, 'Red', 5),
-- Headphones Z
(4, 'Black', 100),
(4, 'White', 50),
(4, 'Blue', 50),
-- T-shirt Classic
(5, 'White', 200),
(5, 'Black', 150),
(5, 'Gray', 150),
-- Sneakers Pro
(6, 'Red', 100),
(6, 'Blue', 100),
(6, 'White', 100),
-- Mystery Novel
(7, 'Blue', 30),
(7, 'Black', 30),
(7, 'Gray', 40),
-- Cookbook Deluxe
(8, 'White', 20),
(8, 'Yellow', 20),
(8, 'Red', 10),
-- Vacuum Cleaner V
(9, 'Gray', 20),
(9, 'Black', 30),
(9, 'Blue', 30),
-- Air Purifier
(10, 'White', 20),
(10, 'Gray', 20),
(10, 'Black', 20);




INSERT INTO product_gallery (product_id, color_id, image_url)
VALUES
-- Smartphone A
(1, 1, 'https://example.com/images/smartphone_a_white.jpg'),
(1, 2, 'https://example.com/images/smartphone_a_black.jpg'),
(1, 3, 'https://example.com/images/smartphone_a_blue.jpg'),
-- Smartphone B
(2, 4, 'https://example.com/images/smartphone_b_silver.jpg'),
(2, 5, 'https://example.com/images/smartphone_b_gold.jpg'),
(2, 6, 'https://example.com/images/smartphone_b_gray.jpg'),
-- Laptop X
(3, 7, 'https://example.com/images/laptop_x_black.jpg'),
(3, 8, 'https://example.com/images/laptop_x_gray.jpg'),
(3, 9, 'https://example.com/images/laptop_x_red.jpg'),
-- Headphones Z
(4, 10, 'https://example.com/images/headphones_z_black.jpg'),
(4, 11, 'https://example.com/images/headphones_z_white.jpg'),
(4, 12, 'https://example.com/images/headphones_z_blue.jpg'),
-- T-shirt Classic
(5, 13, 'https://example.com/images/tshirt_classic_white.jpg'),
(5, 14, 'https://example.com/images/tshirt_classic_black.jpg'),
(5, 15, 'https://example.com/images/tshirt_classic_gray.jpg'),
-- Sneakers Pro
(6, 16, 'https://example.com/images/sneakers_pro_red.jpg'),
(6, 17, 'https://example.com/images/sneakers_pro_blue.jpg'),
(6, 18, 'https://example.com/images/sneakers_pro_white.jpg'),
-- Mystery Novel
(7, 19, 'https://example.com/images/mystery_novel_blue.jpg'),
(7, 20, 'https://example.com/images/mystery_novel_black.jpg'),
(7, 21, 'https://example.com/images/mystery_novel_gray.jpg'),
-- Cookbook Deluxe
(8, 22, 'https://example.com/images/cookbook_deluxe_white.jpg'),
(8, 23, 'https://example.com/images/cookbook_deluxe_yellow.jpg'),
(8, 24, 'https://example.com/images/cookbook_deluxe_red.jpg'),
-- Vacuum Cleaner V
(9, 25, 'https://example.com/images/vacuum_cleaner_v_gray.jpg'),
(9, 26, 'https://example.com/images/vacuum_cleaner_v_black.jpg'),
(9, 27, 'https://example.com/images/vacuum_cleaner_v_blue.jpg'),
-- Air Purifier
(10, 28, 'https://example.com/images/air_purifier_white.jpg'),
(10, 29, 'https://example.com/images/air_purifier_gray.jpg'),
(10, 30, 'https://example.com/images/air_purifier_black.jpg');



SELECT 
    p.product_id AS id,
    p.name,
    p.price,
    p.photo_url,
    COALESCE(ROUND(AVG(r.rating), 1), 0) AS rating,
    COUNT(r.review_id) AS count_rating,
    CASE 
        WHEN p.created_at >= DATE_TRUNC('month', CURRENT_DATE) THEN 'NEW'
        ELSE NULL
    END AS product_status
FROM 
    products p
LEFT JOIN 
    order_items od ON p.product_id = od.product_id
LEFT JOIN 
    orders o ON od.order_id = o.order_id
LEFT JOIN 
    reviews r ON p.product_id = r.product_id
GROUP BY 
    p.product_id
ORDER BY 
    p.product_id;
    

SELECT
    p.product_id AS id,
    p.name,
    p.price,
    p.discount,
    p.discount_price,
    p.photo_url,
    COALESCE(ROUND(AVG(r.rating), 1), 0) AS rating, -
    COUNT(r.review_id) AS count_rating,             
    CASE 
        WHEN p.created_at >= DATE_TRUNC('month', CURRENT_DATE) THEN 'NEW'
        ELSE NULL
    END AS product_status                           
FROM 
    products p
LEFT JOIN
    categories c ON p.category_id = c.category_id
LEFT JOIN 
    order_items od ON p.product_id = od.product_id  
LEFT JOIN 
    orders o ON od.order_id = o.order_id           
LEFT JOIN 
    reviews r ON p.product_id = r.product_id                            
GROUP BY 
    p.product_id,                                  
    p.name, 
    p.price, 
    p.discount, 
    p.discount_price, 
    p.photo_url, 
    p.created_at                                    
ORDER BY 
    p.product_id;                                  


SELECT
        p.product_id AS id,
        p.name,
        p.price,
        COALESCE(p.discount, 0) AS discount,
        p.discount_price,
        p.photo_url,
        COALESCE(ROUND(AVG(r.rating), 1), 0) AS rating,
        COUNT(r.review_id) AS count_rating,
        CASE
                WHEN p.created_at >= DATE_TRUNC('month', CURRENT_DATE) THEN 'NEW'
                ELSE NULL
        END AS product_status
FROM
        products p
LEFT JOIN
        order_items od ON p.product_id = od.product_id
LEFT JOIN
        orders o ON od.order_id = o.order_id
LEFT JOIN
        reviews r ON p.product_id = r.product_id
GROUP BY
        p.product_id,
        p.name,
        p.price,
        p.discount,
        p.discount_price,
        p.photo_url,
        p.created_at
ORDER BY
        p.product_id
LIMIT 4 OFFSET 4;


SELECT 
    p.product_id AS id,
    p.name,
    p.price,
    COALESCE(p.discount_price, p.price) AS price_discount,
    COALESCE(ROUND(AVG(r.rating), 1), 0) AS rating,
    COUNT(r.review_id) AS count_rating
FROM 
    products p
LEFT JOIN 
    reviews r ON p.product_id = r.product_id
WHERE 
    r.created_at >= DATE_TRUNC('month', CURRENT_DATE) -- Hanya data bulan ini
GROUP BY 
    p.product_id
ORDER BY 
    count_rating DESC, rating DESC
LIMIT 10;


SELECT 
    product_id, 
    name, 
    description, 
    photo_url, 
    CASE 
        WHEN created_at >= DATE_TRUNC('month', CURRENT_DATE) THEN 'NEW'
        ELSE NULL
    END AS product_status
FROM products;


SELECT 
    p.product_id AS id,
    p.name,
    p.price,
    COALESCE(p.discount_price, p.price) AS price_discount,
    SUM(od.quantity) AS total_sold,
    COALESCE(ROUND(AVG(r.rating), 1), 0) AS rating,
    COUNT(r.review_id) AS count_rating
FROM 
    products p
LEFT JOIN 
    order_items od ON p.product_id = od.product_id
LEFT JOIN 
    orders o ON od.order_id = o.order_id
LEFT JOIN 
    reviews r ON p.product_id = r.product_id
WHERE 
    o.created_at >= DATE_TRUNC('month', CURRENT_DATE) -- Hanya transaksi bulan ini
GROUP BY 
    p.product_id
ORDER BY 
    total_sold DESC, rating DESC
LIMIT 10;


SELECT 
    p.product_id,
    p.description,
    p.photo_url,
    c.name AS category_name
FROM 
    products p
LEFT JOIN 
    categories c ON p.category_id = c.category_id
WHERE 
    p.discount_price IS NOT NULL 
    AND p.discount_price < p.price 
    AND p.created_at >= DATE_TRUNC('week', CURRENT_DATE); -- Dibuat atau diupdate minggu ini


SELECT 
    name,
    price AS original_price,
    discount_price,
    (price - discount_price) AS discount_amount
FROM products
WHERE (price - discount_price) > 0;


SELECT 
    p.product_id AS id,
    p.name,
    p.price,
    p.photo_url,
    COALESCE(p.discount_price, 0) AS discount_price,
    COALESCE(ROUND(AVG(r.rating), 1), 0) AS rating,
    COUNT(r.review_id) AS count_rating
FROM 
    products p
LEFT JOIN 
    order_items od ON p.product_id = od.product_id
LEFT JOIN 
    orders o ON od.order_id = o.order_id
LEFT JOIN 
    reviews r ON p.product_id = r.product_id
GROUP BY 
    p.product_id
ORDER BY 
    p.product_id;


SELECT 
    product_id,
    name,
    description,
    photo_url
FROM 
    products 
WHERE 
    product_id IN (1, 3, 5, 7)
ORDER BY product_id;


SELECT 
    p.product_id,
    p.name AS product_name,
    pv.size,
    pv.type,
    pc.color_name,
    pg.image_url,
    p.price,
    COALESCE(pv.stock, 0) AS size_stock,
    COALESCE(pc.stock, 0) AS color_stock
FROM 
    products p
LEFT JOIN 
    product_variants pv ON p.product_id = pv.product_id
LEFT JOIN 
    product_colors pc ON p.product_id = pc.product_id
LEFT JOIN 
    product_gallery pg ON pc.color_id = pg.color_id
WHERE 
    p.product_id = 1
ORDER BY 
    p.product_id, pv.size, pc.color_name;

SELECT expires_at FROM tokens WHERE token = 'token_admin_1';

SELECT 
    c.cart_id,
    c.user_id,
    ci.product_id,
    p.name,
    p.discount_price,
    p.photo_url,
    ci.quantity,
    p.discount_price * ci.quantity AS total_price
FROM carts c
LEFT JOIN cart_items ci ON c.cart_id = ci.cart_id
LEFT JOIN products p ON p.product_id = ci.product_id
WHERE 
    c.user_id = 1
ORDER BY
    ci.created_at ASC;

UPDATE cart_items
SET 
    quantity = $2,
    updated_at = CURRENT_TIMESTAMP
WHERE cart_item_id = $1;


SELECT 
    ci.cart_item_id,
    c.user_id,
    ci.product_id,
    p.name,
    p.discount_price,
    p.photo_url,
    ci.quantity,
    p.discount_price * ci.quantity AS total_price
FROM carts c
LEFT JOIN cart_items ci ON c.cart_id = ci.cart_id
LEFT JOIN products p ON p.product_id = ci.product_id
WHERE 
    ci.cart_item_id = 1;
    


SELECT * FROM categories;
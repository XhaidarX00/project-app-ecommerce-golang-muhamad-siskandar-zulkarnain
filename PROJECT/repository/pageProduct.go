package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"project/model"
	"strings"

	"go.uber.org/zap"
)

func (r *AllRepository) GetAllPageProductRepo(name string, category, limit, page int, data *[]model.AllProduct) (int, int, error) {
	offset := (page - 1) * limit
	baseQuery := `
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
	`

	var conditions []string
	var params []interface{}

	// Tambahkan kondisi berdasarkan parameter 'name'
	if name != "" {
		conditions = append(conditions, "p.name ILIKE '%' || $1 || '%'")
		params = append(params, name)
	}

	// Tambahkan kondisi berdasarkan parameter 'category'
	if category != 0 {
		if name != "" {
			conditions = append(conditions, "p.category_id = $2")
		} else {
			conditions = append(conditions, "p.category_id = $1")
		}
		params = append(params, category)
	}

	// Jika ada kondisi, tambahkan WHERE clause
	if len(conditions) > 1 {
		baseQuery += " WHERE " + strings.Join(conditions, " AND ")
	} else if len(conditions) == 1 {
		baseQuery += " WHERE " + conditions[0]
	}

	// Menyusun query akhir untuk pagination
	baseQuery += `
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
		LIMIT $` + fmt.Sprintf("%d", len(params)+1) + ` OFFSET $` + fmt.Sprintf("%d", len(params)+2)

	// Menambahkan limit dan offset sebagai parameter terakhir
	params = append(params, limit, offset)

	// Eksekusi query
	rows, err := r.DB.Query(baseQuery, params...)
	if err != nil {
		return 0, 0, err
	}

	defer rows.Close()

	// Scan hasil query
	for rows.Next() {
		var p model.AllProduct
		if err := rows.Scan(&p.ProductID, &p.Name, &p.Price, &p.Discount, &p.DiscountPrice, &p.PhotoURL, &p.Rating, &p.CountRating, &p.Status); err != nil {
			return 0, 0, err
		}
		*data = append(*data, p)
	}

	// Jika tidak ada data
	if len(*data) == 0 {
		return 0, 0, errors.New("data not found")
	}

	// Hitung total item dan halaman
	var totalItems int
	if len(conditions) == 0 {
		err = r.DB.QueryRow("SELECT COUNT(*) FROM products").Scan(&totalItems)
		if err != nil {
			return 0, 0, err
		}
	} else {
		totalItems = len(*data)
	}
	totalPage := (totalItems + limit - 1) / limit

	// Validasi halaman
	if page > totalPage {
		err := errors.New("page melebihi total page product")
		r.Logger.Error("Error GetAllPageProductRepo", zap.Error(err))
		return 0, 0, err
	}

	return totalPage, totalItems, nil
}

// AddToCart menambahkan produk ke keranjang belanja
func (r *AllRepository) AddToCartRepo(ATC *model.AddToCart) error {
	// Cek apakah user sudah memiliki cart
	query := `
		INSERT INTO carts (user_id)
		SELECT $1
		WHERE NOT EXISTS (
			SELECT 1 FROM carts WHERE user_id = $1
		)
		RETURNING cart_id;
	`

	// Menjalankan query untuk mendapatkan atau membuat cart_id
	err := r.DB.QueryRow(query, ATC.UserID).Scan(&ATC.CartID)
	if err != nil {
		if err != sql.ErrNoRows {
			return fmt.Errorf("error checking or creating cart: %v", err)
		}
		// Jika sudah ada cart_id, kita ambil dari tabel carts
		query = "SELECT cart_id FROM carts WHERE user_id = $1 LIMIT 1"
		err = r.DB.QueryRow(query, ATC.UserID).Scan(&ATC.CartID)
		if err != nil {
			return fmt.Errorf("error getting cart_id: %v", err)
		}
	}

	if ATC.Quantity < 1 {
		ATC.Quantity = 1
	}

	// Menambahkan item ke keranjang
	insertItemQuery := `
		INSERT INTO cart_items (cart_id, product_id, quantity)
		VALUES ($1, $2, $3)
		ON CONFLICT (cart_id, product_id)
		DO UPDATE SET quantity = cart_items.quantity + EXCLUDED.quantity, updated_at = CURRENT_TIMESTAMP;
	`
	_, err = r.DB.Exec(insertItemQuery, ATC.CartID, ATC.ProductID, ATC.Quantity)
	if err != nil {
		return fmt.Errorf("error inserting item to cart: %v", err)
	}

	if err != nil {
		return fmt.Errorf("error committing transaction: %v", err)
	}

	return nil
}

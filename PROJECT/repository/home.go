package repository

import (
	"errors"
	"fmt"
	"project/model"

	"go.uber.org/zap"
)

// get banner // buat tabel banner
func (r *AllRepository) BannerRepository(data *[]model.Product) error {
	query := `
	SELECT
		p.product_id AS product_id,
		b.banner_name,
		b.banner_description,
		b.banner_photo_url
	FROM 
		product_banners b
	LEFT JOIN 
		products p ON b.product_id = p.product_id
	WHERE 
		b.delete_at > CURRENT_TIMESTAMP -- Banner masih aktif
	ORDER BY 
		b.delete_at ASC`

	rows, err := r.DB.Query(query)
	if err != nil {
		return err
	}

	defer rows.Close()

	for rows.Next() {
		var product model.Product
		if err := rows.Scan(&product.ProductID, &product.Name, &product.Description, &product.PhotoURL); err != nil {
			return err
		}

		product.PathPage = fmt.Sprintf("/api/product/%d", product.ProductID)
		*data = append(*data, product)
	}

	if len(*data) == 0 {
		return errors.New("data not found")
	}

	return nil
}

// get categories
func (r *AllRepository) GetCategoryRepo(data *[]model.Category) error {
	query := `SELECT category_id, name FROM categories`
	rows, err := r.DB.Query(query)
	if err != nil {
		return err
	}

	defer rows.Close()

	for rows.Next() {
		var category model.Category
		if err := rows.Scan(&category.CategoryID, &category.Name); err != nil {
			return err
		}

		*data = append(*data, category)
	}

	return nil
}

func (r *AllRepository) GetBestSellingProductRepo(limit int, page int, data *[]model.BestSelling) (int, int, error) {
	offset := (page - 1) * limit
	query := `
		SELECT 
			p.product_id AS id,
			p.name,
			p.price,
			p.discount_price,
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
			o.created_at >= DATE_TRUNC('month', CURRENT_DATE) 
		GROUP BY 
			p.product_id
		ORDER BY 
			total_sold DESC, rating DESC
		LIMIT $1 OFFSET $2
		`

	rows, err := r.DB.Query(query, limit, offset)
	if err != nil {
		return 0, 0, err
	}

	defer rows.Close()

	for rows.Next() {
		var bsp model.BestSelling
		if err := rows.Scan(&bsp.ID, &bsp.Name, &bsp.Price, &bsp.PriceDiscount, &bsp.TotalSold, &bsp.Rating, &bsp.CountRating); err != nil {
			return 0, 0, err
		}

		*data = append(*data, bsp)
	}

	var totalItems int
	err = r.DB.QueryRow("SELECT COUNT(*) FROM products").Scan(&totalItems)
	if err != nil {
		return 0, 0, err
	}

	totalPage := (totalItems + limit - 1) / limit

	if page > totalPage {
		err = errors.New("page melebihi total page product")
		r.Logger.Error("Error GetBestSellingProductRepo", zap.Error(err))
		return 0, 0, err
	}

	return totalPage, totalItems, nil
}

func (r *AllRepository) GetPromoWeeklyProductRepo(data *[]model.PromoWeekly) error {
	query := `
		SELECT 
			p.product_id AS product_id,
			pp.promo_weekly_description,
			pp.promo_weekly_photo_url,
			c.name AS category_name
		FROM 
			product_promo_weekly pp
		LEFT JOIN 
			products p ON pp.product_id = p.product_id
		LEFT JOIN 
			categories c ON c.category_id = p.category_id
		WHERE 
			pp.delete_at > CURRENT_TIMESTAMP
		ORDER BY 
			pp.delete_at ASC`

	rows, err := r.DB.Query(query)
	if err != nil {
		return err
	}

	defer rows.Close()

	for rows.Next() {
		var pwp model.PromoWeekly
		if err := rows.Scan(&pwp.ProductID, &pwp.Description, &pwp.PhotoURL, &pwp.Category); err != nil {
			return err
		}

		pwp.PathPage = fmt.Sprintf("/api/product/%d", pwp.ProductID)
		*data = append(*data, pwp)
	}

	if len(*data) == 0 {
		return errors.New("data not found")
	}

	return nil
}

func (r *AllRepository) GetAllProductRepo(limit int, page int, data *[]model.AllProduct) (int, int, error) {
	offset := (page - 1) * limit
	query := `
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
			p.product_id
		LIMIT $1 OFFSET $2
		`

	rows, err := r.DB.Query(query, limit, offset)
	if err != nil {
		return 0, 0, err
	}

	defer rows.Close()

	for rows.Next() {
		var p model.AllProduct
		if err := rows.Scan(&p.ProductID, &p.Name, &p.Price, &p.PhotoURL, &p.Rating, &p.CountRating, &p.Status); err != nil {
			return 0, 0, err
		}

		*data = append(*data, p)
	}

	if len(*data) == 0 {
		return 0, 0, errors.New("data not found")
	}

	var totalItems int
	err = r.DB.QueryRow("SELECT COUNT(*) FROM products").Scan(&totalItems)
	if err != nil {
		return 0, 0, err
	}
	totalPage := (totalItems + limit - 1) / limit

	if page > totalPage {
		err = errors.New("page melebihi total page product")
		r.Logger.Error("Error GetBestSellingProductRepo", zap.Error(err))
		return 0, 0, err
	}

	return totalPage, totalItems, nil
}

func (r *AllRepository) GetRecomentProductRepo(data *[]model.RecomentProduct) error {
	// productIDsList := strings.Join(productIDs, ","
	// query := fmt.Sprintf(`
	// 	SELECT
	// 		product_id,
	// 		name,
	// 		description,
	// 		photo_url
	// 	FROM
	// 		products
	// 	WHERE
	// 		product_id IN (%s)
	// 	ORDER BY product_id`, productIDsList)

	query := `
		SELECT 
			p.product_id AS product_id,
			pr.recomment_name,
			pr.recomment_description,
			pr.recomment_photo_url
		FROM 
			product_recomments pr
		LEFT JOIN 
			products p ON pr.product_id = p.product_id
		WHERE 
			pr.delete_at > CURRENT_TIMESTAMP
		ORDER BY 
			pr.delete_at ASC`

	rows, err := r.DB.Query(query)
	if err != nil {
		return err
	}

	defer rows.Close()

	for rows.Next() {
		var rp model.RecomentProduct
		if err := rows.Scan(&rp.ProductID, &rp.Name, &rp.Description, &rp.PhotoURL); err != nil {
			return err
		}

		rp.PathPage = fmt.Sprintf("/api/product/%d", rp.ProductID)
		*data = append(*data, rp)
	}

	if len(*data) == 0 {
		return errors.New("data not found")
	}

	return nil
}

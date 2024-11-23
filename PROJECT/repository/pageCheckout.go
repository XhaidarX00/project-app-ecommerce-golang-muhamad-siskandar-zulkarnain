package repository

import (
	"errors"
	"fmt"
	"project/model"
	"strings"

	"go.uber.org/zap"
)

type Params struct {
	ID        int
	UserID    int
	ProductID int
	Quantity  int
}

func (r *AllRepository) GetDetailRepo(data *model.DetailProduct) error {
	query := `
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
		p.product_id = $1
	ORDER BY 
		p.product_id, pv.size, pc.color_name
	`

	rows, err := r.DB.Query(query, data.ProductID)
	if err != nil {
		r.Logger.Error("Error GetCheckoutPage", zap.Error(err))
		return err
	}

	defer rows.Close()

	// Scan hasil query
	for rows.Next() {
		var p model.DetailProductAtribut
		if err := rows.Scan(&data.ProductID, &data.ProductName, &p.Size, &p.Type, &p.ColorName, &p.ImageURL, &p.Price, &p.SizeStock, &p.ColorStock); err != nil {
			return err
		}

		data.Detail = append(data.Detail, p)
	}

	var totalItems int
	err = r.DB.QueryRow("SELECT COUNT(*) FROM products").Scan(&totalItems)
	if err != nil {
		r.Logger.Error("Error GetCheckoutPage", zap.Error(err))
		return err
	}

	if data.ProductID > totalItems {
		err = errors.New("data tidak ditemukan")
		r.Logger.Error("Error GetCheckoutPage", zap.Error(err))
		return err
	}

	return nil
}

func (r *AllRepository) GetListCartRepo(user_id int, data *model.ResponseListCart) error {
	query := `
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
		c.user_id = $1
	ORDER BY
		ci.cart_item_id`

	rows, err := r.DB.Query(query, user_id)
	if err != nil {
		return err
	}

	var data_ []model.ListCart
	for rows.Next() {
		var lct model.ListCart
		if rows.Scan(&lct.ID, &lct.UserID, &lct.ProductID, &lct.ProductName, &lct.Price, &lct.PhotoURL, &lct.Quantity, &lct.Total); err != nil {
			return err
		}

		data.TotalPriceAllItems += lct.Total
		data.Shipping += lct.ShippingCost
		data_ = append(data_, lct)
	}

	data.TotalCartPrice = data.Shipping + data.TotalPriceAllItems
	data.Data = data_

	return nil
}

func (r *AllRepository) UpdateListCartRepo(params Params, data *model.ListCart) error {
	query := `
		UPDATE cart_items
		SET `
	var updates []string
	var params_ []interface{}

	// Periksa parameter yang diubah
	if params.Quantity != 0 {
		updates = append(updates, "quantity = $"+fmt.Sprintf("%d", len(params_)+1))
		params_ = append(params_, params.Quantity)
	}

	if params.ProductID != 0 {
		updates = append(updates, "product_id = $"+fmt.Sprintf("%d", len(params_)+1))
		params_ = append(params_, params.ProductID)
	}

	if len(updates) > 0 {
		updates = append(updates, "updated_at = CURRENT_TIMESTAMP")
	} else {
		return fmt.Errorf("no fields to update")
	}

	query += strings.Join(updates, ", ")
	query += ` WHERE cart_item_id = $` + fmt.Sprintf("%d", len(params_)+1) + ` RETURNING cart_item_id`

	params_ = append(params_, params.ID)

	err := r.DB.QueryRow(query, params_...).Scan(&data.ID)
	if err != nil {
		return fmt.Errorf("failed to update cart item: %w", err)
	}

	querySelect := `
		SELECT
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
		WHERE ci.cart_item_id = $1`

	err = r.DB.QueryRow(querySelect, data.ID).
		Scan(&data.UserID, &data.ProductID, &data.ProductName, &data.Price, &data.PhotoURL, &data.Quantity, &data.Total)
	if err != nil {
		return fmt.Errorf("failed to retrieve updated cart item: %w", err)
	}

	return nil
}

func (r *AllRepository) DeleteListCartRepo(cartID int) error {
	query := `DELETE FROM cart_items WHERE cart_item_id = $1`

	res, err := r.DB.Exec(query, cartID)
	if err != nil {
		return fmt.Errorf("failed to delete cart item with ID %d: %w", cartID, err)
	}

	// Periksa apakah ada baris yang terhapus
	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("no cart item found with ID %d", cartID)
	}

	return nil
}

func (r *AllRepository) GetListAddressRepo(userID int, data *[]model.CustomerAddress) error {
	query := `
        SELECT 
            address_id, user_id, recipient_name, phone_number, 
            address_line, city, province, postal_code, 
            latitude, longitude, is_default, created_at
        FROM customer_addresses
        WHERE user_id = $1;
    `

	rows, err := r.DB.Query(query, userID)
	if err != nil {
		return err
	}
	defer rows.Close()

	for rows.Next() {
		var address model.CustomerAddress
		err := rows.Scan(
			&address.AddressID,
			&address.UserID,
			&address.RecipientName,
			&address.PhoneNumber,
			&address.AddressLine,
			&address.City,
			&address.Province,
			&address.PostalCode,
			&address.Latitude,
			&address.Longitude,
			&address.IsDefault,
			&address.CreatedAt,
		)
		if err != nil {
			return err
		}

		*data = append(*data, address)
	}

	return nil
}

func (r *AllRepository) AddOrdersRepo(data *model.AddOrders) error {
	query := `INSERT INTO orders (user_id, total_price, status, payment_id) VALUES ($1, $2, $3, $4) RETURNING order_id`
	err := r.DB.QueryRow(query, data.UserID, data.TotalPrice, data.Status, data.PaymentID).Scan(&data.OrderID)
	if err != nil {
		return err
	}

	return nil
}

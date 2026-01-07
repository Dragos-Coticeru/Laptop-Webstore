from flask import Blueprint, render_template, redirect, jsonify, request, session
import pypyodbc as odbc
from app.services import get_db_connection
from datetime import datetime

catalog_blueprint = Blueprint('catalog', __name__)

@catalog_blueprint.route('/catalog')
def catalog():
    return render_template('catalog.html')

@catalog_blueprint.route('/get_categories', methods=['GET'])
def get_categories():
    if request.headers.get('X-Requested-With') != 'XMLHttpRequest':
        return jsonify({"error": "Unauthorized access"}), 403
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC dbo.sp_GetCategories")
        categories = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify(categories)
    except Exception as e:
        return jsonify({"error": str(e)})
    
@catalog_blueprint.route('/get_laptops', methods=['GET'])
def get_laptops():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC dbo.sp_GetLaptops")
        laptops = [{"LaptopID": row[0], "ModelName": row[1], "Price": row[2]} for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify(laptops)
    except Exception as e:
        return jsonify({"error": str(e)})
    
@catalog_blueprint.route('/search_laptops', methods=['POST'])
def search_laptops():
    try:
        data = request.json
        search_term = data.get('search_term', '').strip()
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC dbo.sp_SearchLaptops ?", [search_term])
        laptops = [{"LaptopID": row[0], "ModelName": row[1], "Price": row[2]} for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify({"success": True, "laptops": laptops})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    
@catalog_blueprint.route('/filter_laptops', methods=['POST'])
def filter_laptops():
    try:
        data = request.json
        category_name = data.get('category_name')
        if not category_name:
            return jsonify({"success": False, "message": "Category name is required"}), 400
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC dbo.sp_FilterLaptopsByCategory ?", [category_name])
        laptops = [{"LaptopID": row[0], "ModelName": row[1], "Price": row[2]} for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify({"success": True, "laptops": laptops})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500
    
@catalog_blueprint.route('/add_to_cart', methods=['POST'])
def add_to_cart():
    try:
        data = request.json
        laptop_id = data.get('laptop_id')
        cart_id = session.get('CartID')
        if not cart_id:
            return jsonify({"success": False, "message": "No cart associated with the user."}), 403
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC dbo.sp_AddToCart ?, ?", (cart_id, laptop_id))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"success": True, "message": "Laptop added to cart successfully!"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500
    
@catalog_blueprint.route('/get_cart_items', methods=['GET'])
def get_cart_items():
    try:
        cart_id = session.get('CartID')
        if not cart_id:
            return jsonify({"success": False, "message": "No cart associated with the user."}), 403
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC dbo.sp_GetCartItems ?", [cart_id])
        cart_items = [
            {"model_name": row[0], "price": row[1], "quantity": row[2]}
            for row in cursor.fetchall()
        ]
        cursor.close()
        conn.close()
        return jsonify({"success": True, "items": cart_items})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

@catalog_blueprint.route('/cart', methods=['GET'])
def cart_page():
    return render_template('cart.html')

@catalog_blueprint.route('/payment', methods=['GET'])
def payment_page():
    try:
        user_id = session.get('UserID')
        if not user_id:
            return jsonify({"success": False, "message": "User is not logged in"}), 403
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC dbo.sp_GetUserAddresses ?", [user_id])
        addresses = [
            {
                "AddressID": row[0],
                "Street": row[1],
                "Number": row[2],
                "City": row[3],
                "PostalCode": row[4],
                "Country": row[5],
                "AddressType": row[6],
            }
            for row in cursor.fetchall()
        ]
        cursor.close()
        conn.close()
        
        shipping_addresses = [addr for addr in addresses if addr["AddressType"] == "S"]
        billing_addresses = [addr for addr in addresses if addr["AddressType"] == "B"]
        
        return render_template(
            'payment.html',
            shipping_addresses=shipping_addresses,
            billing_addresses=billing_addresses
        )
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

@catalog_blueprint.route('/myaccount', methods=['GET'])
def myaccount():
    try:
        user_id = session.get('UserID')
        if not user_id:
            return jsonify({"success": False, "message": "User is not logged in"}), 403
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute("EXEC dbo.sp_GetUserDetails ?", [user_id])
        user = cursor.fetchone()
        
        cursor.execute("EXEC dbo.sp_GetUserAddressesForAccount ?", [user_id])
        addresses = [
            {
                "Street": row[0],
                "Number": row[1],
                "City": row[2],
                "PostalCode": row[3],
                "Country": row[4],
                "AddressType": "Shipping" if row[5] == "S" else "Billing",
            }
            for row in cursor.fetchall()
        ]
        cursor.close()
        conn.close()
        
        return render_template(
            'myaccount.html',
            user={"FirstName": user[0], "LastName": user[1], "Email": user[2]},
            addresses=addresses
        )
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

@catalog_blueprint.route('/add_address', methods=['GET'])
def add_address():
    return render_template('add_address.html')

@catalog_blueprint.route('/submit_address', methods=['POST'])
def submit_address():
    try:
        user_id = session.get('UserID')
        if not user_id:
            return jsonify({"success": False, "message": "User is not logged in"}), 403
        
        street = request.form.get('street')
        number = request.form.get('number')
        city = request.form.get('city')
        postal_code = request.form.get('postalcode')
        country = request.form.get('country')
        address_type = request.form.get('type')
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC dbo.sp_AddAddress ?, ?, ?, ?, ?, ?, ?", 
                      (user_id, street, number, city, postal_code, country, address_type))
        conn.commit()
        cursor.close()
        conn.close()
        
        return redirect('/myaccount')
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500
    
@catalog_blueprint.route('/get_address_details_by_street/<street>', methods=['GET'])
def get_address_details_by_street(street):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC dbo.sp_GetAddressDetailsByStreet ?", [street])
        row = cursor.fetchone()
        
        if row:
            address = {
                "Street": row[0],
                "Number": row[1],
                "City": row[2],
                "PostalCode": row[3],
                "Country": row[4],
            }
            cursor.close()
            conn.close()
            return jsonify({"success": True, "address": address})
        else:
            cursor.close()
            conn.close()
            return jsonify({"success": False, "message": "Address not found"}), 404
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

@catalog_blueprint.route('/submit_payment', methods=['POST'])
def submit_payment():
    try:
        user_id = session.get('UserID')
        if not user_id:
            return jsonify({"success": False, "message": "User is not logged in"}), 403
        
        data = request.get_json()
        if not data:
            return jsonify({"success": False, "message": "Invalid or missing JSON payload"}), 400
        
        total_amount = data.get('total_amount')
        if total_amount is None or total_amount <= 0:
            return jsonify({"success": False, "message": "Invalid total amount provided."}), 400
        
        cart_id = session.get('CartID')
        if not cart_id:
            return jsonify({"success": False, "message": "No cart associated with the user."}), 403
        
        shipping_address_id = 2
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("EXEC dbo.sp_SubmitOrder ?, ?, ?, ?", (user_id, cart_id, total_amount, shipping_address_id))
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({"success": True, "message": "Order submitted successfully!"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500
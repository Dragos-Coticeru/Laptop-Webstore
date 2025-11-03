from flask import Blueprint, render_template, session, redirect, jsonify, request
from app.services import get_db_connection

adminRoutes_blueprint = Blueprint('admin', __name__)

def call_sp(cursor, sp_name, params=()):
    # Generic EXEC helper for pyodbc + SQL Server
    placeholders = ",".join(["?"] * len(params))
    sql = f"EXEC {sp_name} {placeholders}" if placeholders else f"EXEC {sp_name}"
    cursor.execute(sql, params)

@adminRoutes_blueprint.route('/admin')
def admin_page():
    if session.get('UserType') != "A":
        return redirect('/')
    return render_template('admin.html')

@adminRoutes_blueprint.route('/admin/add_user', methods=['POST'])
def add_user():
    data = request.json
    try:
        conn = get_db_connection(); cur = conn.cursor()
        call_sp(cur, "dbo.sp_AddUser", (
            data['firstName'], data['lastName'], data['email'],
            data['password'], data.get('phoneNumber'), data['userType']
        ))
        conn.commit()
        return jsonify({"success": True, "message": "User added successfully"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try: cur.close(); conn.close()
        except: pass

@adminRoutes_blueprint.route('/admin/remove_user', methods=['POST'])
def remove_user():
    data = request.json
    try:
        conn = get_db_connection(); cur = conn.cursor()
        call_sp(cur, "dbo.sp_RemoveUser", (data['email'],))
        conn.commit()
        return jsonify({"success": True, "message": "User removed successfully"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try: cur.close(); conn.close()
        except: pass

@adminRoutes_blueprint.route('/admin/modify_user', methods=['POST'])
def modify_user():
    data = request.json
    try:
        conn = get_db_connection(); cur = conn.cursor()
        call_sp(cur, "dbo.sp_ModifyUser", (
            data['email'],
            data.get('firstName'),
            data.get('lastName'),
            data.get('password'),
            data.get('phoneNumber'),
            data.get('userType')
        ))
        conn.commit()
        return jsonify({"success": True, "message": "User modified successfully"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try: cur.close(); conn.close()
        except: pass

@adminRoutes_blueprint.route('/admin/add_category', methods=['POST'])
def add_category():
    data = request.json
    try:
        conn = get_db_connection(); cur = conn.cursor()
        call_sp(cur, "dbo.sp_AddCategory", (data['categoryName'], data.get('description')))
        conn.commit()
        return jsonify({"success": True, "message": "Category added successfully"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try: cur.close(); conn.close()
        except: pass

@adminRoutes_blueprint.route('/admin/remove_category', methods=['POST'])
def remove_category():
    data = request.json
    try:
        conn = get_db_connection(); cur = conn.cursor()
        call_sp(cur, "dbo.sp_RemoveCategory", (data['categoryName'],))
        conn.commit()
        return jsonify({"success": True, "message": "Category removed successfully"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try: cur.close(); conn.close()
        except: pass

@adminRoutes_blueprint.route('/admin/update_category', methods=['POST'])
def update_category():
    data = request.json
    try:
        conn = get_db_connection(); cur = conn.cursor()
        call_sp(cur, "dbo.sp_UpdateCategory", (data['categoryName'], data.get('newDescription')))
        conn.commit()
        return jsonify({"success": True, "message": "Category updated successfully"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try: cur.close(); conn.close()
        except: pass

@adminRoutes_blueprint.route('/admin/add_laptop', methods=['POST'])
def add_laptop():
    data = request.json
    try:
        conn = get_db_connection(); cur = conn.cursor()
        call_sp(cur, "dbo.sp_AddLaptop", (
            data['modelName'], data['price'], data['stockQuantity'],
            data['processor'], data['ram'], data['storage'],
            data.get('graphicsCard'), data.get('screenSize'), data.get('description')
        ))
        conn.commit()
        return jsonify({"success": True, "message": "Laptop added successfully"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try: cur.close(); conn.close()
        except: pass

# Optional, since your JS has removeLaptopByName() calling this:
@adminRoutes_blueprint.route('/admin/remove_laptop', methods=['POST'])
def remove_laptop():
    data = request.json
    try:
        conn = get_db_connection(); cur = conn.cursor()
        call_sp(cur, "dbo.sp_RemoveLaptopByModel", (data['ModelName'],))
        conn.commit()
        return jsonify({"success": True, "message": "Laptop removed successfully"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try: cur.close(); conn.close()
        except: pass

# ----- Reports -----
REPORT_MAP = {
    "laptops_by_brand": "dbo.rpt_LaptopsByBrand",
    "popular_brands": "dbo.rpt_PopularBrands",
    "total_orders_by_user": "dbo.rpt_TotalOrdersByUser",
    "popular_categories": "dbo.rpt_PopularCategories",
    "total_stock_by_brand": "dbo.rpt_TotalStockByBrand",
    "average_price_by_category": "dbo.rpt_AveragePriceByCategory",
    "most_expensive_laptop_by_brand": "dbo.rpt_MostExpensiveLaptopByBrand",
    "users_with_high_spending": "dbo.rpt_UsersWithHighSpending",
    "laptops_not_in_cart": "dbo.rpt_LaptopsNotInAnyCartAbovePrice",
    "categories_with_high_stock": "dbo.rpt_CategoriesWithHighStock_NotSold",
    "no_payment_users": "dbo.rpt_NoPaymentUsersSinceYear",
}

@adminRoutes_blueprint.route('/admin/execute_query/<query_name>', methods=['GET'])
def execute_query(query_name):
    param = request.args.get('param', None)
    sp_name = REPORT_MAP.get(query_name)
    if not sp_name:
        return jsonify({"success": False, "message": "Invalid query name."})

    try:
        conn = get_db_connection(); cur = conn.cursor()
        if param is None or str(param).strip() == "":
            call_sp(cur, sp_name, ())
        else:
            call_sp(cur, sp_name, (param,))

        rows = cur.fetchall() if cur.description else []
        cols = [c[0] for c in cur.description] if cur.description else []
        results = [dict(zip(cols, r)) for r in rows] if cols else []
        return jsonify({"success": True, "results": results})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try: cur.close(); conn.close()
        except: pass

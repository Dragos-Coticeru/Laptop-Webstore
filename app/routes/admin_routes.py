from flask import Blueprint, render_template, session, redirect, jsonify, request
from app.services import get_db_connection

adminRoutes_blueprint = Blueprint('admin', __name__)

def call_sp(cursor, sp_name, params=()):
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

# Reports 
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
    "brand_revenue": "dbo.rpt_BrandRevenue",
    "unsold_inventory_risk": "dbo.rpt_UnsoldInventoryRisk",
    "monthly_category_revenue": "rpt_MonthlyCategoryRevenue",
    "restock_advice": "rpt_RestockAdvice",
    "vip_brand_affinity": "rpt_VipBrandAffinity",
    "loyalty_reward_tiers": "dbo.rpt_LoyaltyRewardTiers",
    "lagging_flagships": "dbo.rpt_LaggingFlagshipProducts"
}

REPORT_PARAMS = {
    "laptops_by_brand":       [{"name":"BrandName", "type":"text"}],
    "popular_brands":         [{"name":"MinCount", "type":"int"}],
    "total_orders_by_user":   [{"name":"MinTotalAmount", "type":"decimal"}],
    "popular_categories":     [{"name":"MinCount", "type":"int"}],
    "total_stock_by_brand":   [{"name":"BrandName", "type":"text"}],
    "average_price_by_category":[{"name":"CategoryName", "type":"text"}],
    "most_expensive_laptop_by_brand":[{"name":"BrandName", "type":"text"}],
    "users_with_high_spending":[{"name":"MinAmount", "type":"decimal"}],
    "laptops_not_in_cart":    [{"name":"MinPrice", "type":"decimal"}],
    "categories_with_high_stock":[{"name":"MinPrice", "type":"decimal"}],
    "no_payment_users":       [{"name":"Year", "type":"int"}],


    "brand_revenue": [
        {"name":"StartDate",  "type":"date"},
        {"name":"EndDate",    "type":"date"},
        {"name":"MinRevenue", "type":"decimal"}
    ],
    "unsold_inventory_risk": [{"name":"MinUnits","type":"int"}],
    "monthly_category_revenue": [{"name":"Year", "type":"int"}],
    "restock_advice": [{"name":"SafetyStockThreshold", "type":"int"}],
    "vip_brand_affinity": [
        {"name":"StartDate", "type":"date"},
        {"name":"EndDate", "type":"date"},
        {"name":"MinTotalSpend", "type":"decimal"}
    ],
    "loyalty_reward_tiers": [
        {"name":"MinTotalSpend", "type":"decimal"},
        {"name":"LookbackDate", "type":"date"}
    ],
    "lagging_flagships": [
        {"name":"MinPrice", "type":"decimal"}
    ]
}

def _cast(value, typ):
    if value is None:
        return None
    try:
        if typ == "int":
            return int(value)
        if typ == "decimal" or typ == "float":
            return float(value)
    
        return value
    except:
        return value


@adminRoutes_blueprint.route('/admin/execute_query/<query_name>', methods=['GET'])
def execute_query(query_name):
    sp_name = REPORT_MAP.get(query_name)
    if not sp_name:
        return jsonify({"success": False, "message": "Invalid query name."})


    param_defs = REPORT_PARAMS.get(query_name, [])
    params = []
    for d in param_defs:
        raw = request.args.get(d["name"])
        params.append(_cast(raw, d.get("type")))

    try:
        conn = get_db_connection(); cur = conn.cursor()
        call_sp(cur, sp_name, tuple(params))
        rows = cur.fetchall() if cur.description else []
        cols = [c[0] for c in cur.description] if cur.description else []
        results = [dict(zip(cols, r)) for r in rows] if cols else []
        return jsonify({"success": True, "results": results})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try: cur.close(); conn.close()
        except: pass
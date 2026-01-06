from flask import Blueprint, render_template, jsonify, request
import pypyodbc as odbc
from app.services import get_db_connection 

create_user_blueprint = Blueprint('create_user', __name__)

def call_sp(cursor, sp_name, params=()):
    placeholders = ",".join(["?"] * len(params))
    sql = f"EXEC {sp_name} {placeholders}" if placeholders else f"EXEC {sp_name}"
    cursor.execute(sql, params)

@create_user_blueprint.route('/create_account')
def create_account():
    return render_template('createUser.html')

@create_user_blueprint.route('/create_user', methods=['POST'])
def create_user():
    data = request.get_json()
    first_name = data.get('first_name')
    last_name = data.get('last_name')
    email = data.get('email')
    password = data.get('password')
    phone_number = data.get('phone_number')

    if not first_name:
        return jsonify({"success": False, "message": "First name not completed."})
    if not last_name:
        return jsonify({"success": False, "message": "Last name not completed."})
    if not email:
        return jsonify({"success": False, "message": "Email not completed."})
    if not password:
        return jsonify({"success": False, "message": "Password not completed."})

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        call_sp(cursor, "dbo.sp_RegisterUserWithCart", (
            first_name, last_name, email, password, phone_number
        ))
        
        conn.commit()
        return jsonify({"success": True})
    except Exception as e:
        error_msg = str(e).split(']')[-1].strip() if ']' in str(e) else str(e)
        return jsonify({"success": False, "message": error_msg})
    finally:
        try:
            cursor.close()
            conn.close()
        except:
            pass
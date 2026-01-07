from flask import Blueprint, render_template, jsonify, request, session
import pypyodbc as odbc
from app.services import get_db_connection

login_blueprint = Blueprint('login', __name__)

def call_sp(cursor, sp_name, params=()):
    placeholders = ",".join(["?"] * len(params))
    sql = f"EXEC {sp_name} {placeholders}" if placeholders else f"EXEC {sp_name}"
    cursor.execute(sql, params)

@login_blueprint.route('/')
def login_page():
    return render_template('index.html')

@login_blueprint.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        call_sp(cursor, "dbo.sp_AuthenticateUser", (email, password))
        user_data = cursor.fetchone()

        if user_data:
            session['UserID'] = user_data[0]
            session['UserType'] = user_data[1]
            session['CartID'] = user_data[2]

            redirect_url = "/admin" if user_data[1] == "A" else "/catalog"
            
            return jsonify({"success": True, "redirect": redirect_url})
        else:
            return jsonify({"success": False, "message": "Invalid email or password."})

    except Exception as e:
        return jsonify({"success": False, "message": str(e)})
    finally:
        try:
            cursor.close()
            conn.close()
        except:
            pass
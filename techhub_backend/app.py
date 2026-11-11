import os
import datetime
from functools import wraps
from flask import Flask, request, jsonify, render_template, redirect, url_for, send_from_directory, session
from flask_cors import CORS
from werkzeug.utils import secure_filename
import mysql.connector
import jwt
import bcrypt

app = Flask(__name__)
app.secret_key = "techhub_admin_super_secret_session_key_2026"
CORS(app, resources={r"/*": {"origins": "*"}})

SECRET_KEY = "techhub_super_secret_jwt_key_2026"

# ==================== FILE UPLOAD CONFIGURATION ====================
UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'uploads')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp', 'gif'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def resolve_image_url(raw_url):
    if not raw_url:
        return ''
    base = request.host_url.rstrip('/')
    if raw_url.startswith('/uploads/'):
        return f"{base}{raw_url}"
    if '/uploads/' in raw_url:
        path = raw_url[raw_url.find('/uploads/'):]
        return f"{base}{path}"
    return raw_url

# ==================== DATABASE CONNECTION & INITIALIZATION ====================
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="ecommerce_db"
    )

def ensure_tables():
    """Ensure core tables and admin_users RBAC exist."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)

        cur.execute("""
            CREATE TABLE IF NOT EXISTS admin_users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                username VARCHAR(60) NOT NULL UNIQUE,
                password_hash VARCHAR(255) NOT NULL,
                full_name VARCHAR(100) NOT NULL,
                role ENUM('admin', 'staff') NOT NULL DEFAULT 'staff',
                is_active TINYINT(1) NOT NULL DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        cur.execute("SELECT id FROM admin_users WHERE username = 'admin'")
        if not cur.fetchone():
            hashed_admin = bcrypt.hashpw("admin123".encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
            cur.execute("""
                INSERT INTO admin_users (username, password_hash, full_name, role, is_active)
                VALUES ('admin', %s, 'Wan Sokhour (Master Admin)', 'admin', 1)
            """, (hashed_admin,))
            conn.commit()

        cur.execute("""
            CREATE TABLE IF NOT EXISTS categories (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                icon VARCHAR(50) DEFAULT 'category',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        cur.execute("""
            CREATE TABLE IF NOT EXISTS products (
                id INT AUTO_INCREMENT PRIMARY KEY,
                category_id INT NOT NULL,
                name VARCHAR(200) NOT NULL,
                brand VARCHAR(100) NOT NULL,
                description TEXT,
                price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
                stock_quantity INT NOT NULL DEFAULT 0,
                rating DECIMAL(2, 1) DEFAULT 5.0,
                image_url VARCHAR(255),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        cur.execute("""
            CREATE TABLE IF NOT EXISTS orders (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NULL,
                customer_name VARCHAR(100) NOT NULL,
                phone VARCHAR(30) NOT NULL,
                address TEXT NOT NULL,
                payment_method VARCHAR(50) NOT NULL DEFAULT 'ABA PayWay',
                total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
                delivery_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
                status VARCHAR(50) NOT NULL DEFAULT 'Confirmed',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        cur.execute("""
            CREATE TABLE IF NOT EXISTS order_items (
                id INT AUTO_INCREMENT PRIMARY KEY,
                order_id INT NOT NULL,
                product_id INT NOT NULL,
                quantity INT NOT NULL DEFAULT 1,
                unit_price DECIMAL(10, 2) NOT NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        cur.execute("""
            CREATE TABLE IF NOT EXISTS notifications (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NULL,
                title VARCHAR(255) NOT NULL,
                message TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        cur.execute("""
            CREATE TABLE IF NOT EXISTS wishlist (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NULL,
                product_id INT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print("[DB Init Notice]:", e)

ensure_tables()

# ==================== RBAC GUARDS ====================
def admin_login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('admin_user_id'):
            return redirect(url_for('admin_login'))
        return f(*args, **kwargs)
    return decorated_function

def super_admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('admin_user_id'):
            return redirect(url_for('admin_login'))
        if session.get('admin_role') != 'admin':
            return "Access Denied: Super Admin permission required.", 403
        return f(*args, **kwargs)
    return decorated_function

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/', methods=['GET'])
def index():
    return jsonify({
        "status": "Online",
        "service": "TechHub Store REST API 2.0"
    }), 200

# ==================== ADMIN AUTH ====================
@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    error = None
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '').strip()

        if username == 'admin' and password == 'admin123':
            session['admin_user_id'] = 1
            session['admin_username'] = 'admin'
            session['admin_name'] = 'Wan Sokhour (Master Admin)'
            session['admin_role'] = 'admin'
            return redirect(url_for('admin_dashboard'))

        try:
            conn = get_db_connection()
            cur = conn.cursor(dictionary=True)
            cur.execute("SELECT * FROM admin_users WHERE username = %s AND is_active = 1", (username,))
            account = cur.fetchone()
            cur.close()
            conn.close()

            if account and bcrypt.checkpw(password.encode('utf-8'), account['password_hash'].encode('utf-8')):
                session['admin_user_id'] = account['id']
                session['admin_username'] = account['username']
                session['admin_name'] = account['full_name']
                session['admin_role'] = account['role']
                return redirect(url_for('admin_dashboard'))
        except Exception as e:
            error = f"Database error: {e}"

        error = "Invalid credentials or inactive account."
    return render_template('admin_login.html', error=error)

@app.route('/admin/logout')
def admin_logout():
    session.clear()
    return redirect(url_for('admin_login'))

# ==================== ADMIN DASHBOARD ====================
@app.route('/admin', methods=['GET'])
@admin_login_required
def admin_dashboard():
    current_role = session.get('admin_role', 'admin')
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT 
                COUNT(*) as total_orders,
                COALESCE(SUM(total_amount), 0.00) as total_revenue,
                SUM(CASE WHEN status = 'Delivered' THEN 1 ELSE 0 END) as delivered_orders,
                SUM(CASE WHEN status = 'Confirmed' OR status = 'Shipping' THEN 1 ELSE 0 END) as pending_orders,
                SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) as cancelled_orders
            FROM orders
        """)
        finance = cursor.fetchone()

        cursor.execute("SELECT COUNT(*) as low_stock_count FROM products WHERE stock_quantity < 5")
        low_stock = cursor.fetchone()['low_stock_count'] or 0

        cursor.execute("SELECT COUNT(*) as total_customers FROM users")
        customer_count = cursor.fetchone()['total_customers'] or 0

        stats = {
            "total_orders": finance['total_orders'] or 0,
            "total_revenue": float(finance['total_revenue'] or 0.0) if current_role == 'admin' else None,
            "delivered_orders": int(finance['delivered_orders'] or 0),
            "pending_orders": int(finance['pending_orders'] or 0),
            "cancelled_orders": int(finance['cancelled_orders'] or 0),
            "low_stock_count": low_stock,
            "total_customers": customer_count,
            "today_visitors": 48,
        }

        # Categories
        cursor.execute("SELECT * FROM categories ORDER BY id ASC")
        categories = cursor.fetchall()

        # Products
        cursor.execute("""
            SELECT p.*, c.name as category_name 
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            ORDER BY p.id DESC
        """)
        products = cursor.fetchall()
        for p in products:
            p['price'] = float(p.get('price') or 0.0)
            p['image_url'] = resolve_image_url(p.get('image_url'))

        # Orders with items
        cursor.execute("SELECT * FROM orders ORDER BY id DESC LIMIT 50")
        orders = cursor.fetchall()

        cursor.execute("""
            SELECT oi.id, oi.order_id, oi.product_id, oi.quantity, oi.unit_price,
                   COALESCE(p.name, 'Product Item') as product_name,
                   (oi.quantity * oi.unit_price) as subtotal
            FROM order_items oi
            LEFT JOIN products p ON oi.product_id = p.id
            ORDER BY oi.id ASC
        """)
        all_items = cursor.fetchall()

        for o in orders:
            o['total_amount'] = float(o.get('total_amount') or 0.0)
            o['order_items'] = [i for i in all_items if i['order_id'] == o['id']]

        # Users and Staff (Admin only)
        users = []
        staff_members = []
        if current_role == 'admin':
            cursor.execute("SELECT id, name, email, phone, address, created_at FROM users ORDER BY id DESC")
            users = cursor.fetchall()

            cursor.execute("SELECT id, username, full_name, role, is_active, created_at FROM admin_users ORDER BY id DESC")
            staff_members = cursor.fetchall()

        cursor.close()
        conn.close()

        return render_template(
            'admin.html',
            stats=stats,
            categories=categories,
            products=products,
            orders=orders,
            users=users,
            staff_members=staff_members,
            current_user={
                'name': session.get('admin_name', 'Administrator'),
                'username': session.get('admin_username', 'admin'),
                'role': current_role
            }
        )
    except Exception as e:
        return f"Database Error: {str(e)}", 500

# ==================== PRODUCTS CRUD ====================
@app.route('/admin/product/add', methods=['POST'])
@admin_login_required
def admin_add_product():
    name = request.form.get('name', '').strip()
    brand = request.form.get('brand', '').strip()
    category_id = request.form.get('category_id')
    price = request.form.get('price', 0.0)
    stock = request.form.get('stock_quantity', 10)
    desc = request.form.get('description', '')
    img_url = None

    if 'image' in request.files:
        file = request.files['image']
        if file and file.filename != '' and allowed_file(file.filename):
            fn = secure_filename(f"{int(datetime.datetime.now().timestamp())}_{file.filename}")
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], fn))
            img_url = f"/uploads/{fn}"

    if name and category_id:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO products (category_id, name, brand, description, price, stock_quantity, rating, image_url)
            VALUES (%s, %s, %s, %s, %s, %s, 5.0, %s)
        """, (category_id, name, brand, desc, price, stock, img_url))
        conn.commit()
        cur.close()
        conn.close()

    return redirect(url_for('admin_dashboard'))

@app.route('/admin/product/edit/<int:product_id>', methods=['POST'])
@admin_login_required
def admin_edit_product(product_id):
    name = request.form.get('name', '').strip()
    brand = request.form.get('brand', '').strip()
    category_id = request.form.get('category_id')
    price = request.form.get('price', 0.0)
    stock = request.form.get('stock_quantity', 0)
    desc = request.form.get('description', '')

    conn = get_db_connection()
    cur = conn.cursor()

    if 'image' in request.files:
        file = request.files['image']
        if file and file.filename != '' and allowed_file(file.filename):
            fn = secure_filename(f"{int(datetime.datetime.now().timestamp())}_{file.filename}")
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], fn))
            img_url = f"/uploads/{fn}"
            cur.execute("""
                UPDATE products 
                SET category_id = %s, name = %s, brand = %s, description = %s, 
                    price = %s, stock_quantity = %s, image_url = %s
                WHERE id = %s
            """, (category_id, name, brand, desc, price, stock, img_url, product_id))
            conn.commit()
            cur.close()
            conn.close()
            return redirect(url_for('admin_dashboard'))

    cur.execute("""
        UPDATE products 
        SET category_id = %s, name = %s, brand = %s, description = %s, price = %s, stock_quantity = %s
        WHERE id = %s
    """, (category_id, name, brand, desc, price, stock, product_id))
    conn.commit()
    cur.close()
    conn.close()

    return redirect(url_for('admin_dashboard'))

@app.route('/admin/product/adjust-stock/<int:product_id>')
@admin_login_required
def adjust_stock(product_id):
    amount = int(request.args.get('amount', 0))
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("UPDATE products SET stock_quantity = GREATEST(0, stock_quantity + %s) WHERE id = %s", (amount, product_id))
    conn.commit()
    cur.close()
    conn.close()
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/product/delete/<int:product_id>', methods=['POST'])
@admin_login_required
def admin_delete_product(product_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM products WHERE id = %s", (product_id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect(url_for('admin_dashboard'))

# ==================== CATEGORIES CRUD ====================
@app.route('/admin/category/add', methods=['POST'])
@admin_login_required
def admin_add_category():
    name = request.form.get('name', '').strip()
    icon = request.form.get('icon', 'category').strip()
    if name:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO categories (name, icon) VALUES (%s, %s)", (name, icon))
        conn.commit()
        cur.close()
        conn.close()
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/category/update/<int:category_id>', methods=['POST'])
@admin_login_required
def admin_update_category(category_id):
    name = request.form.get('name', '').strip()
    icon = request.form.get('icon', 'category').strip()
    if name:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("UPDATE categories SET name = %s, icon = %s WHERE id = %s", (name, icon, category_id))
        conn.commit()
        cur.close()
        conn.close()
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/category/delete/<int:category_id>', methods=['POST'])
@admin_login_required
def admin_delete_category(category_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM categories WHERE id = %s", (category_id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect(url_for('admin_dashboard'))

# ==================== ORDERS UPDATE ====================
@app.route('/admin/order/update-status/<int:order_id>', methods=['POST'])
@admin_login_required
def admin_update_order_status(order_id):
    new_status = request.form.get('status', 'Confirmed').strip()
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute("UPDATE orders SET status = %s WHERE id = %s", (new_status, order_id))

        cur.execute("SELECT user_id FROM orders WHERE id = %s", (order_id,))
        order = cur.fetchone()
        user_id = order['user_id'] if order else None

        status_msgs = {
            'Confirmed': f"Your order #{order_id} has been confirmed.",
            'Shipping': f"Order #{order_id} has departed and is on the way!",
            'Delivered': f"Order #{order_id} has been delivered. Thank you!",
            'Cancelled': f"Notice: Order #{order_id} was cancelled."
        }
        msg = status_msgs.get(new_status, f"Order #{order_id} status updated to '{new_status}'.")
        title = f"Order #{order_id} {new_status}"

        cur.execute("""
            INSERT INTO notifications (user_id, title, message)
            VALUES (%s, %s, %s)
        """, (user_id, title, msg))

        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print("[Status Update Error]:", e)

    return redirect(url_for('admin_dashboard'))

# ==================== STAFF MANAGEMENT ====================
@app.route('/admin/staff/create', methods=['POST'])
@super_admin_required
def admin_create_staff():
    username = request.form.get('username', '').strip()
    password = request.form.get('password', '').strip()
    full_name = request.form.get('full_name', '').strip()
    role = request.form.get('role', 'staff').strip()

    if username and password and full_name:
        hashed_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("""
                INSERT INTO admin_users (username, password_hash, full_name, role, is_active)
                VALUES (%s, %s, %s, %s, 1)
            """, (username, hashed_pw, full_name, role))
            conn.commit()
            cur.close()
            conn.close()
        except Exception as e:
            print("[Staff Create Error]:", e)

    return redirect(url_for('admin_dashboard'))

@app.route('/admin/staff/update/<int:staff_id>', methods=['POST'])
@super_admin_required
def admin_update_staff(staff_id):
    role = request.form.get('role', 'staff').strip()
    is_active = 1 if request.form.get('is_active') == '1' else 0
    new_password = request.form.get('password', '').strip()

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        if new_password:
            hashed_pw = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
            cur.execute("""
                UPDATE admin_users SET role = %s, is_active = %s, password_hash = %s WHERE id = %s
            """, (role, is_active, hashed_pw, staff_id))
        else:
            cur.execute("""
                UPDATE admin_users SET role = %s, is_active = %s WHERE id = %s
            """, (role, is_active, staff_id))
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print("[Staff Update Error]:", e)

    return redirect(url_for('admin_dashboard'))

@app.route('/admin/staff/delete/<int:staff_id>', methods=['POST'])
@super_admin_required
def admin_delete_staff(staff_id):
    if staff_id != session.get('admin_user_id'):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("DELETE FROM admin_users WHERE id = %s", (staff_id,))
            conn.commit()
            cur.close()
            conn.close()
        except Exception as e:
            print("[Staff Delete Error]:", e)

    return redirect(url_for('admin_dashboard'))

# ==================== CLIENT MANAGEMENT ====================
@app.route('/admin/client/create', methods=['POST'])
@super_admin_required
def admin_create_client():
    name = request.form.get('name', '').strip()
    email = request.form.get('email', '').strip()
    password = request.form.get('password', '').strip()
    phone = request.form.get('phone', '').strip()
    address = request.form.get('address', '').strip()

    if name and email and password:
        hashed_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("""
                INSERT INTO users (name, email, password_hash, phone, address)
                VALUES (%s, %s, %s, %s, %s)
            """, (name, email, hashed_pw, phone, address))
            conn.commit()
            cur.close()
            conn.close()
        except Exception as e:
            print("[Client Create Error]:", e)

    return redirect(url_for('admin_dashboard'))

@app.route('/admin/client/update/<int:user_id>', methods=['POST'])
@super_admin_required
def admin_update_client(user_id):
    name = request.form.get('name', '').strip()
    phone = request.form.get('phone', '').strip()
    address = request.form.get('address', '').strip()

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            UPDATE users SET name = %s, phone = %s, address = %s WHERE id = %s
        """, (name, phone, address, user_id))
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print("[Client Update Error]:", e)

    return redirect(url_for('admin_dashboard'))

@app.route('/admin/client/delete/<int:user_id>', methods=['POST'])
@super_admin_required
def admin_delete_client(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("DELETE FROM users WHERE id = %s", (user_id,))
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print("[Client Delete Error]:", e)

    return redirect(url_for('admin_dashboard'))

# ==================== FLUTTER CLIENT REST APIS ====================
@app.route('/api/v1/auth/register', methods=['POST'])
def register():
    data = request.json or {}
    name = data.get('name')
    email = data.get('email')
    pw = data.get('password')
    phone = data.get('phone', '')

    if not name or not email or not pw:
        return jsonify({"message": "Name, email, and password required"}), 400

    hashed_pw = bcrypt.hashpw(pw.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO users (name, email, password_hash, phone) VALUES (%s, %s, %s, %s)",
                    (name, email, hashed_pw, phone))
        conn.commit()
        uid = cur.lastrowid
        cur.close()
        conn.close()
        return jsonify({"message": "User registered successfully", "user_id": uid}), 201
    except Exception as e:
        return jsonify({"message": str(e)}), 400

@app.route('/api/v1/auth/login', methods=['POST'])
def login():
    data = request.json or {}
    email = data.get('email')
    pw = data.get('password')

    conn = get_db_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM users WHERE email = %s", (email,))
    user = cur.fetchone()
    cur.close()
    conn.close()

    if user and bcrypt.checkpw(pw.encode('utf-8'), user['password_hash'].encode('utf-8')):
        token = jwt.encode({
            'user_id': user['id'],
            'exp': datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=15)
        }, SECRET_KEY, algorithm="HS256")
        return jsonify({
            "token": token,
            "user": {
                "id": user['id'],
                "name": user['name'],
                "email": user['email'],
                "phone": user.get('phone') or '',
                "address": user.get('address') or ''
            }
        }), 200

    return jsonify({"message": "Invalid email or password"}), 401

@app.route('/api/v1/users/<int:user_id>', methods=['POST', 'PUT'])
def update_user_profile(user_id):
    data = request.json or {}
    name = data.get('name')
    phone = data.get('phone')
    address = data.get('address')

    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute("""
            UPDATE users 
            SET name = COALESCE(%s, name),
                phone = COALESCE(%s, phone),
                address = COALESCE(%s, address)
            WHERE id = %s
        """, (name, phone, address, user_id))
        conn.commit()

        cur.execute("SELECT id, name, email, phone, address FROM users WHERE id = %s", (user_id,))
        updated_user = cur.fetchone()
        cur.close()
        conn.close()

        return jsonify({
            "status": "success",
            "message": "Profile updated successfully",
            "user": updated_user
        }), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/api/v1/categories', methods=['GET'])
def get_categories():
    conn = get_db_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM categories ORDER BY id ASC")
    cats = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(cats), 200

@app.route('/api/v1/products', methods=['GET'])
def get_products():
    category_id = request.args.get('category_id')
    search_query = request.args.get('search')

    conn = get_db_connection()
    cur = conn.cursor(dictionary=True)
    query = "SELECT * FROM products WHERE 1=1"
    params = []

    if category_id and category_id != '0':
        query += " AND category_id = %s"
        params.append(category_id)

    if search_query and search_query.strip():
        query += " AND (name LIKE %s OR brand LIKE %s)"
        params.extend([f"%{search_query.strip()}%", f"%{search_query.strip()}%"])

    query += " ORDER BY id ASC"
    cur.execute(query, tuple(params))
    products = cur.fetchall()
    cur.close()
    conn.close()

    for p in products:
        p['price'] = float(p['price']) if p.get('price') else 0.0
        p['rating'] = float(p['rating']) if p.get('rating') else 5.0
        p['stock_quantity'] = int(p.get('stock_quantity') or 0)
        p['image_url'] = resolve_image_url(p.get('image_url'))

    return jsonify(products), 200

@app.route('/api/v1/orders/checkout', methods=['POST'])
def checkout_order():
    data = request.json or {}
    raw_user_id = data.get('user_id')
    customer_name = str(data.get('customer_name') or data.get('name') or 'Customer').strip()
    phone = str(data.get('phone') or '012345678').strip()
    address = str(data.get('address') or 'Phnom Penh').strip()
    payment_method = str(data.get('payment_method') or 'ABA PayWay (KHQR)').strip()

    try:
        total_amount = float(data.get('amount') or data.get('total') or 0.0)
    except Exception:
        total_amount = 0.0

    try:
        delivery_fee = float(data.get('delivery_fee') or 0.0)
    except Exception:
        delivery_fee = 0.0

    cart_items = data.get('items') or data.get('cart_items') or []

    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)

        valid_user_id = None
        if raw_user_id:
            try:
                check_uid = int(raw_user_id)
                cur.execute("SELECT id FROM users WHERE id = %s", (check_uid,))
                if cur.fetchone():
                    valid_user_id = check_uid
            except Exception:
                valid_user_id = None

        cur.execute("""
            INSERT INTO orders (user_id, customer_name, phone, address, payment_method, total_amount, delivery_fee, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, 'Confirmed')
        """, (valid_user_id, customer_name, phone, address, payment_method, total_amount, delivery_fee))
        conn.commit()
        order_id = cur.lastrowid

        try:
            cur.execute("""
                INSERT INTO notifications (user_id, title, message)
                VALUES (%s, %s, %s)
            """, (valid_user_id, f"Order #{order_id} Confirmed", f"Thank you! Your order #{order_id} has been placed successfully."))
            conn.commit()
        except Exception:
            pass

        for item in cart_items:
            prod_id = item.get('product_id') or item.get('id')
            if not prod_id:
                continue
            try:
                prod_id = int(prod_id)
                unit_price = float(item.get('price') or item.get('unit_price') or 0.0)
                qty = int(item.get('quantity') or item.get('qty') or 1)
            except Exception:
                continue

            try:
                cur.execute("""
                    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
                    VALUES (%s, %s, %s, %s)
                """, (order_id, prod_id, qty, unit_price))
            except Exception:
                pass

            try:
                cur.execute("UPDATE products SET stock_quantity = GREATEST(0, stock_quantity - %s) WHERE id = %s", (qty, prod_id))
            except Exception:
                pass

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            "status": "success",
            "order_id": order_id,
            "message": f"Order #{order_id} recorded successfully."
        }), 200

    except Exception as err:
        if conn:
            try:
                conn.close()
            except Exception:
                pass
        return jsonify({"message": f"Server failed to complete order: {str(err)}"}), 500

@app.route('/api/v1/orders/user/<int:user_id>', methods=['GET'])
def get_user_orders(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT id, customer_name, phone, address, payment_method, total_amount, delivery_fee, status, created_at
            FROM orders
            WHERE user_id = %s
            ORDER BY id DESC
        """, (user_id,))
        orders = cur.fetchall()
        cur.close()
        conn.close()
        for o in orders:
            o['total_amount'] = float(o['total_amount'])
            o['delivery_fee'] = float(o['delivery_fee'])
            o['created_at'] = str(o['created_at'])
        return jsonify(orders), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/api/v1/orders/<int:order_id>', methods=['GET'])
def get_single_order(order_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT * FROM orders WHERE id = %s", (order_id,))
        order = cur.fetchone()

        if not order:
            cur.close()
            conn.close()
            return jsonify({"message": "Order not found"}), 404

        cur.execute("""
            SELECT oi.id, oi.order_id, oi.product_id, oi.quantity, oi.unit_price,
                   COALESCE(p.name, 'Device') as product_name,
                   (oi.quantity * oi.unit_price) as subtotal
            FROM order_items oi
            LEFT JOIN products p ON oi.product_id = p.id
            WHERE oi.order_id = %s
        """, (order_id,))
        items = cur.fetchall()
        cur.close()
        conn.close()

        order['total_amount'] = float(order.get('total_amount') or 0.0)
        order['delivery_fee'] = float(order.get('delivery_fee') or 0.0)
        order['created_at'] = str(order.get('created_at') or '')

        for i in items:
            i['unit_price'] = float(i.get('unit_price') or 0.0)
            i['subtotal'] = float(i.get('subtotal') or 0.0)

        order['items'] = items
        return jsonify(order), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/api/v1/notifications', methods=['GET'])
def get_notifications():
    user_id = request.args.get('user_id')
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        if user_id and user_id != 'null' and user_id != '0':
            cur.execute("""
                SELECT * FROM notifications 
                WHERE user_id = %s OR user_id IS NULL OR user_id = 0
                ORDER BY id DESC LIMIT 50
            """, (user_id,))
        else:
            cur.execute("SELECT * FROM notifications ORDER BY id DESC LIMIT 50")
        notes = cur.fetchall()
        cur.close()
        conn.close()
        for n in notes:
            n['created_at'] = str(n.get('created_at', ''))
        return jsonify(notes), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/api/v1/wishlist/<int:user_id>', methods=['GET'])
def get_user_wishlist(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT p.* FROM products p
            JOIN wishlist w ON p.id = w.product_id
            WHERE w.user_id = %s
            ORDER BY w.created_at DESC
        """, (user_id,))
        products = cur.fetchall()
        cur.close()
        conn.close()
        for p in products:
            p['price'] = float(p['price']) if p.get('price') else 0.0
            p['rating'] = float(p['rating']) if p.get('rating') else 5.0
            p['stock_quantity'] = int(p.get('stock_quantity') or 0)
            p['image_url'] = resolve_image_url(p.get('image_url'))
        return jsonify(products), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/api/v1/wishlist/toggle', methods=['POST'])
def toggle_wishlist():
    data = request.json or {}
    user_id = data.get('user_id')
    product_id = data.get('product_id')

    if not user_id or not product_id:
        return jsonify({"message": "user_id and product_id required"}), 400

    conn = get_db_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT id FROM wishlist WHERE user_id = %s AND product_id = %s", (user_id, product_id))
    row = cur.fetchone()

    if row:
        cur.execute("DELETE FROM wishlist WHERE id = %s", (row['id'],))
        action = "removed"
    else:
        cur.execute("INSERT INTO wishlist (user_id, product_id) VALUES (%s, %s)", (user_id, product_id))
        action = "added"

    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"status": "success", "action": action}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
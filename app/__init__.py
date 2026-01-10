from flask import Flask
from flask_session import Session

def create_app():
    app = Flask(
        __name__,
        static_folder='../static',
        static_url_path='/static'
    )

    # Set the secret key for session management
    app.config['SECRET_KEY'] = 'your_secure_secret_key'
    app.config['SESSION_TYPE'] = 'filesystem'
    app.config['SESSION_PERMANENT'] = False
    app.config['SESSION_USE_SIGNER'] = True

    Session(app)

    # Import and register blueprints
    from .routes.login import login_blueprint
    from .routes.catalog import catalog_blueprint
    from .routes.create_user import create_user_blueprint
    from .routes.admin_routes import adminRoutes_blueprint

    app.register_blueprint(login_blueprint)
    app.register_blueprint(catalog_blueprint)
    app.register_blueprint(create_user_blueprint)
    app.register_blueprint(adminRoutes_blueprint)

    return app
import pypyodbc as odbc

def get_db_connection():
    DRIVER_NAME = 'SQL SERVER'
    # Numele serverului tau
    SERVER_NAME = 'DRAGOS\SQLEXPRESS'
    DATABASE_NAME = 'Website_Database'
    
    # Userul si parola create la pasii de mai sus
    UID = 'LaptopUser'
    PWD = '123'

    connection_string = f"""
        DRIVER={{{DRIVER_NAME}}};
        SERVER={SERVER_NAME};
        DATABASE={DATABASE_NAME};
        UID={UID};
        PWD={PWD};
    """
    return odbc.connect(connection_string)
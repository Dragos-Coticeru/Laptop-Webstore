Magazin Online - Platformă E-Commerce


ACEST ARHIVĂ CONȚINE:
1. Codul sursă al aplicației.
2. Scripturi SQL pentru generarea structurii și popularea datelor.
3. Documentația proiectului.


Pentru a rula aplicația, aveți nevoie de:
1. Microsoft SQL Server 2014 Express.
2. SQL Server Management Studio (SSMS).
3. Visual Studio Code.
4. Python (versiunea 3.x instalată și adăugată la PATH).

Descărcare:
   https://www.microsoft.com/en-us/download/details.aspx?id=42299

Apoi descarcati requirements folosind:
pip install -r requirements.txt


Scripturile se află în folderul: /sql_scripts

PASUL 1: Creare si Populare baza de date
1. Deschideți SSMS și conectați-vă la server (ex: localhost sau .\SQLEXPRESS).
2. File -> Open -> File -> Selectați "01create_db_sp_users.sql".
   - Apăsați butonul "Execute" (F5).
   - Acest script va crea baza de date "Website_Database", tabelele și procedurile stocate.
3. File -> Open -> File -> Selectați "02populare_tabele.sql".
   - Asigurați-vă că în dropdown-ul din stânga sus este selectată baza "Website_Database".
   - Apăsați butonul "Execute" (F5).


Deschideti codul sursa din arhiva sau clonati repository ul local folosind:
https://github.com/Dragos-Coticeru/Laptop-Webstore.git

PASUL 2: Configurare Conexiune
Navigati catre /app/services.py
4. Modificați "Server=" cu numele instanței locale.
   Exemple comune:
   - "Server=.;Database=Website_Database;Trusted_Connection=True;"
   - "Server=localhost;Database=Website_Database;Trusted_Connection=True;"
   - "Server=.\SQLEXPRESS;Database=Website_Database;Trusted_Connection=True;"

PASUL 3: Rulare
Mutati-va la nivelul de root al aplicatiei folosind cd
Rulati aplicatia folosind
python app.py

Rol: ADMIN (Acces la rapoarte și gestiune stocuri)
Email: admin@test.com
Parola: Admin123!

Rol: CUSTOMER (Poate face comenzi)
Email: user@test.com
Parola: User123!

Rol: VIP CUSTOMER (Istoric bogat de comenzi)
Email: vip@test.com
Parola: User123!
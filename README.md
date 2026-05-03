# SE_019-Stress-Less-Learning-Platform
This is the learning platform for Stress-Less, it will host the lessons on social media literacy that we offer. It will also track users' progress in completing said lessons, and potentially be directly integrated into our mobile app later on. 

The website is based on a python 3 Flask server that connects to a postgreSQL database to render html-css webpages. Most pages are dynamic, except for the about us page which does not actually allow you to send a message in its current state.

# How to install and run locally (windows)
Firstly make sure that you have python 3 and postgreSQL installed. Then clone the repository:

git clone <your-repo-url>
cd <your-project-folder>

Next you will want to create a virtual environment and activate it:

python -m venv venv
venv\Scripts\activate

Next step is to install dependencies:

pip install -r requirements.txt


Now you will have to set up the database, first enter psql as the superuser:

psql -U postgres


Now create the database and user, and then exit psql:

CREATE DATABASE <name>;
CREATE USER <username> WITH PASSWORD <password>;
GRANT ALL PRIVILEGES ON DATABASE <name> TO <username>;

\q


Now apply the schema that is included in the db subdirectory:

psql -U <username> -d <name> -h localhost -f "path to db_dump.sql"

Next create a .env file in the main directory and fill it out with the information of your database:
DB_HOST=localhost
DB_NAME=name
DB_USER=username
DB_PASSWORD=your-password
DB_PORT=5432

Now we can run the flask server:

python app.py

This will start the website and it will give you a link to access it in the terminal.

# Use Policy
You are free to use this website and database schema. Please do not to commit any changes to this repository as this is an ongoing project for my university studies.
from flask import Flask, redirect, url_for, render_template

app = Flask(__name__)

app.config.from_object('config')

@app.route('/')
def index():
  return render_template('index.html')

@app.route('/about')
def about():
  return render_template('about.html')

@app.route('/lessons')
def lessons():
  return render_template('lessons.html')

@app.route('/about-me')
def about_me():
  return redirect(url_for('about'))

if __name__ == '__main__':
  app.run()
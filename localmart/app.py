from flask import Flask, render_template, request, redirect, url_for
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

# Sample in-memory product data
products = [
    {"city": "Nashik", "product": "Grapes", "price": "₹100/kg"},
    {"city": "Jalgoan", "product": "Banana", "price": "₹40/dozon"},
    {"city": "Raigad", "product": "Alphanso", "price": "₹540/dozon"},
    {"city": "Ratnagiri", "product": "Kaju", "price": "₹240/kg"},
    {"city": "Sindhudurg", "product": "Mango", "price": "₹550/dozon"},
    {"city": "Nagpur", "product": "Oranges", "price": "₹250/kg"},
]

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/products')
def show_products():
    return render_template('products.html', products=products)

@app.route('/add', methods=['GET', 'POST'])
def add_product():
    if request.method == 'POST':
        city = request.form['city']
        product_name = request.form['product']
        price = request.form['price']
        products.append({"city": city, "product": product_name, "price": price})
        return redirect(url_for('show_products'))
    return render_template('add_product.html')


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)  # This line starts the app

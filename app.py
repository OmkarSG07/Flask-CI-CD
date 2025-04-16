from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, This (Flask CI/CD) App is created for handson practice of DevOps in realtime!"
 
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0',port = 5000)

@app.route("/health")
def health():
    return jsonify({"status": "OK"}), 200
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({
        'message': 'Ustam App API',
        'status': 'running',
        'version': '1.0'
    })

@app.route('/api/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'ustam-api'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
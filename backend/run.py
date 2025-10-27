import os

from app import create_app, socketio

app = create_app()

if __name__ == '__main__':
    debug_enabled = bool(app.config.get('DEBUG'))
    socketio.run(
        app,
        host='0.0.0.0',
        port=int(os.environ.get('PORT', 5000)),
        debug=debug_enabled,
        allow_unsafe_werkzeug=debug_enabled,
    )

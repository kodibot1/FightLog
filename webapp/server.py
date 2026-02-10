#!/usr/bin/env python3
"""
Tiny server for FightLog Voice Log web app.
Serves static files + proxies Claude API calls (avoids CORS issues).
Uses HTTPS so microphone works on Android Chrome.

Usage:
    python3 server.py

Then open https://localhost:8080 on this Mac,
or https://<your-mac-ip>:8080 on your Android phone.
(Accept the self-signed certificate warning.)
"""

import http.server
import json
import os
import ssl
import urllib.request
import urllib.error

PORT = 8080

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == "/api/analyze":
            self._proxy_claude()
        else:
            self.send_error(404)

    def _proxy_claude(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length))

        api_key = body.get("apiKey", "")
        payload = body.get("payload", {})

        data = json.dumps(payload).encode()
        req = urllib.request.Request(
            "https://api.anthropic.com/v1/messages",
            data=data,
            headers={
                "Content-Type": "application/json",
                "anthropic-version": "2023-06-01",
                "x-api-key": api_key,
            },
            method="POST",
        )

        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                result = resp.read()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(result)
        except urllib.error.HTTPError as e:
            error_body = e.read().decode()
            self.send_response(e.code)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(error_body.encode())
        except Exception as e:
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode())


if __name__ == "__main__":
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # SSL context for HTTPS (required for mic access on Android Chrome)
    cert_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cert.pem")
    key_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "key.pem")

    if os.path.exists(cert_file) and os.path.exists(key_file):
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(cert_file, key_file)
        proto = "https"
    else:
        context = None
        proto = "http"

    print(f"\n  FightLog Voice Log - Web App")
    print(f"  {proto}://localhost:{PORT}")

    # Show local IP for Android access
    import socket
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        print(f"  {proto}://{ip}:{PORT}  (use this on your Android phone)")
        if context:
            print(f"  (Accept the certificate warning in Chrome)")
    except:
        pass

    print()
    server = http.server.HTTPServer(("0.0.0.0", PORT), Handler)
    if context:
        server.socket = context.wrap_socket(server.socket, server_side=True)
    server.serve_forever()

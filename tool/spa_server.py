"""Tiny static server that rewrites unknown paths to index.html, mimicking
Firebase Hosting / the GitHub Pages 404 fallback. For local testing only."""
import http.server
import os
import sys

ROOT = sys.argv[2] if len(sys.argv) > 2 else "build/web"
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8099


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=ROOT, **k)

    def do_GET(self):
        path = self.translate_path(self.path)
        if not os.path.exists(path) or os.path.isdir(path):
            if not os.path.exists(path):
                self.path = "/index.html"
        return super().do_GET()


http.server.HTTPServer(("", PORT), Handler).serve_forever()

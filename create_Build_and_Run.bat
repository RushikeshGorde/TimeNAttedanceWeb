@echo off
cd build\web
echo Starting local web server at http://localhost:8080
start http://localhost:8080
python -m http.server 8080
#!/bin/python3
# 載入Flask套件
from flask import Flask
# 創建Flask app物件
app = Flask(__name__)
# 建立根目錄路由，並輸出文字
@app.route("/")
def hello():
    return "<h1>Hello , This a Restful Api Server by Flask...</h1>"
if __name__ == "__main__":
# Port 監聽8088，並啟動除錯模式。
    app.run(port=8088, debug=True)
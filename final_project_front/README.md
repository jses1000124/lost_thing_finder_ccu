# Flutter Project

這是一個基於 Flutter 開發的應用程序，包含了多個功能和模組。以下是詳細的介紹和使用說明。

## 目錄

- [Flutter Project](#flutter-project)
  - [目錄](#目錄)
  - [功能](#功能)
  - [安裝](#安裝)
  - [模組說明](#模組說明)

## 功能

- 地圖和建築物標記：應用包含一組建築物的地理位置信息，可以在地圖上顯示和操作。
- 聊天功能：用戶可以創建聊天室，發送和接收消息。
- 圖片上傳：支持從相機或相冊選擇圖片並上傳至 Firebase Storage。
- 通知功能：可以發送推送通知給指定的用戶。
- 用戶數據管理：用戶可以更新個人信息和設置。
- 主題切換：支持應用的主題模式（亮/暗）切換。

## 安裝

1. 確保你的開發環境已經安裝了 Flutter SDK。可以參考 [Flutter 官網](https://flutter.dev/docs/get-started/install)進行安裝。
2. 克隆本項目到本地：
    ```bash
    git clone <repository-url>
    ```
3. 使用以下命令進入項目目錄並安裝所需的依賴：
    ```bash
    cd <project-directory>
    flutter pub get
    ```
4. 使用以下命令運行應用：
    ```bash
    flutter run
    ```


## 模組說明
getNickname: 用於獲取用戶的暱稱和頭像。
referencePost: 用於在聊天室中引用帖子。
compressImage: 壓縮圖片以減少上傳大小。
GetUserData: 獲取用戶數據並更新本地存儲。
sendNotification: 發送推送通知。
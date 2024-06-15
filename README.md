# CCU Finder

這是一個基於 Flutter 開發的應用程序，提供使用者找尋遺失物服務

## 目錄

- [CCU Finder](#ccu-finder)
  - [目錄](#目錄)
  - [功能](#功能)
  - [安裝](#安裝)
  - [授權條款](#授權條款)

## 功能
- 帳號系統：使用者可以建立自己的帳號，儲存聊天室，自己的貼文等等的資訊。
- 發文功能：用戶可以發布尋獲物、待尋物的文章，其內容包含遺失物類型、名稱，遺失日期、地點，詳細內容及圖片。
- 地圖和建築物標記：應用包含一組建築物的地理位置信息，可以在地圖上顯示和操作。
- 聊天功能：用戶可以創建聊天室，發送和接收消息。
- 圖片上傳：支持從相機或相冊選擇圖片並上傳至 Firebase Storage。
- 通知功能：可以發送推送通知給指定的用戶。
- 用戶數據管理：用戶可以更新個人信息和設置。
- 主題切換：支持應用的主題模式（亮/暗）切換。

## 安裝

1. 確保你的開發環境已經安裝了 Flutter SDK。可以參考 [Flutter 官網](https://flutter.dev/docs/get-started/install)進行安裝。

2. 安裝 Android Studio：
   - 下載並安裝 [Android Studio](https://developer.android.com/studio)。
   - 安裝完成後，打開 Android Studio 並根據提示配置 Android SDK。
   - 在 "SDK Manager" 中下載所需的 Android SDK 平台和工具。

3. 設置 Android 模擬器：
   - 在 Android Studio 中，打開 "AVD Manager"（Android Virtual Device Manager）。
   - 點擊 "Create Virtual Device" 並選擇你想要的設備配置。
   - 選擇一個系統鏡像（建議選擇最新的 Android 版本）。
   - 配置完成後，點擊 "Finish" 創建模擬器。

4. 確認所有程式碼在本地。

5. 使用以下命令進入項目目錄並安裝所需的依賴：
    ```bash
    cd <project-directory>
    flutter pub get
    ```

6. 在 VS Code 中安裝 Flutter 和 Dart 擴展插件：
   - 打開 VS Code，進入擴展市場 (Extensions)。
   - 搜索並安裝 "Flutter" 和 "Dart" 擴展插件。

7. 在 VS Code 中配置 Android 模擬器：
   - 打開 VS Code 命令面板（使用 `Ctrl+Shift+P` 或 `Cmd+Shift+P`或按`F1`）。
   - 輸入 `Flutter: Launch Emulator` 並選擇你剛創建的 Android 模擬器。
   - 等待模擬器啟動完成。

8. 使用以下指令運行程式：
    ```bash
    flutter run
    ```

## 授權條款

本專案依照 [姓名標示-禁止改作4.0 國際 授權條款](https://creativecommons.org/licenses/by-nd/4.0/) 授權。


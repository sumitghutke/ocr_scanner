# 📄 AI OCR Scanner

A powerful, **fully offline** full-stack application for converting handwritten PDFs, images, and tables into digitized HTML and PDF formats.

---

## 🏗️ Project Architecture

The project is organized as a mono-repo:

*   **`backend/`**: A Flask-based Python server utilizing **EasyOCR** for high-accuracy text recognition without needing an internet connection.
*   **`mobile/`**: A modern **Flutter** mobile application providing a seamless interface for document uploading, processing, and viewing digitized results.

---

## ✨ Key Features

*   🚫 **100% Offline OCR**: Uses EasyOCR models running locally. Your data never leaves your server.
*   📝 **Handwriting Support**: Specially tuned image pre-processing to enhance ink visibility for handwritten notes.
*   📊 **Table Recognition**: Capable of detecting and digitizing structured tabular data.
*   📂 **Multi-Format Support**: Processes both multi-page PDFs and standard image formats (JPG, PNG, BMP).
*   🖨️ **PDF Export**: Generate clean, searchable digitized PDFs from the extracted content.

---

## 🚀 Getting Started

### 🐍 Backend Setup (Python)

1.  **Navigate to backend**:
    ```bash
    cd backend
    ```
2.  **Initialize Environment**:
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows use: venv\Scripts\activate
    ```
3.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```
4.  **Run Application**:
    ```bash
    python app.py
    ```
    *The server will start on `http://0.0.0.0:5000`.*

### 📱 Mobile Setup (Flutter)

1.  **Navigate to mobile**:
    ```bash
    cd mobile
    ```
2.  **Get Packages**:
    ```bash
    flutter pub get
    ```
3.  **Configure API**:
    Update the `apiUrl` in `lib/main.dart` to point to your backend IP address (important for real device testing).
4.  **Launch App**:
    ```bash
    flutter run
    ```

---

## 📜 License & Attribution

Copyright (c) 2026 **Sumit**.

This project is licensed under a **Proprietary License**. 

*   **Personal/Educational Use**: Free to use, modify, and study with proper attribution.
*   **Commercial Use**: **Strictly prohibited** without a separate paid commercial license.
*   **Attribution**: Any public use must credit **Sumit** and link back to this repository.

For commercial licensing enquiries or pre-built binaries, contact: 
📧 **ghutkesumit@gmail.com**

*Please refer to the [LICENSE](LICENSE) file for the full legal text.*

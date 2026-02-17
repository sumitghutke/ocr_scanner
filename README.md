# AI OCR Scanner

A full-stack application for converting handwritten PDFs and tables into digitized HTML and PDF formats using offline OCR.

## Project Structure

- **`backend/`**: Python Flask server using EasyOCR for offline text recognition.
- **`mobile/`**: Flutter mobile application for cross-platform document scanning and viewing.

## Getting Started

### Backend Setup

1. Navigate to `backend/`
2. Create a virtual environment: `python -m venv venv`
3. Activate it: `source venv/bin/activate`
4. Install dependencies: `pip install -r requirements.txt`
5. Run the server: `python app.py`

### Mobile Setup

1. Navigate to `mobile/`
2. Install Flutter dependencies: `flutter pub get`
3. Update `apiUrl` in `lib/main.dart` if necessary.
4. Run the app: `flutter run`

## Features

- **Offline OCR**: Uses EasyOCR, no internet required for processing.
- **PDF & Image Support**: Handles both PDFs and common image formats.
- **Table Detection**: Capable of extracting tabular data.
- **Export to PDF**: Generate digitized PDFs from processed text.

## License

MIT

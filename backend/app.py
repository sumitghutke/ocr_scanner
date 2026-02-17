import os
from flask import Flask, render_template, request, send_file, session
from flask_cors import CORS
from werkzeug.utils import secure_filename
from weasyprint import HTML
import ocr_service
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app) # Enable CORS for all routes
app.secret_key = os.urandom(24)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['Result_FOLDER'] = 'results'

os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['Result_FOLDER'], exist_ok=True)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return "No file part", 400
    file = request.files['file']
    if file.filename == '':
        return "No selected file", 400
    
    if file:
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        # Process PDF
        # Note: In a real app, this should be async (Celery/Redis)
        # For now, it's synchronous which might timeout on large files
        html_result = ocr_service.process_pdf(filepath)
        
        # Store HTML in session or pass to template
        # Session might be too small for large HTML, better to write to file
        result_filename = f"{filename}.html"
        result_path = os.path.join(app.config['Result_FOLDER'], result_filename)
        with open(result_path, 'w') as f:
            f.write(html_result)
            
        return render_template('result.html', html_content=html_result, filename=filename)

@app.route('/download-pdf', methods=['POST'])
def download_pdf():
    html_content = request.form.get('html_content')
    filename = request.form.get('filename') or 'document'
    
    # Add minimal CSS for PDF
    pdf_file = HTML(string=html_content).write_pdf()
    
    # Return as response
    from io import BytesIO
    return send_file(
        BytesIO(pdf_file),
        as_attachment=True,
        download_name=f"{filename}_digitized.pdf",
        mimetype='application/pdf'
    )

# --- API Endpoints for Mobile ---

@app.route('/api/process', methods=['POST'])
def api_process():
    if 'file' not in request.files:
        return {"error": "No file part"}, 400
    file = request.files['file']
    if file.filename == '':
        return {"error": "No selected file"}, 400
    
    if file:
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        try:
            # Handle both PDF and Image
            ext = filename.lower().split('.')[-1]
            if ext == 'pdf':
                html_result = ocr_service.process_pdf(filepath)
            elif ext in ['jpg', 'jpeg', 'png', 'bmp', 'tiff']:
                html_result = ocr_service.process_image(filepath)
            else:
                return {"error": f"Unsupported file type: {ext}"}, 400
            
            # Save HTML just in case
            result_filename = f"{filename}.html"
            result_path = os.path.join(app.config['Result_FOLDER'], result_filename)
            with open(result_path, 'w') as f:
                f.write(html_result)

            return {
                "success": True,
                "html": html_result,
                "filename": filename
            }
        except Exception as e:
            return {"error": str(e)}, 500

if __name__ == '__main__':
    # Allow all IPs so mobile can connect
    app.run(debug=True, host='0.0.0.0', port=5000)

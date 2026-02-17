import os
from pdf2image import convert_from_path
import easyocr
import numpy as np
from PIL import Image, ImageEnhance, ImageOps

# Initialize the reader (downloads models once, works offline)
# We initialize it outside processing to avoid loading it every time
try:
    reader = easyocr.Reader(['en'], gpu=False) 
except Exception as e:
    print(f"Error initializing EasyOCR: {e}")
    reader = None

def preprocess_image(img):
    """
    Enhance the image to help the OCR see handwritten ink better.
    """
    # 1. Convert to grayscale
    img = img.convert('L')
    # 2. Increase contrast significantly
    img = ImageOps.autocontrast(img, cutoff=2)
    # 3. Sharpen the image
    enhancer = ImageEnhance.Sharpness(img)
    img = enhancer.enhance(2.0)
    # 4. Brightness adjustment
    enhancer = ImageEnhance.Brightness(img)
    img = enhancer.enhance(1.2)
    return img

def process_image(image_input):
    """
    Common logic to process a single PIL Image or path
    """
    if reader is None:
        return "<p>Error: OCR engine failed to initialize.</p>"
    
    try:
        if isinstance(image_input, str):
            img = Image.open(image_input)
        else:
            img = image_input

        # PRE-PROCESS to improve handwriting visibility
        img = preprocess_image(img)
        img_np = np.array(img)

        # Perform OCR with paragraph mode to group related text
        results = reader.readtext(img_np, detail=1, paragraph=True, contrast_ths=0.1)
        
        # Sort results by Y then X
        results.sort(key=lambda x: (x[0][0][1], x[0][0][0]))
        
        page_html = ""
        for (bbox, text) in results:
            page_html += f"<div class='ocr-block' style='margin-bottom: 12px; line-height: 1.5;'>{text}</div>\n"
            
        return page_html
    except Exception as e:
        return f"<p>Error processing image: {str(e)}</p>"

def process_pdf(pdf_path, api_key=None):
    """
    Local Offline Version: PDF -> Images -> OCR Transcription
    """
    try:
        images = convert_from_path(pdf_path)
    except Exception as e:
        return f"<p>Error converting PDF: {str(e)}</p>"

    full_html = ""
    for i, img in enumerate(images):
        page_html = process_image(img)
        full_html += f"<!-- Page {i+1} -->\n<div class='page-content' style='background: white; padding: 20px; border: 1px solid #eee;'>\n{page_html}\n</div>\n<hr>\n"

    return full_html

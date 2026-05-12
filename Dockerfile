# الأساس المتين والخارق لعام 2026 - Sultan AI Hybrid
FROM python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DEFAULT_TIMEOUT=100

# توجيه المكتبات للبحث عن النماذج في المجلدات المخصصة
ENV INSIGHTFACE_ROOT=/app/models/insightface
ENV TORCH_HOME=/app/models/_cache
ENV MPLCONFIGDIR=/app/models/_cache

# 1. تثبيت أدوات النظام الأساسية (مدمجة في طبقة واحدة لتقليل الحجم)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg libsm6 libxext6 libgl1-mesa-glx git wget curl \
    gcc g++ python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. تحديث أدوات بايثون
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# 3. تثبيت النواة (PyTorch مع دعم CUDA 12.1 لكروت الشاشة)
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu121

# 4. تثبيت الترسانة الشاملة للذكاء الاصطناعي (مدمجة لتسريع البناء)
RUN pip install --no-cache-dir \
    onnx==1.16.0 \
    onnxruntime-gpu==1.17.1 \
    opencv-python-headless \
    pillow \
    tqdm \
    ultralytics \
    insightface==0.7.3 \
    gfpgan \
    basicsr \
    facexlib \
    realesrgan \
    rembg \
    fastapi \
    uvicorn[standard] \
    python-multipart

# 5. تثبيت SAM 2 من المصدر الرسمي
RUN pip install --no-cache-dir "git+https://github.com/facebookresearch/segment-anything-2.git"

# 🌟 6. الدرع الواقي: إجبار النظام على إصدار NumPy الصحيح لمنع أي انهيار 🌟
RUN pip install --no-cache-dir "numpy<2.0.0"

WORKDIR /app

# 7. بناء الهيكل الشجري الشامل لاستقبال جميع النماذج
RUN mkdir -p \
    models/_cache \
    models/swap \
    models/insightface/models/buffalo_l \
    models/gfpgan \
    models/codeformer \
    models/detection \
    models/segmentation \
    models/enhancement \
    models/recognition \
    models/pose \
    output

# 8. ضبط الصلاحيات الشاملة
RUN chmod -R 777 /app/models /app/output

# نسخ ملفات المشروع
COPY . .

# نقطة الانطلاق
CMD ["python", "main.py"]

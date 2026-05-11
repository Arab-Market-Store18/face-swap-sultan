# الأساس المستقر لعام 2026 - Sultan Hybrid
FROM python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DEFAULT_TIMEOUT=100

# إجبار المكتبات على البحث عن النماذج في المجلدات الخارجية
ENV INSIGHTFACE_ROOT=/app/models/insightface
ENV TORCH_HOME=/app/models/_cache
ENV MPLCONFIGDIR=/app/models/_cache

# 1. تثبيت أدوات النظام (دعم شامل لمعالجة الصور والذكاء الاصطناعي)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg libsm6 libxext6 libgl1-mesa-glx git wget curl \
    gcc g++ python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. تحديث Pip وأدوات التوافق
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# 3. تثبيت المكتبات الهجينة (CUDA 12.1 لدعم GPU)
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu121
RUN pip install --no-cache-dir numpy==1.26.4 onnx==1.16.0 onnxruntime-gpu==1.17.1
RUN pip install --no-cache-dir opencv-python-headless pillow tqdm

# 4. تثبيت المكتبات الأساسية والجديدة لصور العرسان
RUN pip install --no-cache-dir insightface==0.7.3 gfpgan basicsr facexlib
RUN pip install --no-cache-dir ultralytics segment-anything-2

WORKDIR /app

# 5. إنشاء الهيكل الشجري لاستقبال النماذج الخارجية
RUN mkdir -p \
    models/_cache \
    models/swap \
    models/insightface/models/buffalo_l \
    models/detection \
    models/segmentation \
    models/pose \
    output

# 6. ضبط صلاحيات الوصول
RUN chmod -R 777 /app/models /app/output

COPY . .

# تشغيل المحرك الذكي
CMD ["python", "main.py"]

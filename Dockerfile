# الأساس المستقر لعام 2026 - Sultan Hybrid
FROM python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DEFAULT_TIMEOUT=100

# إجبار المكتبات على البحث عن النماذج في المجلدات الخارجية
ENV INSIGHTFACE_ROOT=/app/models/insightface
ENV TORCH_HOME=/app/models/_cache
ENV MPLCONFIGDIR=/app/models/_cache

# 1. تثبيت أدوات النظام (بناءً على تقارير التوافق للمكتبات العلمية)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg libsm6 libxext6 libgl1-mesa-glx git wget curl \
    gcc g++ python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. تحديث أدوات التثبيت البرمجية
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# 3. تثبيت المكتبات الهجينة (استخدام CUDA 12.1 لدعم GPU بناءً على توصية PyTorch)
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu121
RUN pip install --no-cache-dir numpy==1.26.4 onnx==1.16.0 onnxruntime-gpu==1.17.1
RUN pip install --no-cache-dir opencv-python-headless pillow tqdm

# 4. تثبيت المكتبات الأساسية (الترتيب هنا حاسم لمنع تعارض نسخ Numpy و Scipy)
# تثبيت Ultralytics أولاً لضبط التبعيات الحديثة
RUN pip install --no-cache-dir ultralytics

# تثبيت مكتبات معالجة الوجوه (إصدارات مستقرة)
RUN pip install --no-cache-dir insightface==0.7.3 gfpgan basicsr facexlib

# تثبيت Segment Anything 2 (SAM 2) من المصدر الرسمي لفيسبوك 
# لضمان التوافق مع Python 3.12 وتجنب خطأ "No matching distribution"
RUN pip install --no-cache-dir "git+https://github.com/facebookresearch/segment-anything-2.git"

WORKDIR /app

# 5. إنشاء الهيكل الشجري لاستقبال النماذج الخارجية (Persistence Layer)
RUN mkdir -p \
    models/_cache \
    models/swap \
    models/insightface/models/buffalo_l \
    models/detection \
    models/segmentation \
    models/pose \
    output

# 6. ضبط صلاحيات الوصول الشاملة للمجلدات
RUN chmod -R 777 /app/models /app/output

# نسخ ملفات المشروع (main.py وأي ملفات أخرى)
COPY . .

# تشغيل المحرك الذكي
CMD ["python", "main.py"]

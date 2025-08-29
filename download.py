#模型下载
from modelscope import snapshot_download
model_dir = snapshot_download('Qwen/Qwen2-1.5B-Instruct')

# 复制目录
import shutil
shutil.copytree(model_dir, './model/qwen2')
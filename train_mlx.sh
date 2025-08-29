#!/usr/bin/env bash
set -euo pipefail

if [ ! -f train_data-new.jsonl ]; then
  echo "ERROR: train_data-new.jsonl not found"
  exit 1
fi

mkdir -p data
python3 - <<'PY'
import math, pathlib, sys
p = pathlib.Path("train_data-new.jsonl")
lines = p.read_text(encoding="utf-8").splitlines()
n = len(lines)
if n == 0:
    print("ERROR: train_data-new.jsonl is empty", file=sys.stderr); sys.exit(1)
val_n = max(1, math.floor(0.1 * n))
train_n = n - val_n
train_lines = lines[:train_n]
val_lines = lines[train_n:]
pathlib.Path("data/train.jsonl").write_text("\n".join(train_lines) + "\n", encoding="utf-8")
pathlib.Path("data/valid.jsonl").write_text("\n".join(val_lines) + "\n", encoding="utf-8")
print(f"WROTE {len(train_lines)} -> data/train.jsonl, {len(val_lines)} -> data/valid.jsonl")
PY

wc -l data/train.jsonl data/valid.jsonl

if [ -d "./mlx_adapters" ]; then
    mv "./mlx_adapters" "./mlx_adapters_backup_$(date +%Y%m%d_%H%M%S)"
fi

mlx_lm.lora \
  --model ./model/qwen2 \
  --train \
  --data data \
  --adapter-path ./mlx_adapters \
  --batch-size 1 \
  --iters 3600 \
  --learning-rate 8e-5 \
  --seed 3407 \
  --steps-per-report 20 \
  --steps-per-eval 360 \
  --save-every 360 \
  --num-layers 16 \
  --max-seq-length 2048 \
  --optimizer adam \
  --grad-checkpoint

if [ -d "./model_new" ]; then
    rm -rf "./model_new"
fi

if mlx_lm.fuse --model ./model/qwen2 --adapter-path ./mlx_adapters --save-path ./model_new 2>/dev/null; then
    echo "Model fused successfully"
    
    python3 - <<'PY'
import os
from safetensors import safe_open
from safetensors.torch import save_file

fixed = 0
for root, dirs, files in os.walk("./model_new"):
    for file in files:
        if file.endswith('.safetensors'):
            path = os.path.join(root, file)
            try:
                with safe_open(path, framework="pt", device="cpu") as f:
                    metadata = f.metadata()
                    if metadata and metadata.get("format") == "pt":
                        continue
                
                tensors = {}
                with safe_open(path, framework="pt", device="cpu") as f:
                    for key in f.keys():
                        tensors[key] = f.get_tensor(key)
                
                save_file(tensors, path, metadata={"format": "pt"})
                fixed += 1
            except: pass

print(f"Fixed {fixed} safetensors files")
PY

    cat > inference.py << 'EOF'
#!/usr/bin/env python3
try:
    from mlx_lm import load, generate
    model, tokenizer = load("./model_new")
    
    while True:
        question = input("> ")
        if question.lower() in ['exit', 'quit']:
            break
        if question.strip():
            prompt = f"下面列出了一个问题. 请写出问题的答案.\n####问题:{question}\n####答案:"
            answer = generate(model, tokenizer, prompt=prompt, max_tokens=256, temp=0.7)
            print(answer)
            print()
except ImportError:
    import subprocess
    
    while True:
        question = input("> ")
        if question.lower() in ['exit', 'quit']:
            break
        if question.strip():
            prompt = f"下面列出了一个问题. 请写出问题的答案.\n####问题:{question}\n####答案:"
            cmd = ["mlx_lm.generate", "--model", "./model_new", "--prompt", prompt, "--max-tokens", "256"]
            result = subprocess.run(cmd, capture_output=True, text=True)
            print(result.stdout.strip())
            print()
EOF

    echo "Created fused model at ./model_new"

else
    echo "Fusion failed, using adapter approach"
    
    cat > inference.py << 'EOF'
#!/usr/bin/env python3
import subprocess

while True:
    question = input("> ")
    if question.lower() in ['exit', 'quit']:
        break
    if question.strip():
        prompt = f"{question}"
        cmd = [
            "mlx_lm.generate",
            "--model", "./model_new",  # 使用融合后的模型
            "--prompt", prompt,
            "--max-tokens", "256"
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(result.stdout.strip())
        print()
EOF

fi

chmod +x inference.py
echo "Training completed"
conda activate sai_train
python3 inference.py
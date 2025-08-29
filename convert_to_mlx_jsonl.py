#!/usr/bin/env python3
# convert_to_mlx_jsonl.py
import json, sys, pathlib
src = pathlib.Path("train_data-new.json")
out = pathlib.Path("train_data-new.jsonl")
if not src.exists():
    print("ERROR: train_data-new.json not found")
    sys.exit(1)
data = json.load(src.open("r", encoding="utf-8"))
if not isinstance(data, list):
    print("ERROR: expected a JSON array at top level")
    sys.exit(2)
lines = []
for idx, item in enumerate(data):
    if not isinstance(item, dict):
        continue
    q = item.get("question")
    a = item.get("answer")
    if q is None or a is None:
        # skip malformed entries but keep going
        continue
    # 使用MLX推荐的chat格式
    chat_format = {
        "messages": [
            {"role": "user", "content": f"下面列出了一个问题. 请写出问题的答案.\n####问题:{q}"},
            {"role": "assistant", "content": f"####答案:{a}"}
        ]
    }
    lines.append(chat_format)
if not lines:
    print("ERROR: no valid entries extracted")
    sys.exit(3)
with out.open("w", encoding="utf-8") as f:
    for obj in lines:
        f.write(json.dumps(obj, ensure_ascii=False) + "\n")
print(f"WROTE {len(lines)} lines -> {out}")
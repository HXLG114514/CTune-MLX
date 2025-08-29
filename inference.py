#!/usr/bin/env python3
import subprocess

while True:
    question = input("> ")
    if question.lower() in ['exit', 'quit']:
        break
    if question.strip():
        prompt = f"下{question}\n"
        cmd = [
            "mlx_lm.generate",
            "--model", "./model_new",
            "--prompt", prompt,
            "--max-tokens", "2048"
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(result.stdout.strip())
        print()
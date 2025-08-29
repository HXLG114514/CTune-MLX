# CTune-MLX

## 介绍

<p align="center">
  <img alt="sai-coder-5" src="./CTune-MLX_Logo.svg">
</p>

这个项目用于对mlx训练模型的简单方法,他解决了在Apple Silicon上面无法使用unsloth的问题,并且生成出来的``model_new``通用自动实现了格式转换！

## 环境

### 1.Conda 安装

推荐安装 **Miniconda**更轻量

 [Miniconda 下载](https://docs.conda.io/en/latest/miniconda.html)

安装完成后验证：

```bash
conda --version
```

### 2.创建环境
```bash
conda create -n CTune-MLX python=3.10.18
```

### 3.进入项目文件夹并进入conda环境
```bash
conda activate CTune-MLX
```
## 4.安装依赖
```bash
pip install -r requirements.txt
```

## 5.下载模型
```bash
python download.py
```
下载模型要一些时间（）

## 6.转换格式
你可以修改``train_data-new.json``的内容是训练微调的数据集，你可以修改它来实现微调效果的更改
参考``训练样本提示语.txt``

### 转换
```bash
python convert_to_mlx_jsonl.py
```
运行后等待出现``train_data-new.jsonl``

## 7.训练模型

### 你可以在``train_mlx.sh``修改他的学习率以及训练参数

```bash
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
```
默认效果其实还可以无需调整直接运行
```bash
./train_mlx.sh
```
然后就可以运行``inference.py``
## 8.运行模型
```bash
python inference.py
```
在终端就能体验你的模型了

## 转换gguf

下载``llama-cpp``

```bash
git clone https://github.com/ggerganov/llama.cpp.git
```

### 先将模型转换成gguf并且精度为f32
```bash
python llama.cpp/convert_hf_to_gguf.py ./model_new --outfile model_new.gguf --outtype f32
```
### 在将转换后的模型量化成q5_1(模型较小损失精度大)
```bash
.\llama-tools\llama-quantize.exe coder5_mini_f16.gguf coder5_mini_q5_1.gguf q5_1
```

## 许可证
参考项目中的许可证文件,按照许可证在商用等领域请注意!
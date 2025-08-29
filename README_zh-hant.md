＃ctune-mlx

## 介紹

<p align =“中心”>
</and-coder-5
</p>

這個項目用於對mlx訓練模型的簡單方法,他解決了在Apple Silicon上面無法使用unsloth的問題,並且生成出來的``model_new``通用自動實現了格式轉換！

## 環境

### 1.Conda 安裝

推薦安裝 **Miniconda**更輕量

[Miniconda 下載](https://docs.conda.io/en/latest/miniconda.html)

安裝完成後驗證：

``bash
conda -version
```

### 2.創建環境
``bash
Conda Create -N Ctune -MLX Python 3.10.18
```

### 3.進入項目文件夾並進入conda環境
``bash
激活CTUNE-MLX
```
## 4.安裝依賴
``bash
pip install -r要求.txt
```

## 5.下載模型
``bash
python download.py
```
下載模型要一些時間（）

## 6.轉換格式
你可以修改``train_data-new.json``的內容是訓練微調的數據集，你可以修改它來實現微調效果的更改
參考``訓練樣本提示語.txt``

### 轉換
``bash
python convert_to_mlx_jsonl.py
```
運行後等待出現``train_data-new.jsonl``

## 7.訓練模型

### 你可以在``train_mlx.sh``修改他的學習率以及訓練參數

``bash
mlx_lm.lora \
-model ./model/qwen2 \
 - 火車 \
 - 然後日期\
-Adapter-Path ./mlx_adapters \
 - 批處理大小1 \
 - 如果3600 \
 - 學習率8e-5 \
 - 種子3407 \
 - 每報告20 \
-Steps-per-eval 360 \
 - 保存 - 每360 \
 - 納米人16 \
-max-seq長度2048 \
 - 攝影劑adam \
 -  Grad-checkpoint
```
默認效果其實還可以無需調整直接運行
``bash
./train_mlx.sh
```
然後就可以運行``inference.py``
## 8.運行模型
``bash
python infference.py
```
在終端就能體驗你的模型了

## 轉換gguf

下載``llama-cpp``

``bash
git克隆https://github.com/ggerganov/llama.cpp.git
```

### 先將模型轉換成gguf並且精度為f32
``bash
python llama.cpp/convert_hf_to_gguf.py ./model_new -outfile model_new.gguf -outtype f32
```
### 在將轉換後的模型量化成q5_1(模型較小損失精度大)
``bash
。
```

## 許可證
參考項目中的許可證文件,按照許可證在商用等領域請注意!
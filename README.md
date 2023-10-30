# llm-play


## Setup

This repository is multi-GPU friendly, and provides code to use model or data parellelism, depending on your computational resources. To install:

```
pip install -r requirements.txt
```


Hyperparameters:

| Hyperparameter      | Value 13B / 70B  |
|---------------------|--------|
| learning rate       | 2e-4 / 1e-4   |
| batch size          | 16     |
| microbatch  size    | 1      |
| warmup steps        | 100    |
| epochs              | 1      |
| weight decay        | 0.     |
| lr scheduler        | cosine |
| lora alpha          | 16     |
| lora rank           | 16     |
| lora dropout        | 0.05   |
| lora target modules | gate_proj, up_proj, down_proj|
| cutoff length       | 4096   |
| train on inputs     | False  |
| group by length     | False  |
| add eos token       | False  |


```bash
python finetune.py \
    --base_model meta-llama/Llama-2-70b-hf \
    --data-path ./data.json \
    --output_dir ./llama2-med-70b \
    --batch_size 16 \
    --micro_batch_size 1 \
    --num_epochs 1 \
    --learning_rate 0.0003 \
    --cutoff_len 2048 \
    --val_set_size 0 \
    --lora_r 16 \
    --lora_alpha 16 \
    --lora_dropout 0.05 \
    --lora_target_modules '[gate_proj, down_proj, up_proj]' \
    --train_on_inputs False \
    --add_eos_token False \
    --group_by_length False \
    --prompt_template_name alpaca \
    --lr_scheduler 'cosine' \
    --warmup_steps 100
```


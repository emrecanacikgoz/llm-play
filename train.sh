#!/bin/bash
#SBATCH --job-name=deneme-llm
#SBATCH -p palamut-cuda     # Kuyruk adi: Uzerinde GPU olan kuyruk olmasina dikkat edin.
#SBATCH -A proj12           # Kullanici adi
##SBATCH -J print_gpu       # Gonderilen isin ismi
#SBATCH -o %J.out           # Ciktinin yazilacagi dosya adi
#SBATCH --gres=gpu:6        # Her bir sunucuda kac GPU istiyorsunuz? Kumeleri kontrol edin.
#SBATCH -N 1                # Gorev kac node'da calisacak?
#SBATCH -n 1                # Ayni gorevden kac adet calistirilacak?
#SBATCH --cpus-per-task 96  # Her bir gorev kac cekirdek kullanacak? Kumeleri kontrol edin.
#SBATCH --time=3-0:0:0      # Sure siniri koyun.


echo "Setting stack size to unlimited..."
ulimit -s unlimited
ulimit -l unlimited
ulimit -a
echo

eval "$(/truba/home/$USER/miniconda3/bin/conda shell.bash hook)"
source activate platypus
echo 'number of processors:'$(nproc)
nvidia-smi

torchrun --nproc_per_node=6 --master_port=1234 finetune.py \
    --base_model meta-llama/Llama-2-7b-hf\
    --data-path /truba/home/eacikgoz/llm-deneme/Platypus/data/data.json \
    --output_dir ./llama2-7b-r16-a16-3e \
    --batch_size 16 \
    --micro_batch_size 2 \
    --num_epochs 1 \
    --learning_rate 0.0002 \
    --cutoff_len 4096 \
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


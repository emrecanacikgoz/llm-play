#!/bin/bash
#SBATCH --job-name=deneme-llm
#SBATCH -p palamut-cuda     # Kuyruk adi: Uzerinde GPU olan kuyruk olmasina dikkat edin.
#SBATCH -A proj12           # Kullanici adi
##SBATCH -J print_gpu       # Gonderilen isin ismi
#SBATCH -o %J.out           # Ciktinin yazilacagi dosya adi
#SBATCH --gres=gpu:4        # Her bir sunucuda kac GPU istiyorsunuz? Kumeleri kontrol edin.
#SBATCH -N 1                # Gorev kac node'da calisacak?
#SBATCH -n 1                # Ayni gorevden kac adet calistirilacak?
#SBATCH --cpus-per-task 64  # Her bir gorev kac cekirdek kullanacak? Kumeleri kontrol edin.
#SBATCH --time=3-0:0:0      # Sure siniri koyun.

# parameters
PORT_ID=12357
LORA_R=32
LORA_ALPHA=16
LR=0.0001
EPOCHS=3
BS=16
MBS=2
OUTPUT_DIR="/localscratch/eacikgoz/mistral-7b-r${LORA_R}-a${LORA_ALPHA}-lr${LR}-bs${BS}-mbs${MBS}-e${EPOCHS}"

echo "Setting stack size to unlimited..."
ulimit -s unlimited
ulimit -l unlimited
ulimit -a
echo

eval "$(/truba/home/$USER/miniconda3/bin/conda shell.bash hook)"
source activate platypus
echo 'number of processors:'$(nproc)
nvidia-smi

ls /localscratch
ls /localscratch/eacikgoz/

torchrun --nproc_per_node=4 --master_port=$PORT_ID finetune_mistral.py \
    --base_model mistralai/Mistral-7B-v0.1\
    --data-path /localscratch/eacikgoz/data.json \
    --output_dir $OUTPUT_DIR\
    --batch_size $BS \
    --micro_batch_size $MBS \
    --num_epochs $EPOCHS \
    --learning_rate $LR \
    --cutoff_len 4096 \
    --val_set_size 0 \
    --lora_r $LORA_R \
    --lora_alpha $LORA_ALPHA \
    --lora_dropout 0.05 \
    --lora_target_modules '[gate_proj, down_proj, up_proj]' \
    --train_on_inputs False \
    --add_eos_token False \
    --group_by_length False \
    --prompt_template_name alpaca \
    --lr_scheduler 'cosine' \
    --warmup_steps 100

cp -r $OUTPUT_DIR /truba/home/eacikgoz/checkpoints



MODEL="data/trained_model/nv-reasyn-ar-166m-v2.ckpt,data/trained_model/nv-reasyn-eb-174m-v2.ckpt"

tail -n +2 data/chembl_filtered_1k.txt | head -n 50 >data/chembl_filtered_50.txt

python scripts/sample.py \
  -m $MODEL \
  -i data/chembl_filtered_50.txt \
  -o results/chembl_50.txt \
  --num_cycles 8 \
  --num_workers_per_gpu 2

python scripts/eval_recon.py results/chembl_50.txt --total 50

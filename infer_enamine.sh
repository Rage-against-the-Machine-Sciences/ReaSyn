MODEL="data/trained_model/nv-reasyn-ar-166m-v2.ckpt,data/trained_model/nv-reasyn-eb-174m-v2.ckpt"

head -n 50 data/enamine_smiles_1k.txt >data/enamine_smiles_50.txt

python scripts/sample.py \
  -m $MODEL \
  -i data/enamine_smiles_50.txt \
  -o results/enamine_50.txt \
  --num_cycles 8 \
  --num_workers_per_gpu 2

python scripts/eval_recon.py results/enamine_50.txt --total 50

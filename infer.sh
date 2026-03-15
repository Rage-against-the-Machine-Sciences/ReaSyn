MODEL="data/trained_model/nv-reasyn-ar-166m-v2.ckpt,data/trained_model/nv-reasyn-eb-174m-v2.ckpt"

head -n 50 data/test_zinc250k.txt >data/test_zinc250k_50.txt

python scripts/sample.py \
  -m $MODEL \
  -i data/test_zinc250k_50.txt \
  -o results/zinc250k_50.txt \
  --num_cycles 8 \
  --add_bb_path data/processed/zinc250k_2048/fpindex.pkl \
  --num_workers_per_gpu 2

python scripts/eval_recon.py results/zinc250k_50.txt --total 50

# ReaSyn Inference on ZINC250k

All commands assume you are in the `ReaSyn/` directory with the `reasyn` conda environment active.

---

## Phase 1: Install dependencies

```bash
conda env create -f env.yml
conda activate reasyn
pip install rotary-embedding-torch setuptools
```

---

## Phase 2: Get reaction templates

```bash
mkdir -p data/rxn_templates
wget -O data/rxn_templates/comprehensive.txt \
  https://raw.githubusercontent.com/wenhao-gao/synformer/main/data/rxn_templates/comprehensive.txt
```

---

## Phase 3: Get preprocessed Enamine building block data

```bash
# Clone SynFormer and install it (needed for pickle compatibility)
git clone https://github.com/wenhao-gao/synformer.git
cd synformer && pip install --no-deps -e . && cd ..
pip install scikit-learn==1.6.0

# Download preprocessed files from HuggingFace
mkdir -p data/processed/comp_2048
python -c "
from huggingface_hub import hf_hub_download
hf_hub_download(repo_id='whgao/synformer', filename='fpindex.pkl', local_dir='data/processed/comp_2048')
hf_hub_download(repo_id='whgao/synformer', filename='matrix.pkl', local_dir='data/processed/comp_2048')
"

# Convert to ReaSyn format
python scripts/convert_processed_1.py
pip install scikit-learn==1.2.2
python scripts/convert_processed_2.py

# Optional cleanup
pip uninstall synformer -y
rm -rf synformer
```

---

## Phase 4: Preprocess ZINC250k building blocks

```bash
python scripts/preprocess.py --model-config configs/preprocess_zinc250k.yml
```

This generates `data/processed/zinc250k_2048/fpindex.pkl`, which is required for the ZINC250k test.

---

## Phase 5: Download model checkpoints

```bash
mkdir -p data/trained_model
python -c "
from huggingface_hub import hf_hub_download
hf_hub_download(repo_id='nvidia/NV-ReaSyn-AR-166M-v2', filename='nv-reasyn-ar-166m-v2.ckpt', local_dir='data/trained_model')
hf_hub_download(repo_id='nvidia/NV-ReaSyn-EB-174M-v2', filename='nv-reasyn-eb-174m-v2.ckpt', local_dir='data/trained_model')
"
```

---

## Phase 6: Run inference and evaluation

```bash
MODEL="data/trained_model/nv-reasyn-ar-166m-v2.ckpt,data/trained_model/nv-reasyn-eb-174m-v2.ckpt"

python scripts/sample.py \
  -m $MODEL \
  -i data/test_zinc250k.txt \
  -o results/zinc250k.txt \
  --num_cycles 16 \
  --add_bb_path data/processed/zinc250k_2048/fpindex.pkl

python scripts/eval_recon.py results/zinc250k.txt
```

The test file `data/test_zinc250k.txt` is already included in the repo.
Using multiple GPUs is recommended; `sample.py` runs workers in parallel automatically.

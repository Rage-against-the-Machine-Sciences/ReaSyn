#!/bin/bash
set -e

# Phase 2: Reaction templates
echo "=== Downloading reaction templates ==="
mkdir -p data/rxn_templates
wget -q -O data/rxn_templates/comprehensive.txt \
  https://raw.githubusercontent.com/wenhao-gao/synformer/main/data/rxn_templates/comprehensive.txt

# Phase 3: Preprocessed Enamine building block data
echo "=== Downloading preprocessed Enamine building blocks ==="
pip install -q rotary-embedding-torch setuptools huggingface_hub

git clone https://github.com/wenhao-gao/synformer.git
cd synformer && pip install -q --no-deps -e . && cd ..
pip install -q scikit-learn==1.6.0

mkdir -p data/processed/comp_2048
python -c "
from huggingface_hub import hf_hub_download
hf_hub_download(repo_id='whgao/synformer', filename='fpindex.pkl', local_dir='data/processed/comp_2048')
hf_hub_download(repo_id='whgao/synformer', filename='matrix.pkl', local_dir='data/processed/comp_2048')
"

echo "=== Converting building block data to ReaSyn format ==="
python scripts/convert_processed_1.py
pip install -q scikit-learn==1.2.2
python scripts/convert_processed_2.py

# Phase 4: ZINC250k building block preprocessing
echo "=== Preprocessing ZINC250k building blocks ==="
python scripts/preprocess.py --model-config configs/preprocess_zinc250k.yml

# Phase 5: Model checkpoints
echo "=== Downloading model checkpoints ==="
mkdir -p data/trained_model
python -c "
from huggingface_hub import hf_hub_download
hf_hub_download(repo_id='nvidia/NV-ReaSyn-AR-166M-v2', filename='nv-reasyn-ar-166m-v2.ckpt', local_dir='data/trained_model')
hf_hub_download(repo_id='nvidia/NV-ReaSyn-EB-174M-v2', filename='nv-reasyn-eb-174m-v2.ckpt', local_dir='data/trained_model')
"

echo "=== Setup complete. Run infer.sh to start inference. ==="

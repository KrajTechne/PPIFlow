#!/bin/bash
set -e  # Exit immediately if any command fails
set -x  # Forces a print of every single command it attempts to execute, prior to running it

# ------------------------------------------------------------------------------
# 1. Install System Dependencies
# ------------------------------------------------------------------------------
echo "🔧 Installing system tools (git, build-essential)..."
apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# 2. Create the Cleaned Requirements File
# ------------------------------------------------------------------------------
echo "📝 Generating requirements.txt..."

# We write the file to /tmp using a 'Here-Doc'
cat << 'EOF' > /tmp/requirements.txt
--extra-index-url https://download.pytorch.org/whl/cu121
absl-py==2.3.1
aiohappyeyeballs==2.6.1
aiohttp==3.13.2
aiosignal==1.4.0
antlr4-python3-runtime==4.9.3
antpack==0.3.8.6
asttokens==3.0.1
attrs==25.4.0
biopython==1.84
biotite==1.5.0
biotraj==1.2.2
certifi==2025.11.12
charset-normalizer==3.4.4
chembl-structure-pipeline==1.2.2
click==8.1.7
comm==0.2.3
contourpy==1.3.3
cycler==0.12.1
debugpy==1.8.18
decorator==5.2.1
dm-tree==0.1.8
docker-pycreds==0.4.0
einops==0.8.0
einx==0.3.0
executing==2.2.1
fairscale==0.4.13
filelock==3.19.1
fonttools==4.61.1
frozendict==2.4.7
frozenlist==1.8.0
fsspec==2025.9.0
gemmi==0.6.5
gitdb==4.0.12
GitPython==3.1.45
hydra-core==1.3.2
idna==3.11
ihm==2.8
ipykernel==7.1.0
ipython==9.8.0
ipython-pygments-lexers==1.1.1
jedi==0.19.2
Jinja2==3.1.6
joblib==1.5.2
jupyter_client==8.7.0
jupyter_core==5.9.1
kiwisolver==1.4.9
lightning-utilities==0.15.2
llvmlite==0.44.0
MarkupSafe==2.1.5
mashumaro==3.14
matplotlib==3.10.8
matplotlib-inline==0.2.1
ml_collections==1.1.0
modelcif==1.2
mpmath==1.3.0
msgpack==1.1.2
multidict==6.7.0
nest-asyncio==1.6.0
networkx==3.5
numba==0.61.0
numpy==1.26.4
omegaconf==2.3.0
packaging==25.0
pandas==2.3.3
parso==0.8.5
pexpect==4.9.0
pillow==11.3.0
pip==24.0
platformdirs==4.5.1
ProDy @ git+https://github.com/prody/ProDy.git
prompt_toolkit==3.0.52
propcache==0.4.1
protobuf==5.29.5
psutil==7.1.3
ptyprocess==0.7.0
pure_eval==0.2.3
py2Dmol==1.5.1
py3Dmol==2.5.3
Pygments==2.19.2
pyparsing==3.1.1
python-dateutil==2.9.0.post0
pytorch-lightning==2.5.0
pytz==2025.2
PyYAML==6.0.2
pyzmq==27.1.0
rdkit==2025.9.3
requests==2.32.3
scikit-learn==1.6.1
scipy==1.13.1
sentry-sdk==2.47.0
setproctitle==1.3.7
setuptools==70.2.0
six==1.17.0
smmap==5.0.2
stack-data==0.6.3
sympy==1.14.0
threadpoolctl==3.6.0
torch==2.4.0+cu121
torchaudio==2.4.0+cu121
torchmetrics==1.8.2
torchvision==0.19.0+cu121
tornado==6.5.3
tqdm==4.67.1
traitlets==5.14.3
triton==3.0.0
types-requests==2.32.4.20250913
typing_extensions==4.15.0
tzdata==2025.3
urllib3==2.6.2
wandb==0.18.7
wcwidth==0.2.14
wheel==0.45.1
yarl==1.22.0
freesasa==2.2.1
gputil==1.4.0
lightning==2.6.1
mdtraj==1.11.0
flash-attn @ https://github.com/Dao-AILab/flash-attention/releases/download/v2.8.3/flash_attn-2.8.3+cu12torch2.4cxx11abiFALSE-cp312-cp312-linux_x86_64.whl
EOF

# ------------------------------------------------------------------------------
# 3. Install Python Dependencies
# ------------------------------------------------------------------------------
echo "📦 Installing packages from requirements.txt..."
# We use the system pip (/databricks/python3/bin/pip is usually the default)
pip install --upgrade pip

# Force installing packages at specified versions
echo "Force installing specific versions of packages..." 
pip install -r /tmp/requirements.txt

echo "✅ Setup Complete! Your environment is ready."
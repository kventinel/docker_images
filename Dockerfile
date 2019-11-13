FROM nvidia:10.1-runtime-ubuntu18.04

apt update
apt full-upgade

pip install numpy
pip install tqdm
pip install scipy
pip install scikit-learn
pip install tensorflow-gpu
pip install torch
pip install torchvision

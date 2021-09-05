# How run container

Use following command to run docker container:
```
docker run --runtime=nvidia --network="host" --shm-size 2G -i -t [image] /bin/bash
```
For mount some folder use `-v from:to`.

And after that attach to given container.

Description of some options:

- `-i` join input stream
- `-t` join terminal
- `-d` detach from container

Then we can run jupyter notebook using following command inside docker container:
```
jupyter notebook --allow-root --no-browser --port port
```

After that we can attach to jupyter notebook using following command on local station:
```
ssh -N -f -L port:localhost:port server
```

# Info about images in this repo

Images:

- default - it's default choice for all cases
- full - need on old gpu, because modern pytorch don't build with support to old gpus. And in this image we can simple add support for new types of gpus by change TORCH_CUDA_ARCH_LIST option
- python36 - used for some python libs, that don't supprt new python3.9 or more, that used as default in default and full images

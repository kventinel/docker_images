Use `docker run --runtime=nvidia --network="host" -i -t [image] /bin/bash` for run docker container
For mount some folder use `-v from:to`
From run jupyter use `jupyter notebook --allow-root --no-browser --port port`
After that use on work station `ssh -N -f -L port:localhost:port server`

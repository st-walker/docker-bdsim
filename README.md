# docker-bdsim

A docker image for [BDSIM](https://twiki.ph.rhul.ac.uk/twiki/bin/view/PP/JAI/BdSim).

## Getting Started

### Prerequisites

Docker version 17.05 or greater (image uses multi-stage builds).

### Building the images

Clone this repository:

``` sh
git clone git@github.com:st-walker/docker-bdsim
```

Build the image:

``` sh
cd docker-bdsim
docker image build -t bdsim:my-chosen-tag .
```

Run the container:

``` sh
docker container run -v host-dir:/mnt/bdsim bdsim:my-chosen-tag \
       --file=sm.gmad --ngenerate=1000
```

where `host-dir` is the host directory to be mounted to `/mnt/bdsim`.  In the above example it would contain the file `sm.gmad`.  For example, to mount your pwd, use `-v $(pwd):/mnt/bdsim`.

## Authors

* **Stuart Walker** - [st-walker](https://github.com/st-walker)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

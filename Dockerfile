# work from latest LTS ubuntu release
FROM ubuntu:18.04

# set the environment variables
ENV optitype_version 1.3.2
ENV samtools_version 1.2
ENV bcftools_version 1.2

# run update and install necessary tools ubuntu tools
RUN apt-get update -y && apt-get install -y \
    build-essential \
    curl \
    unzip \
    python-minimal \
    bzip2 \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libnss-sss \
    libbz2-dev \
    liblzma-dev \
    libhdf5-dev \
    glpk-utils \
    python-pip \
    libpng-dev \
    libfreetype6-dev \
    libfreetype6 \
    pkg-config \
    vim \
    less

# Install additional software dependencies
WORKDIR /usr/local/bin/

#Razers3
RUN mkdir -p /usr/local/bin/ \
  && curl -SL http://packages.seqan.de/razers3/razers3-3.4.0-Linux-x86_64.zip \
  >  razers3-3.4.0-Linux-x86_64.zip
RUN unzip razers3-3.4.0-Linux-x86_64.zip && rm -f razers3-3.4.0-Linux-x86_64.zip
RUN ln -s /usr/local/bin/razers3-3.4.0-Linux-x86_64/bin/razers3 /usr/local/bin/razers3

# samtools
ADD https://github.com/samtools/samtools/releases/download/${samtools_version}/samtools-${samtools_version}.tar.bz2 /usr/local/bin/

RUN tar -xjf /usr/local/bin/samtools-${samtools_version}.tar.bz2 -C /usr/local/bin/
RUN cd /usr/local/bin/samtools-${samtools_version}/ && make
RUN cd /usr/local/bin/samtools-${samtools_version}/ && make install

# install python modules
RUN pip install 'NumPy==1.9.3'
RUN pip install 'Pyomo==4.2.10784'
RUN pip install 'Pandas==0.16.2'
RUN pip install 'Pysam==0.8.3'
RUN pip install 'Matplotlib==1.4.3'
RUN pip install 'Future==0.15.2'
RUN pip install 'tables==3.2.2'

# install optitype
RUN mkdir -p /usr/local/bin/ \
  && curl -SL https://github.com/FRED-2/OptiType/archive/v${optitype_version}.zip \
  >  v${optitype_version}.zip
RUN unzip v${optitype_version}.zip

# set up default configuration
RUN mv /usr/local/bin/OptiType-${optitype_version}/config.ini.example /usr/local/bin/OptiType-${optitype_version}/config.ini
RUN sed -i 's/\/path\/to\//\/usr\/local\/bin\//' /usr/local/bin/OptiType-${optitype_version}/config.ini
RUN sed -i 's/threads=16/threads=8/' /usr/local/bin/OptiType-${optitype_version}/config.ini

# set defualt command
WORKDIR /usr/local/bin/OptiType-${optitype_version}/
ENV PATH="/usr/local/bin/OptiType-${optitype_version}/:${PATH}"
CMD ["python", "OptiTypePipeline.py"]

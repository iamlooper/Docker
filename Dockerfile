FROM python:3.10.4

# Environmental variables
ENV PIP_NO_CACHE_DIR 1 
ENV LANG C.UTF-8 
ENV DEBIAN_FRONTEND noninteractive 
ENV GOOGLE_CHROME_BIN /usr/bin/google-chrome-stable 
ENV GOOGLE_CHROME_DRIVER /usr/bin/chromedriver

# Build essentials
RUN sed -i.bak 's/us-west-2\.ec2\.//' /etc/apt/sources.list && \
    apt -qq update && apt -qq upgrade -y && \
    apt -qq install -y --no-install-recommends \
    apt-utils \
    curl \
    git \
    gnupg2 \
    wget \
    unzip \
    tree \
    gcc python3-dev zlib1g-dev \
    apt-transport-https \
    build-essential coreutils jq pv \
    ffmpeg mediainfo \
    neofetch \
    p7zip-full \
    libfreetype6-dev libjpeg-dev libpng-dev libgif-dev libwebp-dev && \
    curl -sSL https://packages.sury.org/apache2/README.txt | bash -x && \
    apt -qq update -y && apt -qq install -y apache2 && \
    rm -rf /etc/apache2/apache2.conf && \
    rm -rf /etc/apache2/ports.conf && \
    echo "Working" > /var/www/html/index.html

# Apache2
COPY server/apache2.conf /etc/apache2/
COPY server/ports.conf etc/apache2/
COPY requirements.txt .

# Chrome drivers
RUN mkdir -p /tmp/ && \
    cd /tmp/ && \
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i ./google-chrome-stable_current_amd64.deb; apt -fqqy install && \
    wget -q http://chromedriver.storage.googleapis.com/$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip chromedriver -d /usr/bin/ && \
    rm -rf chromedriver_linux64.zip && rm -rf google-chrome-stable_current_amd64.deb && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives /tmp/*

# Inatall requirements 
RUN pip install --upgrade pip && \
    pip install --upgrade setuptools && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf requirements.txt

# Adding email and username to the bot
RUN git config --global user.email "iamlooper@gmail.com"
RUN git config --global user.name "iamlooper"

EXPOSE 8080

CMD bash -c "$(curl -fsSL https://raw.githubusercontent.com/iamlooper/Docker/main/start)"
FROM selenium/node-base:3.0.1-fermium

USER root

#============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION;
#  e.g. google-chrome-stable=53.0.2785.101-1
#       google-chrome-beta=53.0.2785.92-1
#       google-chrome-unstable=54.0.2840.14-1
#       latest (equivalent to google-chrome-stable)
#       google-chrome-beta  (pull latest beta)
#============================================
# See latest version: https://www.ubuntuupdates.org/package/google_chrome/stable/main/base/google-chrome-stable

ARG CHROME_VERSION="google-chrome-stable=56.0.2924.76-1"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#==================
# Chrome webdriver
#==================
ARG CHROME_DRIVER_VERSION=2.27
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

#=================================
# Chrome Launch Script Modication
#=================================
COPY chrome_launcher.sh /opt/google/chrome/google-chrome
RUN chmod +x /opt/google/chrome/google-chrome

#=========
# Firefox
#=========
ARG FIREFOX_VERSION=51.0
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install firefox \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
  && apt-get -y purge firefox \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
  && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

#============
# GeckoDriver
#============
ARG GECKODRIVER_VERSION=0.14.0
RUN wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GECKODRIVER_VERSION/geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz \
  && rm -rf /opt/geckodriver \
  && tar -C /opt -zxf /tmp/geckodriver.tar.gz \
  && rm /tmp/geckodriver.tar.gz \
  && mv /opt/geckodriver /opt/geckodriver-$GECKODRIVER_VERSION \
  && chmod 755 /opt/geckodriver-$GECKODRIVER_VERSION \
  && ln -fs /opt/geckodriver-$GECKODRIVER_VERSION /usr/bin/geckodriver

#======
#Additional Useful tools
#======
RUN apt-get update -qqy \
    && apt-get install jq -y \
    && apt-get install vim -y \
    && apt-get install curl -y 

#====
#Languages
#====
RUN sudo apt-get update \
 && sudo apt-get install -y language-pack-th language-pack-gnome-th language-pack-th-base language-pack-gnome-th-base \
 && sudo apt-get install -y language-pack-ja language-pack-gnome-ja language-pack-ja-base language-pack-gnome-ja-base \
 && sudo apt-get install -y language-pack-zh-hans language-pack-gnome-zh-hans language-pack-zh-hans-base language-pack-gnome-zh-hans-base \
 && sudo apt-get install -y language-pack-ar language-pack-gnome-ar language-pack-ar-base language-pack-gnome-ar-base \
 && sudo apt-get install -y language-pack-fr language-pack-gnome-fr language-pack-fr-base language-pack-gnome-fr-base \
 && sudo apt-get install -y language-pack-nl language-pack-gnome-nl language-pack-nl-base language-pack-gnome-nl-base \
 && sudo apt-get install -y language-pack-en language-pack-gnome-en language-pack-en-base language-pack-gnome-en-base \
 && sudo apt-get install -y fonts-thai-tlwg \
 && sudo apt-get install -y ttf-wqy-zenhei

#=======
#Copy New Entrypoint
#=======
COPY config.json.sh /opt/selenium
RUN chmod +x /opt/selenium/config.json.sh

COPY entry_point.sh /opt/bin
RUN chmod +x /opt/bin/entry_point.sh

RUN chown -R seluser:seluser /opt/selenium

USER seluser
# Following line fixes
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

CMD ["/opt/bin/entry_point.sh"]

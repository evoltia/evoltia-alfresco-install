#!/bin/bash
# -------
# Script for install of Alfresco
#
# Copyright 2013-2017 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

export ALF_HOME=/opt/alfresco
export ALF_DATA_HOME=$ALF_HOME/alf_data
export CATALINA_HOME=$ALF_HOME/tomcat
export ALF_USER=alfresco
export ALF_GROUP=$ALF_USER
export APTVERBOSITY="-q -y"
export TMP_INSTALL=/tmp/alfrescoinstall
export DEFAULTYESNO="y"
export GIT_USER="nachomanzano"
export GIT_PASSWORD="pistacho1650"

# Branch name to pull from server. Use master for stable.
BRANCH=develop
export BASE_DOWNLOAD=https://raw.githubusercontent.com/evoltia/evoltia-alfresco-install/$BRANCH
export KEYSTOREBASE=https://svn.alfresco.com/repos/alfresco-open-mirror/alfresco/HEAD/root/projects/repository/config/alfresco/keystore

#Change this to prefered locale to make sure it exists. This has impact on LibreOffice transformations
#export LOCALESUPPORT=sv_SE.utf8
export LOCALE=es_ES
export ENCODING=UTF-8
export LOCALESUPPORT=$LOCALE.$ENCODING

export TOMCAT_DOWNLOAD=http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.43/bin/apache-tomcat-8.5.43-deployer.tar.gz
export JDBCPOSTGRESURL=https://jdbc.postgresql.org/download
export JDBCPOSTGRES=postgresql-42.2.6.jar
export JDBCMYSQLURL=https://dev.mysql.com/get/Downloads/Connector-J
export JDBCMYSQL=mysql-connector-java-5.1.47.tar.gz

export LIBREOFFICE=http://download.documentfoundation.org/libreoffice/stable/6.4.6/rpm/x86_64/LibreOffice_6.4.6_Linux_x86-64_rpm.tar.gz

## https://www.alfresco.com/es/thank-you/thank-you-downloading-alfresco-community-edition
export ALFRESCO_DISTRIBUTION_DOWNLOAD_URL=https://download.alfresco.com/cloudfront/release/community/201911-GA-build-368/alfresco-content-services-community-distribution-6.2.0-ga.zip

export ASS_DOWNLOAD=https://download.alfresco.com/cloudfront/release/community/SearchServices/1.4.0/alfresco-search-services-1.4.0.zip

export GOOGLEDOCSREPO=$BASE_DOWNLOAD/amps/alfresco-googledocs-repo-community-3.1.0.amp
export GOOGLEDOCSSHARE=$BASE_DOWNLOAD/amps/alfresco-googledocs-share-community-3.1.0.amp

export AOS_AMP=$BASE_DOWNLOAD/amps/alfresco-aos-module-1.3.0.amp

export BASE_BART_DOWNLOAD=https://raw.githubusercontent.com/toniblyx/alfresco-backup-and-recovery-tool/master/src/

export BART_PROPERTIES=alfresco-bart.properties
export BART_EXECUTE=alfresco-bart.sh


# Color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgre=${txtbld}$(tput setaf 2) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

echoblue () {
  echo "${bldblu}$1${txtrst}"
}
echored () {
  echo "${bldred}$1${txtrst}"
}
echogreen () {
  echo "${bldgre}$1${txtrst}"
}
cd /tmp
if [ -d "alfrescoinstall" ]; then
	rm -rf alfrescoinstall
fi
mkdir alfrescoinstall
cd ./alfrescoinstall

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echogreen "Alfresco Centos installer by Evoltia."
echogreen "Please read the documentation at"
echogreen "https://github.com/evoltia/evoltia-alfresco-install"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo

echo
echo "${warn}${bldblu} - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ${warn}"
echogreen "Do you want to install Alfresco Community"
echogreen "You can use this in place of Alfresco Community from Alfresco Software"
echogreen "by manually replacing war files."
echo
echogreen "You are welcome to contact us at jmanzano@evoltia.com"
echo "${warn}${bldblu} - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ${warn}"
echo
read -e -p "Install Alfresco ECM when installing${ques} [y/n] " -i "$DEFAULTYESNO" installAlfrescoEcm
if [ "$installAlfrescoEcm" = "y" ]; then
  echo "Installing Alfresco Community edition from Alfresco Software"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Checking for the availability of the URLs inside script..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Preparing for install. Updating the apt package index files..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sudo yum $APTVERBOSITY update;
echo

if [ "`which systemctl`" = "" ]; then
  export ISON1604=n
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  echo "You are installing for version 14.04 (using upstart for services)."
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  read -e -p "Is this correct [y/n] " -i "$DEFAULTYESNO" useupstart
  if [ "$useupstart" = "n" ]; then
    export ISON1604=y
  fi
else 
  export ISON1604=y
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  echo "You are installing centos."
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  read -e -p "Is this correct [y/n] " -i "$DEFAULTYESNO" useupstart
  if [ "$useupstart" = "n" ]; then
    export ISON1604=n
  fi
fi

if [ "$ISON1604" = "n" ]; then
    echored "Installing on version prior to 16.04 no longer supported"
    exit 1
fi

if [ "`which curl`" = "" ]; then
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "You need to install curl. Curl is used for downloading components to install."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sudo yum $APTVERBOSITY install curl;
fi

if [ "`which wget`" = "" ]; then
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "You need to install wget. Wget is used for downloading components to install."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sudo yum $APTVERBOSITY install wget;
fi

URLERROR=0

for REMOTE in $ALFRESCO_DISTRIBUTION_DOWNLOAD_URL $TOMCAT_DOWNLOAD $JDBCPOSTGRESURL/$JDBCPOSTGRES $JDBCMYSQLURL/$JDBCMYSQL \
        $LIBREOFFICE $GOOGLEDOCSREPO \
        $GOOGLEDOCSSHARE $for REMOTE

do
        wget --spider $REMOTE --no-check-certificate >& /dev/null
        if [ $? != 0 ]
        then
                echored "In alfinstall.sh, please fix this URL: $REMOTE"
                URLERROR=1
        fi
done

if [ $URLERROR = 1 ]
then
    echo
    echored "Please fix the above errors and rerun."
    echo
    exit
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "You need to add a system user that runs the tomcat Alfresco instance."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add alfresco system user${ques} [y/n] " -i "$DEFAULTYESNO" addalfresco
if [ "$addalfresco" = "y" ]; then
  sudo adduser --system --user-group $ALF_USER
  echo
  echogreen "Finished adding alfresco user"
  echo
else
  echo "Skipping adding alfresco user"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "You need to set the locale to use when running tomcat Alfresco instance."
echo "This has an effect on date formats for transformations and support for"
echo "international characters."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Enter the default locale to use: " -i "$LOCALESUPPORT" LOCALESUPPORT
#install locale to support that locale date formats in open office transformations
sudo yum $APTVERBOSITY install glibc-locale-source
sudo localedef -v -c -i $LOCALE -f $ENCODING $LOCALESUPPORT
echo
echogreen "Finished updating locale"
echo

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Centos default for number of allowed open files in the file system is too low"
echo "for alfresco use and tomcat may because of this stop with the error"
echo "\"too many open files\". You should update this value if you have not done so."
echo "Read more at http://wiki.alfresco.com/wiki/Too_many_open_files"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add limits.conf${ques} [y/n] " -i "$DEFAULTYESNO" updatelimits
if [ "$updatelimits" = "y" ]; then
  echo "alfresco  soft  nofile  8192" | sudo tee -a /etc/security/limits.conf
  echo "alfresco  hard  nofile  65536" | sudo tee -a /etc/security/limits.conf
  echo
  echogreen "Updated /etc/security/limits.conf"
  echo
  echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session
  echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session-noninteractive
  echo
  echogreen "Updated /etc/security/common-session*"
  echo
else
  echo "Skipped updating limits.conf"
  echo
fi


echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Download Alfresco distribution from $ALFRESCO_DISTRIBUTION_DOWNLOAD_URL"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sudo curl -# -L -o $TMP_INSTALL/alfresco-content-services-community-distribution.zip $ALFRESCO_DISTRIBUTION_DOWNLOAD_URL
sudo unzip -j $TMP_INSTALL/alfresco-content-services-community-distribution.zip -d $TMP_INSTALL/alfresco-content-services-community-distribution

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Tomcat is the application server that runs Alfresco."
echo "You will also get the option to install jdbc lib for Postgresql or MySql/MariaDB."
echo "Install the jdbc lib for the database you intend to use."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Tomcat${ques} [y/n] " -i "$DEFAULTYESNO" installtomcat

if [ "$installtomcat" = "y" ]; then
  echogreen "Installing Tomcat"
  echo "Downloading tomcat..."
  curl -# -L -O $TOMCAT_DOWNLOAD
  # Make sure install dir exists, including logs dir
  sudo mkdir -p $ALF_HOME/logs
  echo "Extracting..."
  tar xf "$(find . -type f -name "apache-tomcat*")"
  sudo mv "$(find . -type d -name "apache-tomcat*")" $CATALINA_HOME
  # Remove apps not needed
  sudo rm -rf $CATALINA_HOME/webapps/*
  # Create Tomcat conf folder
  sudo mkdir -p $CATALINA_HOME/conf/Catalina/localhost
  # Get Alfresco config
  echo "Downloading tomcat configuration files..."
  
  sudo curl -# -o $CATALINA_HOME/conf/server.xml -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/tomcat/server.xml
  sudo curl -# -o $CATALINA_HOME/conf/catalina.properties -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/tomcat/catalina.properties
  sudo curl -# -o $CATALINA_HOME/conf/tomcat-users.xml -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/tomcat/tomcat-users.xml
  sudo curl -# -o $CATALINA_HOME/conf/context.xml -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/tomcat/context.xml
  if [ "$ISON1604" = "y" ]; then
    sudo curl -# -o /etc/systemd/system/alfresco.service -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/tomcat/alfresco.service
    sudo curl -# -o $ALF_HOME/alfresco-service.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/alfresco-service.sh
    sudo chmod 755 $ALF_HOME/alfresco-service.sh
    sudo sed -i "s/@@LOCALESUPPORT@@/$LOCALESUPPORT/g" $ALF_HOME/alfresco-service.sh 
    # Enable the service
    sudo systemctl enable alfresco.service
    sudo systemctl daemon-reload
  fi

  # Create /shared
  sudo mkdir -p $CATALINA_HOME/shared/classes/alfresco/extension
  sudo mkdir -p $CATALINA_HOME/shared/classes/alfresco/web-extension
  sudo mkdir -p $CATALINA_HOME/shared/lib
  # Add endorsed dir
  sudo mkdir -p $CATALINA_HOME/endorsed

  echo
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  echo "You need to add the dns name, port and protocol for your server(s)."
  echo "It is important that this is is a resolvable server name."
  echo "This information will be added to default configuration files."
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  read -e -p "Please enter the public host name for Share server (fully qualified domain name)${ques} [`hostname`] " -i "`hostname`" SHARE_HOSTNAME
  read -e -p "Please enter the protocol to use for public Share server (http or https)${ques} [http] " -i "http" SHARE_PROTOCOL
  SHARE_PORT=8080
  if [ "${SHARE_PROTOCOL,,}" = "https" ]; then
    SHARE_PORT=443
  fi
  read -e -p "Please enter the host name for Alfresco Repository server (fully qualified domain name) as shown to users${ques} [$SHARE_HOSTNAME] " -i "$SHARE_HOSTNAME" REPO_HOSTNAME
  read -e -p "Please enter the host name for Alfresco Repository server that Share will use to talk to repository${ques} [localhost] " -i "localhost" SHARE_TO_REPO_HOSTNAME
  # Add default alfresco-global.propertis
  ALFRESCO_GLOBAL_PROPERTIES=/tmp/alfrescoinstall/alfresco-global.properties
  sudo curl -# -o $ALFRESCO_GLOBAL_PROPERTIES -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/tomcat/alfresco-global.properties
  sed -i "s/@@ALFRESCO_SHARE_SERVER@@/$SHARE_HOSTNAME/g" $ALFRESCO_GLOBAL_PROPERTIES
  sed -i "s/@@ALFRESCO_SHARE_SERVER_PORT@@/$SHARE_PORT/g" $ALFRESCO_GLOBAL_PROPERTIES
  sed -i "s/@@ALFRESCO_SHARE_SERVER_PROTOCOL@@/$SHARE_PROTOCOL/g" $ALFRESCO_GLOBAL_PROPERTIES
  sed -i "s/@@ALFRESCO_REPO_SERVER@@/$REPO_HOSTNAME/g" $ALFRESCO_GLOBAL_PROPERTIES
  sudo mv $ALFRESCO_GLOBAL_PROPERTIES $CATALINA_HOME/shared/classes/

  read -e -p "Install Share config file (recommended)${ques} [y/n] " -i "$DEFAULTYESNO" installshareconfig
  if [ "$installshareconfig" = "y" ]; then
    SHARE_CONFIG_CUSTOM=/tmp/alfrescoinstall/share-config-custom.xml
    sudo curl -# -o $SHARE_CONFIG_CUSTOM -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/tomcat/share-config-custom.xml
    sed -i "s/@@ALFRESCO_SHARE_SERVER@@/$SHARE_HOSTNAME/g" $SHARE_CONFIG_CUSTOM
    sed -i "s/@@SHARE_TO_REPO_SERVER@@/$SHARE_TO_REPO_HOSTNAME/g" $SHARE_CONFIG_CUSTOM
    sudo mv $SHARE_CONFIG_CUSTOM $CATALINA_HOME/shared/classes/alfresco/web-extension/
  fi

  echo
  read -e -p "Install Postgres JDBC Connector${ques} [y/n] " -i "$DEFAULTYESNO" installpg
  if [ "$installpg" = "y" ]; then
	curl -# -O $JDBCPOSTGRESURL/$JDBCPOSTGRES
	sudo mv $JDBCPOSTGRES $CATALINA_HOME/lib
  fi
  echo
  read -e -p "Install Mysql JDBC Connector${ques} [y/n] " -i "$DEFAULTYESNO" installmy
  if [ "$installmy" = "y" ]; then
    cd /tmp/alfrescoinstall
	curl -# -L -O $JDBCMYSQLURL/$JDBCMYSQL
	tar xf $JDBCMYSQL
	cd "$(find . -type d -name "mysql-connector*")"
	sudo mv mysql-connector*.jar $CATALINA_HOME/lib
  fi
  sudo chown -R $ALF_USER:$ALF_GROUP $ALF_HOME
  echo
  echogreen "Finished installing Tomcat"
  echo
else
  echo "Skipping install of Tomcat"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Java JDK."
echo "This will install OpenJDK 11 version of Java. If you prefer Oracle Java 11 "
echo "you need to download and install that manually."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install OpenJDK${ques} [y/n] " -i "$DEFAULTYESNO" installjdk
if [ "$installjdk" = "y" ]; then
  echoblue "Installing OpenJDK..."
  sudo yum $APTVERBOSITY install java-11-openjdk-devel
  echo
  echogreen "Make sure correct default java is selected!"
  echo
  sudo update-alternatives --config java
  #sudo yum $APTVERBOSITY install python-software-properties software-properties-common
  #sudo add-apt-repository ppa:webupd8team/java
  #sudo yum $APTVERBOSITY update
  #echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
  #sudo yum $APTVERBOSITY install oracle-java8-installer
  #sudo update-java-alternatives -s java-8-oracle
  echo
  echogreen "Finished installing OpenJDK "
  echo
else
  echo "Skipping install of OpenJDK."
  echored "IMPORTANT: You need to install other JDK and adjust paths for the install to be complete"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install LibreOffice."
echo "This will download and install the latest LibreOffice from libreoffice.org"
echo "Newer version of Libreoffice has better document filters, and produce better"
echo "transformations. If you prefer to use Ubuntu standard packages you can skip"
echo "this install."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install LibreOffice${ques} [y/n] " -i "$DEFAULTYESNO" installibreoffice
if [ "$installibreoffice" = "y" ]; then

  cd /tmp/alfrescoinstall
  curl -# -L -O $LIBREOFFICE
  tar xf LibreOffice*.tar.gz
  cd "$(find . -type d -name "LibreOffice*")"
  cd RPMS
  sudo yum localinstall *.rpm
  echo
  echoblue "Installing some support fonts for better transformations."
  # libxinerama1 libglu1-mesa needed to get LibreOffice 4.4 to work. Add the libraries that Alfresco mention in documentatinas required.

  ###1604 fonts-droid not available, use fonts-noto instead
  sudo yum $APTVERBOSITY install ttf-mscorefonts-installer fonts-noto fontconfig libcups2 libfontconfig1 libglu1-mesa libice6 libsm6 libxinerama1 libxrender1 libxt6 libcairo2
  echo
  echogreen "Finished installing LibreOffice"
  echo
else
  echo
  echo "Skipping install of LibreOffice"
  echored "If you install LibreOffice/OpenOffice separetely, remember to update alfresco-global.properties"
  echored "Also run: sudo yum install ttf-mscorefonts-installer fonts-droid libxinerama1"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install ImageMagick."
echo "This will ImageMagick from Ubuntu packages."
echo "It is recommended that you install ImageMagick."
echo "If you prefer some other way of installing ImageMagick, skip this step."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install ImageMagick${ques} [y/n] " -i "$DEFAULTYESNO" installimagemagick
if [ "$installimagemagick" = "y" ]; then

  echoblue "Installing ImageMagick. Fetching packages..."
  #sudo yum $APTVERBOSITY install imagemagick ghostscript libgs-dev libjpeg62 libpng16-16
  sudo dnf $APTVERBOSITY install epel-release
  sudo dnf config-manager --set-enabled PowerTools
  sudo dnf update
  sudo dnf $APTVERBOSITY install ImageMagick ImageMagick-devel
fi

echo
echoblue "Adding basic support files. Always installed if not present."
echo
# Always add the addons dir and scripts
  sudo mkdir -p $ALF_HOME/addons/war
  sudo mkdir -p $ALF_HOME/addons/share
  sudo mkdir -p $ALF_HOME/addons/alfresco
  if [ ! -f "$ALF_HOME/addons/apply.sh" ]; then
    echo "Downloading apply.sh script..."
    sudo curl -# -o $ALF_HOME/addons/apply.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/apply.sh
    sudo chmod u+x $ALF_HOME/addons/apply.sh
  fi
  if [ ! -f "$ALF_HOME/addons/alfresco-mmt.jar" ]; then
    sudo cp $TMP_INSTALL/alfresco-content-services-community-distribution/alfresco-mmt.jar $ALF_HOME/addons/alfresco-mmt.jar
  fi

  # Add the jar modules dir
  sudo mkdir -p $ALF_HOME/modules/platform
  sudo mkdir -p $ALF_HOME/modules/share

  sudo mkdir -p $ALF_HOME/bin
  if [ ! -f "$ALF_HOME/bin/alfresco-pdf-renderer" ]; then
    echo "Alfresco PDF Renderer binary (alfresco-pdf-renderer)..."
    sudo cp $TMP_INSTALL/alfresco-content-services-community-distribution/alfresco-pdf-renderer-*-linux.tgz $TMP_INSTALL/alfresco-pdf-renderer.tgz
    sudo tar -xf $TMP_INSTALL/alfresco-pdf-renderer.tgz -C $TMP_INSTALL
    sudo mv $TMP_INSTALL/alfresco-pdf-renderer $ALF_HOME/bin/
  fi

  sudo mkdir -p $ALF_HOME/scripts
  if [ ! -f "$ALF_HOME/scripts/mariadb.sh" ]; then
    echo "Downloading mariadb.sh install and setup script..."
    sudo curl -# -o $ALF_HOME/scripts/mariadb.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/mariadb.sh
  fi
  if [ ! -f "$ALF_HOME/scripts/postgresql.sh" ]; then
    echo "Downloading postgresql.sh install and setup script..."
    sudo curl -# -o $ALF_HOME/scripts/postgresql.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/postgresql.sh
  fi

  if [ ! -f "$ALF_HOME/scripts/mysql.sh" ]; then
    echo "Downloading mysql.sh install and setup script..."
    sudo curl -# -o $ALF_HOME/scripts/mysql.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/mysql.sh
  fi

  if [ ! -f "$ALF_HOME/scripts/limitconvert.sh" ]; then
    echo "Downloading limitconvert.sh script..."
    sudo curl -# -o $ALF_HOME/scripts/limitconvert.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/limitconvert.sh
  fi
  if [ ! -f "$ALF_HOME/scripts/createssl.sh" ]; then
    echo "Downloading createssl.sh script..."
    sudo curl -# -o $ALF_HOME/scripts/createssl.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/createssl.sh
  fi
  if [ ! -f "$ALF_HOME/scripts/libreoffice.sh" ]; then
    echo "Downloading libreoffice.sh script..."
    sudo curl -# -o $ALF_HOME/scripts/libreoffice.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/libreoffice.sh
    sudo sed -i "s/@@LOCALESUPPORT@@/$LOCALESUPPORT/g" $ALF_HOME/scripts/libreoffice.sh
  fi
  if [ ! -f "$ALF_HOME/scripts/iptables.sh" ]; then
    echo "Downloading iptables.sh script..."
    sudo curl -# -o $ALF_HOME/scripts/iptables.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/iptables.sh
  fi
  if [ ! -f "$ALF_HOME/scripts/alfresco-iptables.conf" ]; then
    echo "Downloading alfresco-iptables.conf upstart script..."
    sudo curl -# -o $ALF_HOME/scripts/alfresco-iptables.conf -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/alfresco-iptables.conf
  fi
  if [ ! -f "$ALF_HOME/scripts/ams.sh" ]; then
    echo "Downloading maintenance shutdown script..."
    sudo curl -# -o $ALF_HOME/scripts/ams.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/scripts/ams.sh
  fi
  sudo chmod 755 $ALF_HOME/scripts/*.sh

  # Keystore
  sudo mkdir -p $ALF_DATA_HOME/keystore
  # Only check for precesence of one file, assume all the rest exists as well if so.
  if [ ! -f " $ALF_DATA_HOME/keystore/ssl.keystore" ]; then
    echo "Downloading keystore files..."
    sudo curl -# -o $ALF_DATA_HOME/keystore/browser.p12 $KEYSTOREBASE/browser.p12
    sudo curl -# -o $ALF_DATA_HOME/keystore/generate_keystores.sh $KEYSTOREBASE/generate_keystores.sh
    sudo curl -# -o $ALF_DATA_HOME/keystore/keystore $KEYSTOREBASE/keystore
    sudo curl -# -o $ALF_DATA_HOME/keystore/keystore-passwords.properties $KEYSTOREBASE/keystore-passwords.properties
    sudo curl -# -o $ALF_DATA_HOME/keystore/ssl-keystore-passwords.properties $KEYSTOREBASE/ssl-keystore-passwords.properties
    sudo curl -# -o $ALF_DATA_HOME/keystore/ssl-truststore-passwords.properties $KEYSTOREBASE/ssl-truststore-passwords.properties
    sudo curl -# -o $ALF_DATA_HOME/keystore/ssl.keystore $KEYSTOREBASE/ssl.keystore
    sudo curl -# -o $ALF_DATA_HOME/keystore/ssl.truststore $KEYSTOREBASE/ssl.truststore
  fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Alfresco war files."
echo "Download war files and optional addons."
echo "If you have already downloaded your war files you can skip this step and add "
echo "them manually."
echo
echo "If you use separate Alfresco and Share server, only install the needed for each"
echo "server. Alfresco Repository will need Share Services if you use Share."
echo
echo "This install place downloaded files in the $ALF_HOME/addons and then use the"
echo "apply.sh script to add them to tomcat/webapps. Se this script for more info."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add Alfresco Repository war file${ques} [y/n] " -i "$DEFAULTYESNO" installwar
if [ "$installwar" = "y" ]; then

  echogreen "Copy alfresco war file..."
  sudo cp $TMP_INSTALL/alfresco-content-services-community-distribution/alfresco.war $ALF_HOME/addons/war/alfresco.war
  echo

  # Add default alfresco and share modules classloader config files
  sudo cp $TMP_INSTALL/alfresco-content-services-community-distribution/alfresco.xml $CATALINA_HOME/conf/Catalina/localhost/alfresco.xml

  echogreen "Finished adding Alfresco Repository war file"
  echo
else
  echo
  echo "Skipping adding Alfresco Repository war file and addons"
  echo
fi

read -e -p "Add Share Client war file${ques} [y/n] " -i "$DEFAULTYESNO" installsharewar
if [ "$installsharewar" = "y" ]; then

  echogreen "Copy Share war file..."
  sudo cp $TMP_INSTALL/alfresco-content-services-community-distribution/share.war $ALF_HOME/addons/war/share.war

  # Add default alfresco and share modules classloader config files
  sudo cp $TMP_INSTALL/alfresco-content-services-community-distribution/share.xml $CATALINA_HOME/conf/Catalina/localhost/share.xml

  echo
  echogreen "Finished adding Share war file"
  echo
else
  echo
  echo "Skipping adding Alfresco Share war file"
  echo
fi

if [ "$installwar" = "y" ] || [ "$installsharewar" = "y" ]; then
cd /tmp/alfrescoinstall

if [ "$installwar" = "y" ]; then
    echored "You must install Share Services if you intend to use Share Client."
    read -e -p "Add Share Services plugin${ques} [y/n] " -i "$DEFAULTYESNO" installshareservices
    if [ "$installshareservices" = "y" ]; then
      echo "Copy Share Services addon..."
      sudo cp $TMP_INSTALL/alfresco-content-services-community-distribution/alfresco-share-services*.amp $ALF_HOME/addons/alfresco/
    fi
fi

read -e -p "Add Google docs integration${ques} [y/n] " -i "$DEFAULTYESNO" installgoogledocs
if [ "$installgoogledocs" = "y" ]; then
  echo "Downloading Google docs addon..."
  if [ "$installwar" = "y" ]; then
    curl -# -O $GOOGLEDOCSREPO
    sudo mv alfresco-googledocs-repo*.amp $ALF_HOME/addons/alfresco/
  fi
  if [ "$installsharewar" = "y" ]; then
    curl -# -O $GOOGLEDOCSSHARE
    sudo mv alfresco-googledocs-share* $ALF_HOME/addons/share/
  fi
fi
fi


echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Alfresco Office Services (Sharepoint protocol emulation)."
echo "This allows you to open and save Microsoft Office documents online."
echored "This module is not Open Source (Alfresco proprietary)."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Alfresco Office Services integration${ques} [y/n] " -i "$DEFAULTYESNO" installssharepoint
if [ "$installssharepoint" = "y" ]; then
    echogreen "Installing Alfresco Offices Services bundle..."
    echogreen "Downloading Alfresco Office Services amp file"
    # Sub shell to keep the file name
    (cd $ALF_HOME/addons/alfresco;sudo curl -# -O $AOS_AMP)
    echogreen "Copy _vti_bin.war into tomcat/webapps"
    sudo cp $TMP_INSTALL/alfresco-content-services-community-distribution/_vti_bin.war $ALF_HOME/tomcat/webapps/_vti_bin.war
    echogreen "Copy ROOT.war into tomcat/webapps"
    sudo cp $TMP_INSTALL/alfresco-content-services-community-distribution/ROOT.war $ALF_HOME/tomcat/webapps/ROOT.war
fi

# Install of war and addons complete, apply them to war file
if [ "$installwar" = "y" ] || [ "$installsharewar" = "y" ] || [ "$installssharepoint" = "y" ]; then
    # Check if Java is installed before trying to apply
    if type -p java; then
        _java=java
    elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
        _java="$JAVA_HOME/bin/java"
        echored "No JDK installed. When you have installed JDK, run "
        echored "$ALF_HOME/addons/apply.sh all"
        echored "to install addons with Alfresco or Share."
    fi
    if [[ "$_java" ]]; then
        sudo $ALF_HOME/addons/apply.sh all
    fi
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Solr6 Alfresco Search Services indexing engine."
echo "You can run Solr6 on a separate server, unless you plan to do that you should"
echo "install the Solr6 indexing engine on the same server as your repository server."
echored "Alfresco Serch Services will be installed without SSL!"
echored "Configure firewall to block port 8983 or install ssl, see"
echored "https://docs.alfresco.com/community/tasks/solr6-install.html"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Solr6 indexing engine${ques} [y/n] " -i "$DEFAULTYESNO" installsolr
if [ "$installsolr" = "y" ]; then

  # Make sure we have unzip available
  sudo yum $APTVERBOSITY install unzip

  echogreen "Downloading Solr6 file..."
  sudo curl -# -o $ALF_HOME/solr6.zip $ASS_DOWNLOAD
  echogreen "Expanding Solr6 file..."
  cd $ALF_HOME
  sudo unzip -q solr6.zip
  sudo mv alfresco-search-services solr6
  sudo rm solr6.zip

  echogreen "Downloading Solr6 scripts and settings file..."
  sudo curl -# -o /etc/systemd/system/alfresco-search.service -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/search/alfresco-search.service
  sudo curl -# -o $ALF_HOME/solr6/solrhome/conf/shared.properties -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/search/shared.properties
  sudo curl -# -o $ALF_HOME/solr6/solr.in.sh -u $GIT_USER:$GIT_PASSWORD $BASE_DOWNLOAD/search/solr.in.sh
  sudo chmod u+x $ALF_HOME/solr6/solr.in.sh
# Enable the service
    sudo systemctl enable alfresco-search.service
    sudo systemctl daemon-reload

  echo
  echogreen "Finished installing Solr6 engine."
  echored "Verify your setting in alfresco-global.properties."
  echo "Set property value index.subsystem.name=solr6"
  echo
else
  echo
  echo "Skipping installing Solr6."
  echo "You can always install Solr6 at a later time."
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Alfresco BART - Backup and Recovery Tool"
echo "Alfresco BART is a backup and recovery tool for Alfresco ECM. Is a shell script"
echo "tool based on Duplicity for Alfresco backups and restore from a local file system,"
echo "FTP, SCP or Amazon S3 of all its components: indexes, data base, content store "
echo "and all deployment and configuration files."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install B.A.R.T${ques} [y/n] " -i "$DEFAULTYESNO" installbart

if [ "$installbart" = "y" ]; then
 echogreen "Installing B.A.R.T"


 sudo mkdir -p $ALF_HOME/scripts/bart
 sudo mkdir -p $ALF_HOME/logs/bart
 sudo curl -# -o $TMP_INSTALL/$BART_PROPERTIES $BASE_BART_DOWNLOAD$BART_PROPERTIES
 sudo curl -# -o $TMP_INSTALL/$BART_EXECUTE $BASE_BART_DOWNLOAD$BART_EXECUTE

 # Update bart settings
 ALFHOMEESCAPED="${ALF_HOME//\//\\/}"
 BARTLOGPATH="$ALF_HOME/logs/bart"
 ALFBRTPATH="$ALF_HOME/scripts/bart"
 INDEXESDIR="\$\{ALF_DIRROOT\}/solr6"
 # Escape for sed
 BARTLOGPATH="${BARTLOGPATH//\//\\/}"
 ALFBRTPATH="${ALFBRTPATH//\//\\/}"
 INDEXESDIR="${INDEXESDIR//\//\\/}"

 sed -i "s/ALF_INSTALLATION_DIR\=.*/ALF_INSTALLATION_DIR\=$ALFHOMEESCAPED/g" $TMP_INSTALL/$BART_PROPERTIES
 sed -i "s/ALFBRT_LOG_DIR\=.*/ALFBRT_LOG_DIR\=$BARTLOGPATH/g" $TMP_INSTALL/$BART_PROPERTIES
 sed -i "s/INDEXES_DIR\=.*/INDEXES_DIR\=$INDEXESDIR/g" $TMP_INSTALL/$BART_PROPERTIES
 sudo cp $TMP_INSTALL/$BART_PROPERTIES $ALF_HOME/scripts/bart/$BART_PROPERTIES
 sed -i "s/ALFBRT_PATH\=.*/ALFBRT_PATH\=$ALFBRTPATH/g" $TMP_INSTALL/$BART_EXECUTE
 sudo cp $TMP_INSTALL/$BART_EXECUTE $ALF_HOME/scripts/bart/$BART_EXECUTE

 sudo chmod 700 $ALF_HOME/scripts/bart/$BART_PROPERTIES
 sudo chmod 774 $ALF_HOME/scripts/bart/$BART_EXECUTE

 # Install dependency
 sudo yum $APTVERBOSITY install duplicity;

 # Add to cron tab
 tmpfile=/tmp/crontab.tmp

 # read crontab and remove custom entries (usually not there since after a reboot
 # QNAP restores to default crontab: http://wiki.qnap.com/wiki/Add_items_to_crontab#Method_2:_autorun.sh
 sudo -u $ALF_USER crontab -l | grep -vi "alfresco-bart.sh" > $tmpfile

 # add custom entries to crontab
 echo "0 5 * * * $ALF_HOME/scripts/bart/$BART_EXECUTE backup" >> $tmpfile

 #load crontab from file
 sudo -u $ALF_USER crontab $tmpfile

 # remove temporary file
 rm $tmpfile

 # restart crontab
 sudo service cron restart

 echogreen "B.A.R.T Cron is installed to run in 5AM every day as the $ALF_USER user"

fi

# Finally, set the permissions
sudo chown -R $ALF_USER:$ALF_GROUP $ALF_HOME
if [ -d "$ALF_HOME/www" ]; then
   sudo chown -R www-data:root $ALF_HOME/www
fi

echo
echogreen "- - - - - - - - - - - - - - - - -"
echo "Scripted install complete"
echo
echored "Manual tasks remaining:"
echo
echo "1. Add database. Install scripts available in $ALF_HOME/scripts"
echored "   It is however recommended that you use a separate database server."
echo
echo "2. Verify Tomcat memory and locale settings in the file"
echo "   $ALF_HOME/alfresco-service.sh."

echo "   Alfresco runs best with lots of memory. Add some more to \"lots\" and you will be fine!"
echo "   Match the locale LC_ALL (or remove) setting to the one used in this script."
echo "   Locale setting is needed for LibreOffice date handling support."
echo
echo "3. Update database and other settings in alfresco-global.properties"
echo "   You will find this file in $CATALINA_HOME/shared/classes"
echored "   Really, do this. There are some settings there that you need to verify."
echo
echo "4. Update properties for BART (if installed) in $ALF_HOME/scripts/bart/alfresco-bart.properties"
echo "   DBNAME,DBUSER,DBPASS,DBHOST,REC_MYDBNAME,REC_MYUSER,REC_MYPASS,REC_MYHOST,DBTYPE "
echo
echo "5. Update cpu settings in $ALF_HOME/scripts/limitconvert.sh if you have more than 2 cores."
echo
echo "6. Start nginx if you have installed it: sudo service nginx start"
echo
echo "7. Start Alfresco/tomcat:"

echo "   sudo $ALF_HOME/alfresco-service.sh start"

echo

echo
echo "${warn}${bldblu} - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ${warn}"
echogreen "Thanks for using Alfresco Ubuntu installer by Loftux AB."
echogreen "Please visit https://loftux.com for more Alfresco Services and add-ons."
echogreen "You are welcome to contact us at info@loftux.se"
echo "${warn}${bldblu} - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ${warn}"
echo
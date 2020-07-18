#Reference:https://github.com/HA71/WhatCMS
#!/bin/sh
cmsapikey=
domainapikey=
#Get api key from https://whatcms.org/API/Plans?cmd=RegisterForm 
#Dual apikeys for dual requests to bypass 1 request per 10 seconds rule - https://whatcms.org/API/Plans

dnsapikey=
#Get api key from https://viewdns.info/api/#register

curl -s "https://www.who-hosts-this.com/APIEndpoint?key=$domainapikey&url="$1 > domain_raw
  	isp=$(cat domain_raw | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^isp_name/ {print $2}' | sed 's/\(^"\|"$\)//g' | sort | uniq | tr '\n' ' ')
	ip=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' domain_raw | sort | uniq | tr '\n' ' ')
	type=$(cat domain_raw | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^type/ {print $2}' | sed 's/\(^"\|"$\)//g' | sort | uniq | tr '\n' ' ')
	domain_error=$(cat domain_raw | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^msg/ {print $3}' | sed 's/\(^"\|"$\)//g' | sort | uniq | tr '\n' ' ')
	if [ -z "$isp" ]
	then
	echo ""
	echo -e " \e[1m[DOMAIN ERROR]: \e[1;36m$domain_error\e[0m"
	else
	echo ""
	echo -e " \e[1m[ISP]: \e[1;36m$isp\e[0m"
	echo ""
	echo -e " \e[1m[IP]: \e[1;36m$ip\e[0m"
	echo ""
	echo -e " \e[1m[TYPE] \e[1;36m$type\e[0m"
	fi

curl -s "https://whatcms.org/APIEndpoint?key=$cmsapikey&url="$1 > cms_raw
	cms=$(cat cms_raw | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^name/ {print $2}' | sed 's/\(^"\|"$\)//g')
    version=$(cat cms_raw | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^version/ {print $2}' | sed 's/\(^"\|"$\)//g')
    echo ""
    echo -e " \e[1m[URL]: \e[1;36m$1\e[0m"
    echo ""
    echo -e " \e[1m[CMS]: \e[1;92m$cms\e[0m"
    echo ""
    echo -e " \e[1m[VERSION]: \e[1;92m$version\e[0m"

curl -s "https://api.viewdns.info/reverseip/?apikey=$dnsapikey&output=json&host="$1 > rev_domains_raw
	no_rev_domains=$(cat rev_domains_raw | sed -e 's/[{}]/''/g' | grep -o '"name" : "[^"]*' | cut -d'"' -f4 | wc -l)
	echo ""
	if [[ $no_rev_domains -gt 1 ]]
	then
	echo -e " \e[1;92mAccording to Reverse IP results, it is a shared hosting and there are $no_rev_domains domains hosted on this server.\e[0m"
	echo ""
	read -p ">> Wanna see domains? (y or n) " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	echo ""
	rev_domains=$(cat rev_domains_raw | sed -e 's/[{}]/''/g' | grep -o '"name" : "[^"]*' | cut -d'"' -f4)
	echo -e " \e[1m[DOMAINS]: \e[1;36m\n\n$rev_domains\e\n[0m"
	fi	
	elif [[ $no_rev_domains -eq 0 ]]
	then
	echo -e " \e[1;92m- Host not found or input error. Enter active domain with valid format. [e.g. ./dnser.sh youtube.com]\e\n[0m"
	else
	echo -e " \e[1;92m- According to Reverse IP result, it is a dedicated hosting.\e\n[0m"
	fi
	
rm -f domain_raw
rm -f cms_raw
rm -f rev_domains_raw

#!/bin/bash

#Variables
GREEN='\033[0;32m'
NC='\033[0m'
domain=${!#}
without_suffix=`echo $domain | sed 's/\.[^.]*$//'`
crtsh_run=
amass_run=
githubsubdomains_run=
githubdorks_run=
github_keys=""
gospider_run=
wayback_run=
hakrawler_run=
massdns_run=
aquatone_run=
aquatone_ports="80,81,443,8000,8080,8081,8443,4443"
aquatone_extra_ports="80,81,82,443,2082,2083,2086,2087,2095,2096,3000,8000,8001,8008,8009,8080,8081,8083,8443,8834,8888,4443"
eyewitness_run=
eyewitness_ports="-p http:8080 -p http:8000 http:81 -p http:8081 -p https:4443 -p https:8443"
eyewitness_extra_ports="-p http:8080 -p http:8000 -p http:8001 -p http:3000 -p http:2082 -p https:2083 -p http:2086 -p https:2087 -p http:2095 -p https:2096 -p http:8888 -p http:81 -p http:82 -p http:8008 -p http:8088 -p http:8009 -p http:8081 -p http:8083 -p https:4443 -p https:8443"


now=$(date +"%m_%d_%Y_%H")
resultsDir="$HOME/docs/RECON/$domain/$now"

#start time
start=`date +%s`

#Options
usage() { echo -e "Usage: ./easyPeasy.sh [-x] [-d] [-c] [-o] [-g] [-s} [-w] [-k] [-m] [-e] [-E] [-a] [-A] domain.com\nOptions:\n  -x\t-  run github-dorks.py, crt.sh, subfinder, assetfinder, amass, github-subdomains.py and github-endpoints.py, gospider, waybackurls, massdns\n  -d\t-  run github-dorks.py using api keys\n  -c\t-  run crt.sh\n  -o\t-  run subfinder, assetfinder, amass enum\n  -g\t-  run github-subdomains.py and github-endpoints.py using api keys\n  -s\t-  run gospider(more results than hakrawler)\n  -w\t-  run waybackurls\n  -k\t-  run hakrawler\n  -m\t-  run massdns\n  -a\t-  run aquatone with small list (small list: 80,81,443,8000,8080,8081,8443,4443)\n  -A\t-  run aquatone with large list (large list: 80,81,82,443,2082,2083,2086,2087,2095,2096,3000,8000,8001,8008,8009,8080,8081,8083,8443,8834,8888,4443)\n  -e\t-  run httprobe and eyewitness with small list (small list: http:80 https:443 http:8080 http:8000 http:81 http:8081 https:4443 https:8443)\n  -E\t-  run httprobe and eyewitness with large list (large list: http:80 https:443 http:8080 http:8000 http:8001 http:3000 http:2082 https:2083 http:2086 https:2087 http:2095 https:2096 http:8083 http:8888 http:81 http:82 http:8008 http:8088 http:8009 http:8081 https:4443 https:8443)\n " 1>&2; exit 1; }

while getopts "dcogswkmaAeEx" o; do
    case "${o}" in
	d)
	    githubdorks_run=1
	    ;;
	c)
            crtsh_run=1
            ;;
    	o)
	    amass_run=1
	    ;;
	g)
	    githubsubdomains_run=1
	    ;;
	s)
	    gospider_run=1
	    ;;
	w)
	    wayback_run=1
	    ;;
	k)
	    hakrawler_run=1
	    ;;
	m)
	    massdns_run=1
	    ;;
    	a)
	    aquatone_run=1
	    #aquatone_ports=($OPTARG)
	    ;;
	A)
	    aquatone_run=1
	    aquatone_ports=$aquatone_extra_ports
	    ;;
    	e)
	    eyewitness_run=1
	    #eyewitness_ports=($OPTARG)
	    ;;
	E)
	    eyewitness_run=1
	    eyewitness_ports=$eyewitness_extra_ports
	    ;;
	x)
	    githubdorks_run=1
	    crtsh_run=1
	    amass_run=1
	    githubsubdomains_run=1
	    gospider_run=1
	    wayback_run=1
	    massdns_run=1
	    ;;
    	*)
            usage
            ;;
    esac
done

if [ $# = 0 ]
then
usage
fi

echo "                      _____                     "
echo "                     |  __ \                    "
echo "  ___  __ _ ___ _   _| |__) |__  __ _ ___ _   _ "
echo " / _ \/ _\` / __| | | |  ___/ _ \/ _\` / __| | | |"
echo "|  __/ (_| \__ \ |_| | |  |  __/ (_| \__ \ |_| |"
echo " \___|\__,_|___/\__, |_|   \___|\__,_|___/\__, |"
echo "                 __/ |                     __/ |"
echo "                |___/                     |___/ "
echo ""

mkdir -p $resultsDir
echo "Results will be saved to: $resultsDir"


#echo ""
#echo -e "${GREEN}************ Github Dork Links ***************${NC}"
#echo ""
#echo "  password"
#echo "https://github.com/search?q=%22$domain%22+password&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+password&type=Code&o=desc&s=indexed"
#echo ""
#echo " npmrc _auth"
#echo "https://github.com/search?q=%22$domain%22+npmrc%20_auth&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+npmrc%20_auth&type=Code&o=desc&s=indexed"
#echo ""
#echo " dockercfg"
#echo "https://github.com/search?q=%22$domain%22+dockercfg&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+dockercfg&type=Code&o=desc&s=indexed"
#echo ""
#echo " pem private"
#echo "https://github.com/search?q=%22$domain%22+pem%20private&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+extension:pem%20private&type=Code&o=desc&s=indexed"
#echo ""
#echo "  id_rsa"
#echo "https://github.com/search?q=%22$domain%22+id_rsa&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+id_rsa&type=Code&o=desc&s=indexed"
#echo ""
#echo "  security_credentials"
#echo "https://github.com/search?q=%22$domain%22+security_credentials&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+security_credentials&type=Code&o=desc&s=indexed"
#echo ""
#echo " connectionstring"
#echo "https://github.com/search?q=%22$domain%22+connectionstring&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+connectionstring&type=Code&o=desc&s=indexed"
#echo ""
#echo " JDBC"
#echo "https://github.com/search?q=%22$domain%22+JDBC&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+JDBC&type=Code&o=desc&s=indexed"
#echo ""
#echo " ssh2_auth_password"
#echo "https://github.com/search?q=%22$domain%22+ssh2_auth_password&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+ssh2_auth_password&type=Code&o=desc&s=indexed"
#echo ""
#echo "  send_keys"
#echo "https://github.com/search?q=%22$domain%22+send_keys&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+send_keys&type=Code&o=desc&s=indexed"
#echo ""
#echo " aws_access_key_id"
#echo "https://github.com/search?q=%22$domain%22+aws_access_key_id&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+aws_access_key_id&type=Code&o=desc&s=indexed"
#echo ""
#echo " s3cfg"
#echo "https://github.com/search?q=%22$domain%22+s3cfg&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+s3cfg&type=Code&o=desc&s=indexed"
#echo ""
#echo " htpasswd"
#echo "https://github.com/search?q=%22$domain%22+htpasswd&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+htpasswd&type=Code&o=desc&s=indexed"
#echo ""
#echo " git-credentials"
#echo "https://github.com/search?q=%22$domain%22+git-credentials&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+git-credentials&type=Code&o=desc&s=indexed"
#echo ""
#echo " bashrc password"
#echo "https://github.com/search?q=%22$domain%22+bashrc%20password&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+bashrc%20password&type=Code&o=desc&s=indexed"
#echo ""
#echo " sshd_config"
#echo "https://github.com/search?q=%22$domain%22+sshd_config&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+sshd_config&type=Code&o=desc&s=indexed"
#echo ""
#echo " xoxp OR xoxb OR xoxa"
#echo "https://github.com/search?q=%22$domain%22+xoxp%20OR%20xoxb%20OR%20xoxa&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+xoxp%20OR%20xoxb%20OR%20xoxa&type=Code&o=desc&s=indexed"
#echo ""
#echo " SECRET_KEY"
#echo "https://github.com/search?q=%22$domain%22+SECRET_KEY&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+SECRET_KEY&type=Code&o=desc&s=indexed"
#echo ""
#echo " client_secret"
#echo "https://github.com/search?q=%22$domain%22+client_secret&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+client_secret&type=Code&o=desc&s=indexed"
#echo ""
#echo " sshd_config"
#echo "https://github.com/search?q=%22$domain%22+sshd_config&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+sshd_config&type=Code&o=desc&s=indexed"
#echo ""
#echo " github_token"
#echo "https://github.com/search?q=%22$domain%22+github_token&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+github_token&type=Code&o=desc&s=indexed"
#echo ""
#echo " api_key"
#echo "https://github.com/search?q=%22$domain%22+api_key&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+api_key&type=Code&o=desc&s=indexed"
#echo ""
#echo " FTP"
#echo "https://github.com/search?q=%22$domain%22+FTP&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+FTP&type=Code&o=desc&s=indexed"
#echo ""
#echo " app_secret"
#echo "https://github.com/search?q=%22$domain%22+app_secret&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+app_secret&type=Code&o=desc&s=indexed"
#echo ""
#echo "  passwd"
#echo "https://github.com/search?q=%22$domain%22+passwd&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+passwd&type=Code&o=desc&s=indexed"
#echo ""
#echo " s3.yml"
#echo "https://github.com/search?q=%22$domain%22+.env&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+.env&type=Code&o=desc&s=indexed"
#echo ""
#echo " .exs"
#echo "https://github.com/search?q=%22$domain%22+.exs&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+.exs&type=Code&o=desc&s=indexed"
#echo ""
#echo " beanstalkd.yml"
#echo "https://github.com/search?q=%22$domain%22+beanstalkd.yml&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+beanstalkd.yml&type=Code&o=desc&s=indexed"
#echo ""
#echo " deploy.rake"
#echo "https://github.com/search?q=%22$domain%22+deploy.rake&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+deploy.rake&type=Code&o=desc&s=indexed"
#echo ""
#echo " mysql"
#echo "https://github.com/search?q=%22$domain%22+mysql&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+mysql&type=Code&o=desc&s=indexed"
#echo ""
#echo " credentials"
#echo "https://github.com/search?q=%22$domain%22+credentials&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+credentials&type=Code&o=desc&s=indexed"
#echo ""
#echo " PWD"
#echo "https://github.com/search?q=%22$domain%22+PWD&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+PWD&type=Code&o=desc&s=indexed"
#echo ""
#echo " deploy.rake"
#echo "https://github.com/search?q=%22$domain%22+deploy.rake&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+deploy.rake&type=Code&o=desc&s=indexed"
#echo ""
#echo " .bash_history"
#echo "https://github.com/search?q=%22$domain%22+.bash_history&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+.bash_history&type=Code&o=desc&s=indexed"
#echo ""
#echo " .sls"
#echo "https://github.com/search?q=%22$domain%22+.sls&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+PWD&type=Code&o=desc&s=indexed"
#echo ""
#echo " secrets"
#echo "https://github.com/search?q=%22$domain%22+secrets&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+secrets&type=Code&o=desc&s=indexed"
#echo ""
#echo " composer.json"
#echo "https://github.com/search?q=%22$domain%22+composer.json&type=Code&o=desc&s=indexed"
#echo "https://github.com/search?q=%22$without_suffix%22+composer.json&type=Code&o=desc&s=indexed"
#echo ""


#github-dorks
if [[ $githubdorks_run = 1 ]]
then
	echo -e "${GREEN}Github-Dorks Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"
	
	echo -e $github_keys > $HOME/tools/github-search/.tokens
	python3 $HOME/tools/github-search/github-dorks.py -o $domain -d $HOME/tools/github-search/dorks.txt | grep -v '(0)' | tee -a $resultsDir/github-dorks.txt
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}Github-Dorks Finished.${NC}"
	echo ""

else
	echo -e "${GREEN}Github-Dorks Skipped${NC}"
	echo ""
fi


#TO DO TEST/IMPLEMENT GITDORKER !!!!!!


#CRT.SH (sub)
if [[ $crtsh_run = 1 ]]
then
	echo -e "${GREEN}CRT.SH Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"

	crtsh -q $domain -o | sort -u | tee -a $resultsDir/domains2.txt $resultsDir/temp_crtsh.txt
	linii=$(cat $resultsDir/temp_crtsh.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp_crtsh.txt $resultsDir/crtsh.linii$linii.txt
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}CRT.SH Finished.${NC}"
	echo ""

else
	echo -e "${GREEN}CRT.SH Skipped${NC}"
	echo ""
fi

#Amass/Subfinder/Assetfinder (sub+ip)
if [[ $amass_run -eq 1 ]] 
then
	echo -e "${GREEN}Subfinder Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"
	
	#IPs
	subfinder -d $domain -nW -oI -o $resultsDir/temp_ips_subfinder.txt > /dev/null
       	cat $resultsDir/temp_ips_subfinder.txt | cut -d "," -f 2 | sed 's/\(\([^,]\+,\)\{1\}\)/\1\n/g;s/,\n/\n/g' | sort -u | tee -a $resultsDir/temp2_ips_subfinder.txt $resultsDir/ips2.txt > /dev/null
	linii=$(cat $resultsDir/temp2_ips_subfinder.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp2_ips_subfinder.txt $resultsDir/subfinder.ips.linii$linii.txt
	rm $resultsDir/temp_ips_subfinder.txt
	
	#Subdomains
	sleep 10
	subfinder -d $domain | tee -a $resultsDir/domains2.txt $resultsDir/temp_subfinder.txt
	linii=$(cat $resultsDir/temp_subfinder.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp_subfinder.txt $resultsDir/subfinder.linii$linii.txt
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}Subfinder Finished${NC}"
	echo ""
	echo -e "${GREEN}Assetfinder Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"

	assetfinder --subs-only $domain | sort -u | tee -a $resultsDir/domains2.txt $resultsDir/temp_assetfinder.txt
	linii=$(cat $resultsDir/temp_assetfinder.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp_assetfinder.txt $resultsDir/assetfinder.linii$linii.txt
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}Assetfinder Finished${NC}"
	echo ""
	echo -e "${GREEN}AMASS Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"
	
	amass enum -ip -d $domain | tee -a $resultsDir/temp_amass.txt
	cat $resultsDir/temp_amass.txt | cut -d " " -f 1 | tee -a $resultsDir/domains2.txt $resultsDir/temp_dns_amass.txt
	linii=$(cat $resultsDir/temp_dns_amass.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp_dns_amass.txt $resultsDir/amass.domains.linii$linii.txt
	cat $resultsDir/temp_amass.txt | cut -d " " -f 2 | sed 's/\(\([^,]\+,\)\{1\}\)/\1\n/g;s/,\n/\n/g' | sort -u | tee -a $resultsDir/temp_ips_amass.txt $resultsDir/ips2.txt
	linii=$(cat $resultsDir/temp_ips_amass.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp_ips_amass.txt $resultsDir/amass.ips.linii$linii.txt
	rm $resultsDir/temp_amass.txt
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}AMASS Finished${NC}"
	echo ""

else
	echo -e "${GREEN}AMASS/Subfinder/Assetfinder Skipped${NC}"
	echo ""
fi

#TO DO implement SonarSearch !!!!!!!

#Github-Search (sub+url)
if [[ $githubsubdomains_run -eq 1 ]]
then
	echo -e "${GREEN}Github-Search Started (Endpoints+Subdomains)${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"
	
	sleep 10
	#urls
	python3 $HOME/tools/github-search/github-endpoints.py -d $domain -s | tee -a $resultsDir/github_endpoints.txt | grep -v '>>>' | grep . | tee -a $resultsDir/urls2.txt > /dev/null
	sleep 10
	#subdomains
	python3 $HOME/tools/github-search/github-subdomains.py -d $domain | grep . | tee -a $resultsDir/domains2.txt $resultsDir/temp_github-subdomains.txt
	linii=$(cat $resultsDir/temp_github-subdomains.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp_github-subdomains.txt $resultsDir/github-subdomains.linii$linii.txt
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}Github-Search Finished${NC}"
	echo ""
else
	echo -e "${GREEN}Github-Search Skipped${NC}"
	echo ""
fi

#GoSpider (sub+url)
if [[ $gospider_run = 1 ]]
then
	echo -e "${GREEN}GoSpider Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"
	
	gospider -s https://$domain -q -t 4 -c 10 -d 3 --other-source --include-subs | tee $resultsDir/temp_gospider.txt > /dev/null
	cat $resultsDir/temp_gospider.txt | sort -u | tee -a $resultsDir/gospider_urls.txt | grep $domain | sort -u | tee -a $resultsDir/urls2.txt > /dev/null
	cat $resultsDir/temp_gospider.txt | grep $domain | unfurl domain | sort -u | tee -a $resultsDir/domains2.txt $resultsDir/temp_gospiderdomains.txt
	linii=$(cat $resultsDir/temp_gospiderdomains.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp_gospiderdomains.txt $resultsDir/gospider.linii$linii.txt
	rm $resultsDir/temp_gospider.txt
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}GoSpider Finished.${NC}"
	echo ""

else
	echo -e "${GREEN}GoSpider Skipped${NC}"
	echo ""
fi

#Waybackurls (sub+url)
if [[ $wayback_run = 1 ]]
then
	echo -e "${GREEN}Waybackurls Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"
	
	echo $domain | waybackurls | tee -a $resultsDir/urls2.txt $resultsDir/wayback_urls.txt | unfurl domains | sort -u | tee -a $resultsDir/domains2.txt $resultsDir/temp_wayback.txt
	linii=$(cat $resultsDir/temp_wayback.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp_wayback.txt $resultsDir/wayback.linii$linii.txt
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}Waybackurls Finished.${NC}"
	echo ""

else
	echo -e "${GREEN}Waybackurls Skipped${NC}"
	echo ""
fi

#Hakrawler (sub+url)
if [[ $hakrawler_run -eq 1 ]]
then
	echo -e "${GREEN}HAKRWALER Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"

	hakrawler -linkfinder -depth 3 -plain -url $domain | tee -a $resultsDir/hakrawler_urls.txt $resultsDir/urls2.txt | unfurl domains | grep $domain | sort -u | tee -a $resultsDir/domains2.txt $resultsDir/temp_hakrawler.txt
	linii=$(cat $resultsDir/temp_hakrawler.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp_hakrawler.txt $resultsDir/hakrawler.linii$linii.txt
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}HAKRAWLER Finished${NC}"
	echo ""
else
	echo -e "${GREEN}HAKRAWLER Skipped${NC}"
	echo ""
fi

#wait for all to finish, including background scripts
wait

#Massdns (sub)
if [[ $massdns_run -eq 1 ]]
then
	echo -e "${GREEN}MASSDNS Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"

	#create wordlist for bruteforce
	cp $HOME/docs/mylists/dns/all.txt $resultsDir/temp_all$domain.txt
	sed -e 's/$/.'$domain'/' -i $resultsDir/temp_all$domain.txt
	echo -e "${GREEN}This should take about 25 minutes${NC}"
	$HOME/tools/massdns/bin/massdns -r $HOME/docs/mylists/dns/resolvers_curated.txt -t A -o S $resultsDir/temp_all$domain.txt --hashmap-size 550 -q -w $resultsDir/temp_results1.txt
	cat $resultsDir/temp_results1.txt | cut -d " " -f 1 | sed 's/.$//' > $resultsDir/temp_massdns.txt
	$HOME/tools/massdns/bin/massdns -r $HOME/docs/mylists/dns/saferesolver.txt -t A -o S $resultsDir/temp_massdns.txt --hashmap-size 70 -q -w $resultsDir/temp_results2.txt
	linii=$(cat $resultsDir/temp_results2.txt | sort -u | uniq -u | wc -l)
	cat $resultsDir/temp_results2.txt | cut -d " " -f 1 | sed 's/.$//' | tee -a $resultsDir/domains2.txt $resultsDir/massdns.linii$linii.txt
	#remove temp files
	rm $resultsDir/temp_all$domain.txt
	rm $resultsDir/temp_results1.txt
	rm $resultsDir/temp_results2.txt
	rm $resultsDir/temp_massdns.txt

	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}MASSDNS Finished${NC}"
	echo ""
else
	echo -e "${GREEN}MASSDNS Skipped${NC}"
	echo ""
fi

#Create output file with all subdomains (BEFORE SSLSCRAPE)
linii=$(cat $resultsDir/domains2.txt | sort -u | uniq -u | wc -l)
cat $resultsDir/domains2.txt | grep . | sort -u | uniq -u > $resultsDir/allsubdomains.$domain.linii$linii.txt
rm $resultsDir/domains2.txt


#Create output file with all IPs
while read dnsname
do
	dig +short $dnsname | grep -v '\.$' | tee -a $resultsDir/temp_dig_ips.txt $resultsDir/ips2.txt > /dev/null
done < $resultsDir/allsubdomains.$domain.linii$linii.txt
linii_2=$(cat $resultsDir/temp_dig_ips.txt | sort -u | uniq -u | wc -l)
mv $resultsDir/temp_dig_ips.txt $resultsDir/dig_ips.$domain.linii$linii_2.txt

linii_2=$(cat $resultsDir/ips2.txt | sort -u | uniq -u | wc -l)
cat $resultsDir/ips2.txt | grep . | sort -u | uniq -u > $resultsDir/all_ips.$domain.linii$linii_2.txt
rm $resultsDir/ips2.txt

#TO DO Create output file with all subdomains (AFTER SSLSCRAPE) !!!!!!

#Create output file with all urls
linii_3=$(cat $resultsDir/urls2.txt | sort -u | uniq -u | wc -l)
cat $resultsDir/urls2.txt | grep . | sort -u | uniq -u > $resultsDir/all_urls.$domain.linii$linii_3.txt
rm $resultsDir/urls2.txt

#Valid Subdomains output file
echo -e "${GREEN}Generating file with Valid Subdomains${NC}"
echo ""
while read i; do digout=$(dig +short ${i//[$'\t\r\n ']}); if [[ ! -z $digout ]]; then echo ${i//[$'\t\r\n ']}; fi; done < $resultsDir/allsubdomains.$domain.linii$linii.txt > $resultsDir/allsubdomains_valid_temp.txt
linii_valid=$(cat $resultsDir/allsubdomains_valid_temp.txt | sort -u | uniq -u | wc -l)
mv $resultsDir/allsubdomains_valid_temp.txt $resultsDir/allsubdomains_valid.$domain.linii$linii_valid.txt

#httprobe and Eyewitness
if [[ "$eyewitness_run" -eq 1 ]]
then
	echo -e "${GREEN}httprobe Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"

	cat $resultsDir/allsubdomains.$domain.linii$linii.txt | httprobe -t 15000 -c 300 $eyewitness_ports > $resultsDir/temp_httprobes.txt
	linii=$(cat $resultsDir/temp_httprobes.txt | sort -u | uniq -u | wc -l)
	mv $resultsDir/temp_httprobes.txt $resultsDir/httprobes.$domain.linii$linii.txt
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}httprobe Finished"
	echo ""
	echo -e "${GREEN}Eyewitness Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"

	cd $resultsDir
	eyewitness --timeout 35 --results 40 --no-prompt -f $resultsDir/httprobes.$domain.linii$linii.txt | sed '1d'
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}Eyewitness Finished${NC}"
	echo ""
else
	echo -e "${GREEN}Eyewitness Skipped${NC}"
	echo ""
fi

#Aquatone
if [[ "$aquatone_run" -eq 1 ]]
then
	echo -e "${GREEN}Aquatone Started${NC}"
	
	#command start time
	comm_start=`date +%s`
	echo "Start time: `date +"%H:%M"`"

	cd $resultsDir
	cat $resultsDir/allsubdomains.$domain.linii$linii.txt | aquatone -scan-timeout 2500 -http-timeout 15000 -screenshot-timeout 35000 -threads 15 -ports $aquatone_ports -out aquatone_$now
	
	#end time
	comm_end=`date +%s`
	comm_runtime=`expr $((comm_end-comm_start)) / 60`
	echo "Execution time: $comm_runtime minutes"

	echo -e "${GREEN}Aquatone Finished${NC}"
	echo ""

else
	echo -e "${GREEN}Aquatone Skipped${NC}"
	echo ""
fi

#end time
end=`date +%s`
runtime=`expr $((end-start)) / 60`

python3 $HOME/tools/telegram-bot-cli/telegram-bot-cli.py -j "easyPeasy" -d "Dom:$domain;Time:$runtime;Sub:$linii;IP:$linii2"

echo -e "${GREEN}Total execution time: $runtime minutes${NC}"
echo ""
echo -e "${GREEN}Results are located in $resultsDir ${NC}"
echo ""
echo -e "${GREEN}Finished RECON for domain $domain ${NC}"

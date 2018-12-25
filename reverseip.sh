#!/bin/bash

yougetsignal(){
	web="$1"
	printf "    YouGetSignal... "
	curl=$(curl -s -F "remoteAddress=$web" "https://domains.yougetsignal.com/domains.php")
	if [[ $curl =~ "status\":\"Success" ]]; then
		domain=$(echo $curl | grep -Po '\["\K.*?(?=",)')
		echo "$domain" >> result.tmp
		total=$(echo $curl | grep -Po '(?<=domainCount":")[^",]*')
		printf "$total Domains\n"
	elif [[ $curl =~ "Service unavailable" ]]; then
		curl2=$(curl -s -F "remoteAddress=$web" "https://domains.yougetsignal.com/domains.php")
		if [[ $curl2 =~ "status\":\"Success" ]]; then
			domain2=$(echo $curl2 | grep -Po '\["\K.*?(?=",)')
			echo "$domain2" >> result.tmp
			total2=$(echo $curl2 | grep -Po '(?<=domainCount":")[^",]*')
			printf "$total2 Domains\n"
		else
			printf "\n"
		fi		
	elif [[ $curl =~ "check limit reached" ]]; then
		printf "[LIMIT]\n"
	else

	fi
}
viewdns(){
	web="$1"
	i=0;
	for ResWeb in $(curl -s "https://viewdns.info/reverseip/?host=$web&t=1" | grep -Po '(?<=<td>)[[:alnum:]_.-]+?\.[[:alpha:].]{2,10}[^</td]*');
	do
		((i++))
		echo "$ResWeb" >> result.tmp
	done
	printf "$i Domains\n"
}
hackertarget() {
	web="$1"
	i=0;
	for SITE in $(curl -s -d "theinput=$web&thetest=reverseiplookup&name_of_nonce_field=d210302267&_wp_http_referer=%2Freverse-ip-lookup%2F" "https://hackertarget.com/reverse-ip-lookup/" | sed -n -e '/<pre id="formResponse">/,/<\/pre>/p' | grep -Po '([[:alnum:]_.-]+?\.){1,5}[[:alpha:].]{2,10}')
	do
		((i++))
		echo "${SITE}" >> result.tmp
	done
	printf "$i Domains\n"
}


if [[ -z $1 ]]; then
	printf "\nMANA TARGETNYA GOBLOK!1!1!\n\n"
	exit 1;
fi

sed -i 's/\r//' $1

IFS=$'\r\n' GLOBIGNORE='*' command eval  'target=($(cat $1))'
for (( i = 0; i <"${#target[@]}"; i++ )); do
	korban=$(echo "${target[$i]}" | grep -Po '([[:alnum:]_.-]+?\.){1,5}[[:alpha:].]{2,10}')

	printf "[!] $korban\n"
	yougetsignal $korban;
	hackertarget $korban;
	viewdns $korban;
done
wait
printf "\n[!] Filtering Result... "
cat result.tmp | sort -u | uniq >> result.txt
printf "[!] Total : $(cat result.txt | wc -l) Domains\n\n"
#!/bin/bash

g='\e[1;32m'
r="tput sgr0"

echo -e "${g} _                                              "; $r
echo -e "${g}|_)  _.        ._ _  o ._   _  ._    |_   _ _|_ "; $r
echo -e "${g}|_) (_| \/ |_| | | | | | | (/_ |  __ |_) (_) |_ "; $r
echo -e "${g}        /                                       "; $r

MSG_FILE="bayuM.msg"
JSON_FILE="bayuM.json"
echo -e "Wallet Monitoring~ \nCurrency\t: XMR" > $MSG_FILE
WEB="http://api.zergpool.com:8080/api/walletEx?address={s3cretToken}"

#json init
echo -e "${g}Json initialization"; $r
json_init=$(curl -s "$WEB" | jq -r '.')
echo -e "$json_init" > $JSON_FILE
echo -e "${g}===================="; $r

#wrapp
unsold=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"unsold": ')
balance=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"balance": ')
unpaid=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"unpaid": ')
paid24h=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"paid24h": ')
minpay=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"minpay": ')
minpay_sunday=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"minpay_sunday": ')
total=$(cat "$JSON_FILE" | awk -F, 'NR>1{print $1}' RS='"total": ')
eimi=$(cat "$JSON_FILE" | jq -r ' .miners[] | "ID: " + (.ID + " | Hashrate: " + .hashrate)')

#print
echo -e "${g}Generate report.."; $r
echo -e "Immature\t: "$unsold " XMR" >> $MSG_FILE
echo -e "Balance\t: "$balance " XMR" >> $MSG_FILE
echo -e "Unpaid\t\t: "$unpaid " XMR" >> $MSG_FILE
echo -e "Paid 24 Hours\t: "$paid24h " XMR" >> $MSG_FILE
echo -e "Paid/4jam\t: "$minpay >> $MSG_FILE
echo -e "Sunday\t\t: "$minpay_sunday >> $MSG_FILE
echo -e "Total\t\t: "$total " XMR" >> $MSG_FILE
echo -e "Accepted\t: "$eimi >> $MSG_FILE
sed -i "s/ID: /\n\t\tID: /g" $MSG_FILE
echo -e "${g}===================="; $r

if [ -z "$total" ]
then
    #fail
    echo -e "${g}FAIL.. try again."; $r
else
    #send tele
    echo -e "${g}Sending report.."; $r
    TOKEN={s3cret_token}
    CHAT_ID=({s3cret_id})
    MESSAGE=`cat $MSG_FILE`
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    for ID in "${CHAT_ID[@]}"
    do
        curl -X POST -so /dev/null $URL -d chat_id=$ID -d text="$MESSAGE";
        echo -e "${g}===================="; $r
        echo -e "${g}SUCCESS.. DONE."; $r
    done
fi
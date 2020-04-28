#!/bin/sh

timestamp()
{
	date +"%Y-%m-%d %T"
}

# Human Readable Output
free --mega | grep Mem | awk '{printf "%.2f ", $(NF-4)*100/$(NF-5)}'
free --mega | grep Mem | awk '{printf "%2.0f ", $(NF-4)}'
free --mega | grep Mem | awk '{printf "%2.0f ", $(NF-5)}'
df -h | grep rootfs | awk '{printf "%.2f ", $(NF-2)/$(NF-3)}'
top -bn1 | grep load | awk '{printf "%.2f\n", $(NF-2)}'
vnstat --oneline | cut -d ';' -f4 | awk '{printf "%.2f\n", $(NF-1)}' # today's received
vnstat --oneline | cut -d ';' -f5 | awk '{printf "%.2f\n", $(NF-1)}' # today's transmitted

printf "$(timestamp) " >> log.txt

# These just output the RAM (in percent), Free Disk Space (in percent),and CPU Load (Lord help me this shit is weird) and outputs it to a file for us to refer to later
free --mega | grep Mem | awk '{printf "%.2f ", $(NF-4)*100/$(NF-5)}' >> log.txt
free --mega | grep Mem | awk '{printf "%2.0f ", $(NF-4)}' >> log.txt
free --mega | grep Mem | awk '{printf "%2.0f ", $(NF-5)}' >> log.txt
df -h | grep rootfs | awk '{printf "%.2f ", $(NF-2)/$(NF-3)}' >> log.txt
top -bn1 | grep load | awk '{printf "%.2f\n", $(NF-2)}' >> log.txt
vnstat --oneline | cut -d ';' -f4 | awk '{printf "%.2f\n", $(NF-1)}' >> log.txt # today's received
vnstat --oneline | cut -d ';' -f5 | awk '{printf "%.2f\n", $(NF-1)}' >> log.txt # today's transmitted

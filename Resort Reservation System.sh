#!/bin/bash
L="ledger.txt"
TH="theater.txt"
max=10

if [ ! -f $L ]; then
    touch $L
fi
if [ ! -f $TH ]; then
    touch $TH
fi

menu() {
    echo "Private Family Resort Reservation System"
    echo "        _    .  ,   .           ."
    echo "    *  / \_ *  / \_      _  *         *   /\'__        *"
    echo "      /    \  /    \,   ((        .     _/  /  \  *'."
    echo "  *  /\/\  /\/ :' __ \_  \`          _/\/   /    \`--."
    echo "    /    \/  \  _/  \-'\      *    /.'  '_   \_   .'\  *"
    echo "   /\  .-   \`. \/     \ /==~=-=~=-=-;  _/ \ -. \`_/   \ "
    echo "  /  \`-.__ ^   / .-'.--\ =-=~_=-=~=^/    _ \`--./ .-'  \`-"
    echo " /        \`.  / /       \`.~-^=-=~=^=.-'        '-._ \`.__"
    echo "                []_____             []_____"
    echo "               /\      \           /\      \ "
    echo "           ___/  \__/\__\__     __/  \__/\__\__ "
    echo "       ---/\___\ |''''''|__\  /\___\ |''''''|__\-- --- "
    echo "          ||'''| |''||''|''|  ||'''| |''||''|''|  "
    echo "          \`\`\"\"'\"'\"\"''\"\"'\"\" \`  \`\`\`\`\"\"\`\"\"''\"\"'\"\"''     \" \""
    echo "  __        __   _                            _         "
    echo "  \ \      / /__| | ___ ___  _ __ ___   ___  | |_ ___   "
    echo "   \ \ /\ / / _ \ |/ __/ _ \| '_ \` _ \ / _ \ | __/ _ \  "
    echo "    \ V  V /  __/ | (_| (_) | | | | | |  __/ | || (_) | "
    echo "     \_/\_/ \___|_|\___\___/|_| |_| |_|\___|  \__\___/  "
    echo "                | | | | ___ | |_ ___| |                 "
    echo "                | |_| |/ _ \| __/ _ \ |                 "
    echo "                |  _  | (_) | ||  __/ |                 "
    echo "            ____|_| |_|\___/ \__\___|_|      _          "
    echo "           / ___|___| | ___  ___| |_(_) __ _| |         "
    echo "          | |   / _ \ |/ _ \/ __| __| |/ _\` | |         "
    echo "          | |__|  __/ |  __/\__ \ |_| | (_| | |         "
    echo "           \____\___|_|\___||___/\__|_|\__,_|_| "
    echo "                                                      "
    echo "							"
    echo "1. Make a Reservation"
    echo "2. See the Vacancy"
    echo "3. Cancel Reservation"
    echo "4. Book Theater Service"
    echo "5. Show Theater Availability"
    echo "6. Exit"
}

sort_l() {
    sort -t, -k5,5 $L -o $L
}

sort_th() {
    sort -t, -k5,5 -k4,4nr $TH -o $TH
}

conv_date() {
    local date=$1
    echo $(date -d "$(echo $date | awk -F- '{print $3"-"$2"-"$1}')" +%Y-%m-%d)
}

reserve() {
    echo "Enter your name:"
    read name
    echo "Enter your NID:"
    read nid
    echo "Enter number of room (max capacity 2 person):"
    read room
    echo "Enter check-in date (dd-mm-yy):"
    read c_in
    echo "Enter check-out date (dd-mm-yy):"
    read c_out

    c_in_conv=$(conv_date $c_in)
    c_out_conv=$(conv_date $c_out)

    ch_vac $room $c_in_conv $c_out_conv
    if [ $? -ne 0 ]; then
        echo "Sorry, not enough vacancy for those days."
        return
    fi

    vip=$(awk -F, -v nid="$nid" '$2 == nid {print $6}' $L | tail -n 1)
    if [ -z "$vip" ]; then
        vip=1
    else
        vip=$((vip + 1))
    fi

    discount=0
    case $vip in
        2) discount=5 ;;
        3) discount=10 ;;
        4) discount=20 ;;
        *) [ $vip -gt 4 ] && discount=30 ;;
    esac

    days=$(( ( $(date -d $c_out_conv +%s) - $(date -d $c_in_conv +%s) ) / 86400 ))
    total=$(( room * days * 8000 ))
    discounted_total=$(( total * (100 - discount) / 100 ))

    echo "Receipt:"
    echo "Name: $name"
    echo "NID: $nid"
    echo "Check-in: $c_in"
    echo "Check-out: $c_out"
    echo "room: $room"
    echo "Total Amount: $total Tk"
    echo "Discount: $discount%"
    echo "Amount after Discount: $discounted_total Tk"

    echo "Confirm reservation? (yes/no)"
    read confirm
    if [ "$confirm" = "yes" ]; then
        date=$c_in_conv
        while [ "$date" != "$c_out_conv" ]; do
            echo "$name,$nid,$room,$c_in,$date,$vip" >> $L
            date=$(date -I -d "$date + 1 day")
        done
        sort_l
        echo "Reservation confirmed."
    else
        echo "Reservation cancelled."
    fi
}

ch_vac() {
    local r=$1
    local s_date=$2
    local e_date=$3

    local date=$s_date
    while [ "$date" != "$e_date" ]; do
        booked=$(awk -F, -v date="$date" '$5 == date {sum += $3} END {print sum}' $L)
        available=$(( max - booked ))
        if [ $available -lt $r ]; then
            return 1
        fi
        date=$(date -I -d "$date + 1 day")
    done
    return 0
}

see_vac() {
    local today=$(date -I)
    local next_month=$(date -I -d "$today + 1 month")
    
    echo "Vacancy for the next month:"
    local date=$today
    while [ "$date" != "$next_month" ]; do
        booked=$(awk -F, -v date="$date" '$5 == date {sum += $3} END {print sum}' $L)
        available=$(( max - booked ))
        if [ $available -le 0 ]; then
            status="Fully booked"
        else
            status="$available rooms available"
        fi
        echo "$(date -d "$date" +%d-%m-%y): $status"
        date=$(date -I -d "$date + 1 day")
    done
}

cancel() {
    echo "Enter your NID:"
    read nid

    l_reserve=$(awk -F, -v nid="$nid" '$2 == nid {print $0}' $L | tail -n 1)

    if [ -z "$l_reserve" ]; then
        echo "No reservation found for NID: $nid"
        return
    fi

    IFS=',' read -r name nid room c_in conv_date vip <<< "$l_reserve"

    awk -F, -v nid="$nid" -v c_in="$c_in" '$2 != nid || $4 != c_in' $L > $L.tmp && mv $L.tmp $L
    echo "Reservation cancelled."
}

book_th() {
    echo "Enter your NID:"
    read nid

    if ! grep -q ",$nid," $L; then
        echo "No reservation found for NID: $nid"
        return
    fi

    echo "Choose a theater slot:"
    echo "1. Evening (3:00 PM - 7:00 PM)"
    echo "2. Night (8:00 PM - 12:00 AM)"
    read slt

    case $slt in
        1) slot="Evening";;
        2) slot="Night";;
        *) echo "Invalid slot option."; return;;
    esac

    echo "Enter the date for theater service (dd-mm-yy):"
    read th_date

    th_date_conv=$(conv_date $th_date)

    l_reserve=$(awk -F, -v nid="$nid" '$2 == nid {print $0}' $L | tail -n 1)
    IFS=',' read -r name nid room c_in conv_date vip <<< "$l_reserve"

    res_th "$name" "$nid" "$vip" "$slot" "$th_date_conv"
    echo "Theater service booked for $slot on $th_date."
}

res_th() {
    local name=$1
    local nid=$2
    local vip=$3
    local slot=$4
    local th_date=$5

    fin_book_th=$(awk -F, -v date="$th_date" -v slot="$slot" '$4 == slot && $5 == date {print $0}' $TH)

    if [ -n "$fin_book_th" ]; then
        IFS=',' read -r e_name e_nid e_vip e_slot fin_book_th_date <<< "$fin_book_th"

        if [ $vip -gt $e_vip ]; then
            reschedule_th "$e_name" "$e_nid" "$e_vip" "$slot" "$th_date"
            awk -F, -v date="$th_date" -v slot="$slot" '$4 != slot || $5 != date' $TH > $TH.tmp && mv $TH.tmp $TH
            echo "$name,$nid,$vip,$slot,$th_date" >> $TH
        else
            reschedule_th "$name" "$nid" "$vip" "$slot" "$th_date"
        fi
    else
        echo "$name,$nid,$vip,$slot,$th_date" >> $TH
    fi

    sort_th
}

reschedule_th() {
    local name=$1
    local nid=$2
    local vip=$3
    local slot=$4
    local th_date=$5

    case $slot in
        "Evening") n_slot="Night"; n_date="$th_date";;
        "Night") n_slot="Evening"; n_date=$(date -I -d "$th_date + 1 day");;
    esac

    fin_book_th=$(awk -F, -v date="$n_date" -v slot="$n_slot" '$4 == slot && $5 == date {print $0}' $TH)
    
    if [ -n "$fin_book_th" ]; then
        IFS=',' read -r e_name e_nid e_vip e_slot fin_book_th_date <<< "$fin_book_th"

        if [ $vip -gt $e_vip ]; then
            reschedule_th "$e_name" "$e_nid" "$e_vip" "$n_slot" "$n_date"
            awk -F, -v date="$n_date" -v slot="$n_slot" '$4 != slot || $5 != date' $TH > $TH.tmp && mv $TH.tmp $TH
            echo "$name,$nid,$vip,$n_slot,$n_date" >> $TH
        else
            reschedule_th "$name" "$nid" "$vip" "$n_slot" "$n_date"
        fi
    else
        echo "$name,$nid,$vip,$n_slot,$n_date" >> $TH
    fi
}

th_avi() {
    local today=$(date -I)
    local n_week=$(date -I -d "$today + 1 week")

    echo "Theater availability for the next week:"
    local date=$today
    while [ "$date" != "$n_week" ]; do
        echo "$(date -d "$date" +%d-%m-%y):"
        eve=$(awk -F, -v date="$date" '$4 == "Evening" && $5 == date {print $0}' $TH)
        night=$(awk -F, -v date="$date" '$4 == "Night" && $5 == date {print $0}' $TH)

        if [ -n "$eve" ]; then
            IFS=',' read -r name nid vip slot book_date <<< "$eve"
            echo "  Evening Slot (3:00 PM - 7:00 PM): Booked by $name"
        else
            echo "  Evening Slot (3:00 PM - 7:00 PM): Available"
        fi

        if [ -n "$night" ]; then
            IFS=',' read -r name nid vip slot book_date <<< "$night"
            echo "  Night Slot (8:00 PM - 12:00 AM): Booked by $name"
        else
            echo "  Night Slot (8:00 PM - 12:00 AM): Available"
        fi

        date=$(date -I -d "$date + 1 day")
    done
}

while true; do
    menu
    echo "Choose an option:"
    read c
    case $c in
        1) reserve ;;
        2) see_vac ;;
        3) cancel ;;
        4) book_th ;;
        5) th_avi ;;
        6) echo "Exiting program."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done
[ $# -eq 1 ] && sed -e 's/deal with increment/deal_with_increment/' -e 's/deal into new stack/deal_into_new_stack/' $1 > "$1-preprocessed"

#Masa Itmazi 1200814 Hatem Hussien 1200894
echo "Do you have a dictionary file? (yes/no)"
read answer

while [ "$answer" != "yes" ] && [ "$answer" != "no" ]; do
    echo "Invalid input. Please enter yes or no: "
    read answer
done

declare -A unique_buffer # Create an associative array to store the dictionary entries
if [ "$answer" = "yes" ]; then
    echo "Please enter the path of the dictionary file:"
    read filepath
    # Check if the file exists
    while [ ! -f "$filepath" ]; do
        echo "File does not exist. Please enter a valid file path:"
        read filepath
    done
    # Read the dictionary file line by line
    while IFS=" " read -r word address; do
        unique_buffer["$word"]=$address # Store the dictionary entries in the associative array
    done < "$filepath"

    cat "$filepath"
else
    echo "Enter the file name for the new dictionary:"
    read new_file

    touch "$new_file"
    echo "File '$new_file' was created."
fi

 input=false

while [ "$input" = false ]; do
    echo "Please enter c compresscompression  or d decompress  decompression'"
    read answer2

    if [ "$answer2" = "c" ] || [ "$answer2" = "compress" ] || [ "$answer2" = "compression" ]; then
        echo ".....COMPRESSION MODE....."
        input=true
        echo "Please enter the file you want to compress:"
        word=""
        alphabetic_words=()
        special_chars=()
        read file_path

        # Read the entire file content into the sentence variable
        sentence=$(cat "$file_path")
 
        # Print the contents of the sentence
        echo "THE CONTENTS OF THE FILE TO BE COMPRESSED:"
        echo "$sentence"
        echo "THE SIZE OF THE UNCOMPRESSED FILE IS:"
        # Calculate the size of the uncompressed file
        num_of_chars_uncomp=$(wc -c < "$file_path")
        size_of_uncomp=$((num_of_chars_uncomp * 16))
        echo "$size_of_uncomp"

        word=""
        alphabetic_words=()
        special_chars=()

        
     # loop through two arrays when for characters and the other for spcieal character and then store them in a buffer 
       #-r used for backslash
       #-n1 used for one character at a time
        while IFS= read -rn1 char; do
        #if if the charter alphapetic add it to the word
            if [[ "$char" =~ [[:alpha:]] ]]; then
            #if the special char is not empty add it to the array
                if [[ -n "$special_chars" ]]; then
                    alphabetic_words+=("${special_chars[@]}")
                    special_chars=()
                fi
                #add the char to the word
                word="$word$char"
                #if the char is a special char or space add it to the special char array
            elif [[ "$char" == " " ]]; then
                if [[ -n "$word" ]]; then
                    alphabetic_words+=("$word")
                    #empty the word
                    word=""
                fi
                #add the space to the array
                alphabetic_words+=(" ")
            else
                if [[ -n "$word" ]]; then
                #add the word to the array
                    alphabetic_words+=("$word")
                    word=""
                fi
                #add the special char to the array
                if [[ -n "$char" ]]; then
                    alphabetic_words+=("$char")
                fi
            fi
        done <<< "$sentence"


        #if the word is not empty add it to the array
        if [[ -n "$word" ]]; then
            alphabetic_words+=("$word")
        fi
# mix the two arrays togather

        combined_array=("${alphabetic_words[@]}" "${special_chars[@]}")



address=0
#address1=0
# exams if there is any thing in unique buffer if not do nothing

	for word in "${!unique_buffer[@]}"; do
    #if the word is not empty add it to the array
	    if [[ -z "${unique_buffer[$word]}" ]]; then
		unique_buffer["$word"]=$address
        #add the word to the dictionary file
		printf "%s 0x%.4X\n" "$word" "$address" >> "$filepath"
		((address++))
	    fi
	done

	# calculate the last line in dictionary file to start count the new words loaded in dictionary it's value +1
	last_address=$(wc -l < "$filepath")


	# iterate through combined_array array
	for word in "${combined_array[@]}"; do
	    if [[ -z "${unique_buffer[$word]}" ]]; then
        #if the word is not empty add it to the array
		unique_buffer["$word"]=$address
		printf "%s 0x%.4X\n" "$word" "$address" >> "$filepath"
		((address++))
		((last_address++))
	    fi
	done


	# printing compressed file
	for word in "${combined_array[@]}"; do
	    printf "0x%.4X\n" "${unique_buffer["$word"]}"
	done > compressed.txt

      
        echo ".....COMPRESSION DONE....."
        echo "THE SIZE OF THE FILE COMPRESSED IS:"
        num_of_chars_comp=$(wc -l < compressed.txt)
        size_of_comp=$((num_of_chars_comp * 16))
        echo "$size_of_comp"

        echo "THE COMPRESSION RATIO IS:"
        compression_ratio=$((size_of_uncomp / size_of_comp))
        echo "$compression_ratio"
    elif [ "$answer2" = "d" ] || [ "$answer2" = "decompress" ] || [ "$answer2" = "decompression" ]; then
        input=true
        echo ".....DECOMPRESSION MODE....."
        echo "Please enter the dictionary file path:"
        read dictionary_path
        while [ ! -f "$dictionary_path" ]; do
            echo "Dictionary file does not exist. Please enter a valid file path:"
            read dictionary_path
        done

        declare -A unique_buffer_reverse

        while IFS=" " read -r word address; do
            address=${address//0x/}  # Remove '0x' prefix
            if [[ -z "$word" ]]; then
                word=" "
            fi
            unique_buffer_reverse[$((16#$address))]="$word"
        done < "$dictionary_path"

        echo "PLEASE ENTER THE COMPRESSED FILE PATH/NAME:"
        read compressed_path
        while [ ! -f "$compressed_path" ]; do
            echo "COMPRESSED FILE DOESN'T EXIST"
            read compressed_path
        done

        while IFS= read -r line; do
            line=${line//0x/}  # Remove '0x' prefix
            printf "% s" "${unique_buffer_reverse[$((16#$line))]}"
        done < "$compressed_path" > decompressed.txt

        echo "DECOMPRESSION COMPLETED"

    else
        echo "Invalid input. Please enter 'c'or 'compress', 'compression' or'd', 'decompress' or 'decompression' again."
    fi
done

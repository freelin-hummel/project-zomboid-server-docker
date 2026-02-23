#!/bin/bash

declare -A LOADED_MOD_IDS

normalize_mod_id() {
    local mod_id="$1"
    mod_id="${mod_id%$'\r'}"
    mod_id="${mod_id#${mod_id%%[![:space:]]*}}"
    mod_id="${mod_id%${mod_id##*[![:space:]]}}"
    mod_id="${mod_id#\\}"
    mod_id=$(printf '%s' "$mod_id" | sed "s/\\\\'/'/g")
    echo -n "$mod_id"
}

load_mod_ids_from_ini() {
    local ini_file="$1"

    if [ ! -f "$ini_file" ]; then
        return
    fi

    local mods_line
    mods_line=$(grep -m1 '^Mods=' "$ini_file" || true)
    if [ -z "$mods_line" ]; then
        return
    fi

    mods_line="${mods_line#Mods=}"
    IFS=';' read -ra mod_tokens <<< "$mods_line"

    for token in "${mod_tokens[@]}"; do
        local normalized
        normalized=$(normalize_mod_id "$token")
        if [ -n "$normalized" ]; then
            LOADED_MOD_IDS["$normalized"]=1
        fi
    done
}

mod_folder_is_loaded() {
    local mod_folder="$1"

    if [ ${#LOADED_MOD_IDS[@]} -eq 0 ]; then
        return 0
    fi

    while IFS= read -r -d '' mod_info; do
        local mod_id_line
        local mod_id
        mod_id_line=$(grep -m1 '^id=' "$mod_info" || true)
        if [ -z "$mod_id_line" ]; then
            continue
        fi

        mod_id="${mod_id_line#id=}"
        mod_id=$(normalize_mod_id "$mod_id")

        if [ -n "${LOADED_MOD_IDS[$mod_id]+x}" ]; then
            return 0
        fi
    done < <(find "$mod_folder" -maxdepth 3 -type f -name 'mod.info' -print0)

    return 1
}

# Function to recursively search for a folder name
search_folder() {
    local search_dir="$1"
    counter=1

    for item in "$search_dir"/*; do

        echo "Searching for maps: ($counter/$(ls -1 "$search_dir" | wc -l))"

        # Check if the given directory exists
        if [ -d "$search_dir" ]; then                
            # Check if there is a "maps" folder within the "mods" directory
            if [ -d "$item/mods" ]; then
                for mod_folder in "$item/mods"/*; do
                    if ! mod_folder_is_loaded "$mod_folder"; then
                        continue
                    fi

                    if [ -d "$mod_folder/media/maps" ]; then
                
                        # Copy maps to map folder
                        source_dirs=("$mod_folder/media/maps"/*)
                        map_dir=("${HOMEDIR}/pz-dedicated/media/maps")

                        for source_dir in "${source_dirs[@]}"; do
                            dir_name=$(basename "$source_dir")
                            if [ ! -d "$map_dir/$dir_name" ]; then
                                echo "Found map(s). Copying..."
                                cp -r "$mod_folder/media/maps"/* "${HOMEDIR}/pz-dedicated/media/maps"
                                echo "Successfully copied!"
                            fi
                        done

                        # Adds map names to a semicolon separated list and outputs it.
                        map_list=""
                        for dir in "$mod_folder/media/maps"/*/; do
                            if [ -d "$dir" ]; then
                                dir_name=$(basename "$dir")
                                map_list+="$dir_name;"     
                            fi
                        done
                        # Exports to .txt file to add to .ini file in entry.sh
                            echo -n "$map_list" >> "${HOMEDIR}/maps.txt"
                    fi
                done
            fi
        fi
        ((counter++))
    done
}

parent_folder="$1"
server_ini_file="$2"

if [ -n "$server_ini_file" ]; then
    load_mod_ids_from_ini "$server_ini_file"
fi

if [ ! -d "$parent_folder" ]; then
    exit 1
fi

# Call the search_folder function with the provided arguments
search_folder "$parent_folder"

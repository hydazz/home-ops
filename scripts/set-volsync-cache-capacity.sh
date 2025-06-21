#!/bin/bash

# Script to dynamically set VOLSYNC_CACHE_CAPACITY based on VOLSYNC_CAPACITY
# Sets cache capacity to 20% of the main capacity

set -euo pipefail

# Function to convert storage units to bytes for calculation
convert_to_bytes() {
    local value="$1"
    local number=$(echo "$value" | sed 's/[^0-9]*//g')
    local unit=$(echo "$value" | sed 's/[0-9]*//g')

    case "$(echo "$unit" | tr '[:lower:]' '[:upper:]')" in
        "KI"|"K")
            echo $((number * 1024))
            ;;
        "MI"|"M")
            echo $((number * 1024 * 1024))
            ;;
        "GI"|"G")
            echo $((number * 1024 * 1024 * 1024))
            ;;
        "TI"|"T")
            echo $((number * 1024 * 1024 * 1024 * 1024))
            ;;
        *)
            echo "$number"
            ;;
    esac
}

# Function to convert bytes back to human readable format
convert_from_bytes() {
    local bytes="$1"

    if [ "$bytes" -ge $((1024 * 1024 * 1024)) ]; then
        echo "$((bytes / (1024 * 1024 * 1024)))Gi"
    elif [ "$bytes" -ge $((1024 * 1024)) ]; then
        echo "$((bytes / (1024 * 1024)))Mi"
    elif [ "$bytes" -ge 1024 ]; then
        echo "$((bytes / 1024))Ki"
    else
        echo "${bytes}B"
    fi
}

# Function to round up to the nearest power of 2
round_to_power_of_2() {
    local value="$1"
    local power=1

    # Find the smallest power of 2 that is >= value
    while [ "$power" -lt "$value" ]; do
        power=$((power * 2))
    done

    echo "$power"
}

# Function to calculate 20% cache capacity, rounded up to power of 2
calculate_cache_capacity() {
    local capacity="$1"
    local bytes=$(convert_to_bytes "$capacity")
    local cache_bytes=$((bytes / 5))  # 20% = 1/5

    # Convert to appropriate unit for rounding
    local cache_value
    local cache_unit

    if [ "$cache_bytes" -ge $((1024 * 1024 * 1024)) ]; then
        # Work in Gi
        cache_value=$((cache_bytes / (1024 * 1024 * 1024)))
        cache_unit="Gi"
    elif [ "$cache_bytes" -ge $((1024 * 1024)) ]; then
        # Work in Mi
        cache_value=$((cache_bytes / (1024 * 1024)))
        cache_unit="Mi"
    else
        # Work in Mi with minimum of 1Mi
        cache_value=1
        cache_unit="Mi"
    fi

    # Ensure minimum cache size of 8Mi (reasonable minimum for power of 2)
    if [ "$cache_value" -lt 8 ] && [ "$cache_unit" = "Mi" ]; then
        cache_value=8
    elif [ "$cache_value" -lt 1 ] && [ "$cache_unit" = "Gi" ]; then
        # If less than 1Gi, convert to Mi and ensure minimum
        cache_value=$((cache_bytes / (1024 * 1024)))
        cache_unit="Mi"
        if [ "$cache_value" -lt 8 ]; then
            cache_value=8
        fi
        cache_value=$(round_to_power_of_2 "$cache_value")
    else
        # Round up to nearest power of 2
        cache_value=$(round_to_power_of_2 "$cache_value")
    fi

    echo "${cache_value}${cache_unit}"
}

# Function to process a single ks.yaml file
process_file() {
    local file="$1"
    local has_volsync_capacity=false
    local has_volsync_cache_capacity=false
    local volsync_capacity=""

    echo "Processing: $file"

    # Check if file contains VOLSYNC_CAPACITY
    if grep -q "VOLSYNC_CAPACITY:" "$file"; then
        has_volsync_capacity=true
        volsync_capacity=$(grep "VOLSYNC_CAPACITY:" "$file" | awk '{print $2}')
        echo "  Found VOLSYNC_CAPACITY: $volsync_capacity"
    fi

    if grep -q "VOLSYNC_CACHE_CAPACITY:" "$file"; then
        has_volsync_cache_capacity=true
        echo "  Found existing VOLSYNC_CACHE_CAPACITY, will overwrite"
    fi

    # If has capacity, add or update cache capacity
    if [ "$has_volsync_capacity" = true ]; then
        local cache_capacity=$(calculate_cache_capacity "$volsync_capacity")
        echo "  Calculated VOLSYNC_CACHE_CAPACITY: $cache_capacity"

        if [ "$has_volsync_cache_capacity" = true ]; then
            # Replace existing VOLSYNC_CACHE_CAPACITY
            sed -i '' "s/VOLSYNC_CACHE_CAPACITY:.*/VOLSYNC_CACHE_CAPACITY: $cache_capacity/" "$file"
            echo "  ✅ Updated VOLSYNC_CACHE_CAPACITY: $cache_capacity"
        else
            # Add VOLSYNC_CACHE_CAPACITY after VOLSYNC_CAPACITY
            sed -i '' "/VOLSYNC_CAPACITY:/a\\
      VOLSYNC_CACHE_CAPACITY: $cache_capacity" "$file"
            echo "  ✅ Added VOLSYNC_CACHE_CAPACITY: $cache_capacity"
        fi
    else
        echo "  No VOLSYNC_CAPACITY found, skipping"
    fi
}

# Main execution
main() {
    local workspace_root="/Users/ahyde/GitHub/hydazz/home-ops"
    local dry_run=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--dry-run] [--help]"
                echo ""
                echo "Options:"
                echo "  --dry-run    Show what would be changed without making changes"
                echo "  --help       Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    echo "🔍 Searching for ks.yaml files with VOLSYNC_CAPACITY..."
    echo ""

    # Find all ks.yaml files that contain VOLSYNC_CAPACITY
    local files_to_process=()
    while IFS= read -r -d '' file; do
        if grep -q "VOLSYNC_CAPACITY:" "$file"; then
            files_to_process+=("$file")
        fi
    done < <(find "$workspace_root/kubernetes/apps" -name "ks.yaml" -print0)

    if [ ${#files_to_process[@]} -eq 0 ]; then
        echo "No ks.yaml files with VOLSYNC_CAPACITY found."
        exit 0
    fi

    echo "Found ${#files_to_process[@]} files with VOLSYNC_CAPACITY:"
    for file in "${files_to_process[@]}"; do
        echo "  - $file"
    done
    echo ""

    if [ "$dry_run" = true ]; then
        echo "🔍 DRY RUN MODE - No changes will be made"
        echo ""

        for file in "${files_to_process[@]}"; do
            local has_cache=$(grep -q "VOLSYNC_CACHE_CAPACITY:" "$file" && echo "true" || echo "false")
            local capacity=$(grep "VOLSYNC_CAPACITY:" "$file" | awk '{print $2}')
            local cache_capacity=$(calculate_cache_capacity "$capacity")

            if [ "$has_cache" = "false" ]; then
                echo "Would add to $file:"
                echo "  VOLSYNC_CAPACITY: $capacity"
                echo "  VOLSYNC_CACHE_CAPACITY: $cache_capacity (calculated as 20% of capacity)"
                echo ""
            else
                local current_cache=$(grep "VOLSYNC_CACHE_CAPACITY:" "$file" | awk '{print $2}')
                echo "Would update $file:"
                echo "  VOLSYNC_CAPACITY: $capacity"
                echo "  VOLSYNC_CACHE_CAPACITY: $current_cache → $cache_capacity (calculated as 20% of capacity)"
                echo ""
            fi
        done
    else
        echo "🚀 Processing files..."
        echo ""

        for file in "${files_to_process[@]}"; do
            process_file "$file"
        done

        echo "✅ Processing complete!"
    fi
}

# Run the script
main "$@"

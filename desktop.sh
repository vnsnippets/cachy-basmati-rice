echo ""
echo "󰀻  Scanning applications in /usr/share/applications..."
sudo -v
echo "Skipping the prompt (y/n) will keep the current application setup unchanged."
    
for file in /usr/share/applications/*.desktop; do
    [ -e "$file" ] || continue
    
    # Extract details
    app_filename=$(basename "$file")
    app_name=$(grep "^Name=" "$file" | head -1 | cut -d'=' -f2)
    app_desc=$(grep "^Comment=" "$file" | head -1 | cut -d'=' -f2)
    
    # Check current NoDisplay status
    if grep -q "NoDisplay=true" "$file"; then
        current_status="󰈈  Hidden"
    else
        current_status="󰈈  Visible"
    fi

    echo "------------------------------------------------"
    echo "  File:   $app_filename"
    echo "󱓞  Name:   $app_name"
    echo "󰛨  Desc:   ${app_desc:-No description available}"
    echo "󰂵  Status: $current_status"
    
    while true; do
        read -p "󰗚  Show in application list? (y/n): " choice
        
        # If the user just presses Enter, choice is empty
        if [[ -z "$choice" ]]; then
            echo "  󰒲  No changes made."
            break
        fi
        
        case "${choice,,}" in
            y)
                echo "   Setting to visible..."
                sudo sed -i '/^NoDisplay=/d' "$file"
                break
                ;;
            n)
                echo "  󰈈  Setting to hidden..."
                # Remove existing and append to ensure it exists
                sudo sed -i '/^NoDisplay=/d' "$file"
                echo "NoDisplay=true" | sudo tee -a "$file" > /dev/null
                break
                ;;
            *)
                echo "    Invalid input. Please enter y or n or nothing"
                echo "        (yes) y: Show in Launcher"
                echo "        (no)  n: Hide in Launcher"
                echo "        (enter): Leave unchanged"
                ;;
        esac
    done
done
sudo -k
echo "  Desktop apps setup complete."
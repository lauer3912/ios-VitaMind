#!/bin/bash
# VitaMind Screenshot Generator - Placeholder Generation
# Creates placeholder screenshots at required App Store dimensions

OUTPUT_DIR="$HOME/Desktop/ios-VitaMind/AppStore/Screenshots"
mkdir -p "$OUTPUT_DIR"

# Colors - matching VitaMind brand
VIOLET="#7C3AED"
MINT="#10B981"
AMBER="#F59E0B"
BG_LIGHT="#F8FAFC"
BG_DARK="#1E293B"

# Function to create placeholder screenshot
create_placeholder() {
    local name=$1
    local width=$2
    local height=$3
    local bg_color=$4
    local accent_color=$5
    local label=$6
    
    echo "  Creating $name (${width}x${height})..."
    magick -size ${width}x${height} xc:"$bg_color" \
        -fill "$accent_color" -draw "roundrectangle 0,0 ${width},$((height/6)) 0,0" \
        -fill "$accent_color" -draw "roundrectangle $((width/20)),$((height*2/10)) $((width*9/20)),$((height*4/10)) 20,20" \
        -fill "$accent_color" -draw "roundrectangle $((width*11/20)),$((height*2/10)) $((width*19/20)),$((height*4/10)) 20,20" \
        -fill "$accent_color" -draw "roundrectangle $((width/20)),$((height*5/10)) $((width*9/20)),$((height*7/10)) 20,20" \
        -fill "$accent_color" -draw "roundrectangle $((width*11/20)),$((height*5/10)) $((width*19/20)),$((height*7/10)) 20,20" \
        "$OUTPUT_DIR/${name}.png"
}

echo "🍎 Generating VitaMind App Store placeholder screenshots..."

# iPhone 6.5" (1284×2778) - 5 screenshots required
create_placeholder "iPhone65_Health" 1284 2778 "$BG_LIGHT" "$VIOLET" "Health"
create_placeholder "iPhone65_Habits" 1284 2778 "$BG_LIGHT" "$MINT" "Habits"
create_placeholder "iPhone65_AI" 1284 2778 "$BG_LIGHT" "$VIOLET" "AI"
create_placeholder "iPhone65_Settings" 1284 2778 "$BG_LIGHT" "#64748B" "Settings"
create_placeholder "iPhone65_Health_Dark" 1284 2778 "$BG_DARK" "$VIOLET" "Health"

# iPhone 5.5" (1242×2208) - 3 screenshots required
create_placeholder "iPhone55_Health" 1242 2208 "$BG_LIGHT" "$VIOLET" "Health"
create_placeholder "iPhone55_Habits" 1242 2208 "$BG_LIGHT" "$MINT" "Habits"
create_placeholder "iPhone55_AI" 1242 2208 "$BG_LIGHT" "$VIOLET" "AI"

# iPad Pro 12.9" (2048×2732) - 3 screenshots required
create_placeholder "iPad_Health" 2048 2732 "$BG_LIGHT" "$VIOLET" "Health"
create_placeholder "iPad_Habits" 2048 2732 "$BG_LIGHT" "$MINT" "Habits"
create_placeholder "iPad_AI" 2048 2732 "$BG_LIGHT" "$VIOLET" "AI"

echo ""
echo "✅ Placeholder screenshots saved to: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR/"
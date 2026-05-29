#!/bin/bash
# VitaMind Screenshot Generator v2 - More placeholder variations
# Creates App Store screenshots at required dimensions

OUTPUT_DIR="$HOME/Desktop/ios-VitaMind/AppStore/Screenshots"
mkdir -p "$OUTPUT_DIR"

# Colors
VIOLET="#7C3AED"
MINT="#10B981"
AMBER="#F59E0B"
ROSE="#F43F5E"
SKY="#0EA5E9"
BG_LIGHT="#F8FAFC"
BG_DARK="#1E293B"

# Function to create a colored card placeholder
create_screenshot() {
    local name=$1
    local width=$2
    local height=$3
    local bg=$4
    local c1=$5
    local c2=$6
    local c3=$7
    local c4=$8
    
    echo "  Creating $name (${width}x${height})..."
    magick -size ${width}x${height} xc:"$bg" \
        -fill "$c1" -draw "roundrectangle 0,0 ${width},$((height/6)) 0,0" \
        -fill "$c2" -draw "roundrectangle $((width*3/20)),$((height*15/100)) $((width*9/20)),$((height*45/100)) 25,25" \
        -fill "$c3" -draw "roundrectangle $((width*11/20)),$((height*15/100)) $((width*17/20)),$((height*45/100)) 25,25" \
        -fill "$c4" -draw "roundrectangle $((width*3/20)),$((height*55/100)) $((width*9/20)),$((height*85/100)) 25,25" \
        -fill "$c2" -draw "roundrectangle $((width*11/20)),$((height*55/100)) $((width*17/20)),$((height*85/100)) 25,25" \
        "$OUTPUT_DIR/${name}.png"
}

echo "🍎 Generating more VitaMind screenshot placeholders..."

# Dark mode variants
create_screenshot "iPhone65_Habits_Dark" 1284 2778 "$BG_DARK" "$VIOLET" "$MINT" "$AMBER" "$ROSE"
create_screenshot "iPhone65_AI_Dark" 1284 2778 "$BG_DARK" "$SKY" "$VIOLET" "$MINT" "$AMBER"
create_screenshot "iPhone65_Settings_Dark" 1284 2778 "$BG_DARK" "#64748B" "#475569" "#334155" "$ROSE"

# Light mode variations
create_screenshot "iPhone55_Habits_Light" 1242 2208 "$BG_LIGHT" "$MINT" "$VIOLET" "$AMBER" "$SKY"
create_screenshot "iPhone55_Settings" 1242 2208 "$BG_LIGHT" "#64748B" "#94A3B8" "#CBD5E1" "$ROSE"

# iPad additional variants
create_screenshot "iPad_Habits_Light" 2048 2732 "$BG_LIGHT" "$MINT" "$VIOLET" "$AMBER" "$SKY"
create_screenshot "iPad_Settings" 2048 2732 "$BG_LIGHT" "#64748B" "#475569" "#334155" "$ROSE"

echo ""
echo "✅ Additional screenshots saved to: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR/"
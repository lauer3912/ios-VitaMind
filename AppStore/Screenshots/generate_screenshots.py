#!/usr/bin/env python3
"""
VitaMind Screenshot Generator
Creates App Store screenshots using PIL
"""
from PIL import Image, ImageDraw, ImageFont
import os

# Output directory
OUTPUT_DIR = os.path.expanduser("~/Desktop/ios-VitaMind/AppStore/Screenshots")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Colors (violet/mint/amber theme matching the icon)
VIOLET = "#7C3AED"
MINT = "#10B981"
AMBER = "#F59E0B"
BG_LIGHT = "#F8FAFC"
BG_DARK = "#1E293B"

def create_health_screenshot(width, height, dark=False):
    """Create Health Dashboard screenshot"""
    bg = BG_DARK if dark else BG_LIGHT
    text_color = "white" if dark else "#1E293B"
    card_bg = "#334155" if dark else "white"
    
    img = Image.new('RGB', (width, height), bg)
    draw = ImageDraw.Draw(img)
    
    # Header
    draw.rectangle([(0, 0), (width, 200)], fill=VIOLET)
    
    # Title
    draw.text((60, 60), "Health", fill="white")
    draw.text((60, 100), "VitaMind", fill="white")
    
    # Metrics cards
    card_y = 250
    card_h = 200
    card_w = width // 2 - 80
    
    # Heart Rate Card
    draw.rectangle([(40, card_y), (width//2-40, card_y+card_h)], fill=card_bg, outline=VIOLET, width=3)
    draw.text((60, card_y+30), "❤️ Heart Rate", fill=MINT if not dark else MINT)
    draw.text((60, card_y+80), "72", fill=text_color)
    draw.text((60, card_y+130), "BPM", fill="gray")
    
    # Steps Card
    draw.rectangle([(width//2+40, card_y), (width-40, card_y+card_h)], fill=card_bg, outline=MINT, width=3)
    draw.text((width//2+60, card_y+30), "👟 Steps", fill=MINT if not dark else MINT)
    draw.text((width//2+60, card_y+80), "8,542", fill=text_color)
    draw.text((width//2+60, card_y+130), "steps", fill="gray")
    
    # Sleep Card
    card_y2 = card_y + card_h + 40
    draw.rectangle([(40, card_y2), (width//2-40, card_y2+card_h)], fill=card_bg, outline=AMBER, width=3)
    draw.text((60, card_y2+30), "🌙 Sleep", fill=AMBER)
    draw.text((60, card_y2+80), "7.5", fill=text_color)
    draw.text((60, card_y2+130), "hours", fill="gray")
    
    # Active Card
    draw.rectangle([(width//2+40, card_y2), (width-40, card_y2+card_h)], fill=card_bg, outline=AMBER, width=3)
    draw.text((width//2+60, card_y2+30), "🔥 Active", fill=AMBER)
    draw.text((width//2+60, card_y2+80), "45", fill=text_color)
    draw.text((width//2+60, card_y2+130), "minutes", fill="gray")
    
    return img

def create_habits_screenshot(width, height, dark=False):
    """Create Habit Tracking screenshot"""
    bg = BG_DARK if dark else BG_LIGHT
    text_color = "white" if dark else "#1E293B"
    card_bg = "#334155" if dark else "white"
    
    img = Image.new('RGB', (width, height), bg)
    draw = ImageDraw.Draw(img)
    
    # Header
    draw.rectangle([(0, 0), (width, 200)], fill=MINT)
    draw.text((60, 60), "Habits", fill="white")
    draw.text((60, 100), "Track Your Goals", fill="white")
    
    # Habit items
    habits = [
        ("💧", "Drink Water", "5/8", True),
        ("🧘", "Meditation", "1/1", True),
        ("🏃", "Exercise", "0/1", False),
        ("😴", "Sleep Early", "0/1", False),
    ]
    
    y = 260
    for emoji, name, count, done in habits:
        draw.rectangle([(40, y), (width-40, y+120)], fill=card_bg, outline=MINT if done else "gray", width=2)
        draw.text((70, y+30), emoji, fill="white")
        draw.text((140, y+30), name, fill=text_color)
        draw.text((width-180, y+30), count, fill=MINT if done else "gray")
        if done:
            draw.text((width-100, y+30), "✓", fill=MINT)
        y += 140
    
    return img

def create_ai_screenshot(width, height, dark=False):
    """Create AI Assistant screenshot"""
    bg = BG_DARK if dark else BG_LIGHT
    text_color = "white" if dark else "#1E293B"
    card_bg = "#334155" if dark else "white"
    
    img = Image.new('RGB', (width, height), bg)
    draw = ImageDraw.Draw(img)
    
    # Header
    draw.rectangle([(0, 0), (width, 200)], fill=VIOLET)
    draw.text((60, 60), "AI Assistant", fill="white")
    draw.text((60, 100), "Your Health Coach", fill="white")
    
    # Chat bubbles
    draw.rectangle([(40, 240), (width-40, 340)], fill=card_bg)
    draw.text((60, 260), "🤖 AI", fill=VIOLET)
    draw.text((60, 295), "Hello! How can I help you", fill=text_color)
    draw.text((60, 320), "today?", fill=text_color)
    
    draw.rectangle([(width//3, 380), (width-40, 480)], fill=VIOLET)
    draw.text((width//3+20, 410), "Show me my health tips", fill="white")
    
    draw.rectangle([(40, 520), (width-40, 620)], fill=card_bg)
    draw.text((60, 540), "🤖 AI", fill=VIOLET)
    draw.text((60, 575), "Based on your data, I", fill=text_color)
    draw.text((60, 600), "recommend drinking more", fill=text_color)
    
    # Input field
    draw.rectangle([(40, height-150), (width-40, height-90)], fill=card_bg, outline="gray")
    draw.text((60, height-130), "Ask me anything...", fill="gray")
    draw.rectangle([(width-120, height-150), (width-40, height-90)], fill=VIOLET)
    draw.text((width-100, height-125), "Send", fill="white")
    
    return img

def create_settings_screenshot(width, height, dark=False):
    """Create Settings screenshot"""
    bg = BG_DARK if dark else BG_LIGHT
    text_color = "white" if dark else "#1E293B"
    card_bg = "#334155" if dark else "white"
    
    img = Image.new('RGB', (width, height), bg)
    draw = ImageDraw.Draw(img)
    
    # Header
    draw.rectangle([(0, 0), (width, 200)], fill="#64748B")
    draw.text((60, 60), "Settings", fill="white")
    
    # Settings items
    settings = [
        ("❤️", "HealthKit", True),
        ("⌚", "Apple Watch", True),
        ("🔔", "Reminders", True),
        ("💧", "Hydration", True),
        ("🔒", "Privacy Policy", True),
        ("ℹ️", "Version 3.0.0", False),
    ]
    
    y = 240
    for emoji, name, arrow in settings:
        draw.rectangle([(40, y), (width-40, y+100)], fill=card_bg)
        draw.text((70, y+30), emoji, fill="white")
        draw.text((140, y+30), name, fill=text_color)
        if arrow:
            draw.text((width-100, y+30), ">", fill="gray")
        y += 120
    
    return img

def main():
    """Generate all screenshots"""
    screenshots = [
        # iPhone 6.5" (1284×2778)
        ("iPhone65_Health", 1284, 2778, create_health_screenshot),
        ("iPhone65_Habits", 1284, 2778, create_habits_screenshot),
        ("iPhone65_AI", 1284, 2778, create_ai_screenshot),
        ("iPhone65_Settings", 1284, 2778, create_settings_screenshot),
        ("iPhone65_Health_Dark", 1284, 2778, lambda w, h, d=False: create_health_screenshot(w, h, True)),
        
        # iPhone 5.5" (1242×2208)
        ("iPhone55_Health", 1242, 2208, create_health_screenshot),
        ("iPhone55_Habits", 1242, 2208, create_habits_screenshot),
        ("iPhone55_AI", 1242, 2208, create_ai_screenshot),
        
        # iPad Pro 12.9" (2048×2732)
        ("iPad_Health", 2048, 2732, create_health_screenshot),
        ("iPad_Habits", 2048, 2732, create_habits_screenshot),
        ("iPad_AI", 2048, 2732, create_ai_screenshot),
    ]
    
    print("Generating VitaMind App Store screenshots...")
    
    for name, width, height, creator in screenshots:
        print(f"  Creating {name} ({width}×{height})...")
        img = creator(width, height)
        filepath = os.path.join(OUTPUT_DIR, f"{name}.png")
        img.save(filepath, "PNG")
        print(f"    Saved: {filepath}")
    
    print(f"\n✅ All screenshots saved to: {OUTPUT_DIR}")
    print(f"   Total: {len(screenshots)} screenshots")

if __name__ == "__main__":
    main()
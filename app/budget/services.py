import colorsys
import random

def generate_unique_color(existing_colors, index):
    golden_ratio = 0.61803398875
    start_hue = random.random()
    hue = (start_hue + index * golden_ratio) % 1.0
    saturation = random.uniform(0.5, 0.8)
    lightness = random.uniform(0.6, 0.85)

    r, g, b = colorsys.hls_to_rgb(hue, lightness, saturation)
    color = f"#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}"

    while color in existing_colors:
        hue = (hue + 0.05) % 1.0
        r, g, b = colorsys.hls_to_rgb(hue, lightness, saturation)
        color = f"#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}"

    existing_colors.add(color)
    return color

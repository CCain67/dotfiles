"""Generates a random background image based on theme colors."""

import random
from PIL import Image, ImageDraw

from colors import BORDER_COLOR, BACKGROUND_COLOR, COLOR_POOL


def hex_to_rgb(hex_color: str) -> tuple:
    """Helper function to convert hex to RGB"""
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


image_width = 1920
image_height = 1080
square_size = 20  # size of each square in the grid, can be any divisor of 120

# convert hex colors to RGB
border_color = hex_to_rgb(BORDER_COLOR)
default_color = hex_to_rgb(BACKGROUND_COLOR)
color_pool = [hex_to_rgb(color) for color in list(COLOR_POOL.values())]

# calculate the number of squares for each axis
num_squares_x = image_width // square_size
num_squares_y = image_height // square_size

# create an empty image with a white background
image = Image.new("RGB", (image_width, image_height), default_color)
draw = ImageDraw.Draw(image)

# for keeping track of which squares are colored
colored_grid = [[False for _ in range(num_squares_x)] for _ in range(num_squares_y)]

if __name__ == "__main__":
    for j in range(num_squares_y):
        for i in range(num_squares_x):
            square_index = j * num_squares_x + i
            probability = max(98 - 2.5 * j, 0) / 100
            if random.random() < probability:
                fill_color = random.choice(color_pool)
                colored_grid[j][i] = True
            else:
                fill_color = default_color

            top_left = (i * square_size, j * square_size)
            bottom_right = ((i + 1) * square_size - 1, (j + 1) * square_size - 1)
            draw.rectangle(
                [top_left, bottom_right], fill=fill_color, outline=border_color
            )

    image.save("/home/chase/.config/awesome/backgrounds/generated_wallpaper.png")

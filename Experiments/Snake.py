import pygame
import random

# Set the dimensions of the game window
WINDOW_WIDTH = 400
WINDOW_HEIGHT = 400

# Set the dimensions of the grid
GRID_SIZE = 20

# Set the speed of the snake
SNAKE_SPEED = 20

# Set the colors for the game
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GREEN = (0, 255, 0)
RED = (255, 0, 0)

# Initialize the Pygame library
pygame.init()

# Set the dimensions of the game window and create the window
window = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))
pygame.display.set_caption("Snake")

# Define a function to draw the snake
def draw_snake(snake):
    for segment in snake:
        pygame.draw.rect(window, GREEN, (segment[0], segment[1], GRID_SIZE, GRID_SIZE))

# Define a function to generate a random position
def generate_random_position():
    x = random.randint(0, WINDOW_WIDTH - GRID_SIZE) // GRID_SIZE * GRID_SIZE
    y = random.randint(0, WINDOW_HEIGHT - GRID_SIZE) // GRID_SIZE * GRID_SIZE
    return (x, y)

# Define the main function
def main():
    # Initialize the snake
    snake = [(200, 200), (220, 200), (240, 200)]

    # Initialize the direction of the snake
    direction = "LEFT"

    # Initialize the food
    food = generate_random_position()

    # Initialize the score
    score = 0

    # Set the clock for the game
    clock = pygame.time.Clock()

    # Run the game loop
    while True:
        # Handle events
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                quit()

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_LEFT and direction != "RIGHT":
                    direction = "LEFT"
                elif event.key == pygame.K_RIGHT and direction != "LEFT":
                    direction = "RIGHT"
                elif event.key == pygame.K_UP and direction != "DOWN":
                    direction = "UP"
                elif event.key == pygame.K_DOWN and direction != "UP":
                    direction = "DOWN"

        # Move the snake
        if direction == "LEFT":
            snake.pop()
            x = snake[0][0] - GRID_SIZE
            y = snake[0][1]
            snake.insert(0, (x, y))
        elif direction == "RIGHT":
            snake.pop()
            x = snake[0][0] + GRID_SIZE
            y = snake[0][1]
            snake.insert(0, (x, y))
        elif direction == "UP":
            snake.pop()
            x = snake[0][0]
            y = snake[0][1] - GRID_SIZE
            snake.insert(0, (x, y))
        elif direction == "DOWN":
            snake.pop()
            x = snake[0][0]
            y = snake[0][1] + GRID_SIZE
            snake.insert(0, (x, y))

        # Check if the snake has collided with the wall
        if snake[0][0] < 0 or snake[0][0] >= WINDOW_WIDTH or snake[0][1] < 0 or snake[0][1] >= WINDOW_HEIGHT:
            pygame.quit()
            quit()

        # Check if the snake has collided with itself
            for segment in snake[1:]:
            if segment == snake[0]:
            pygame.quit()
            quit()


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

extern void process_image_asm(unsigned char *image, int width, int height, int channels);
void process_image_c(unsigned char *image, int width, int height, int channels);

void print_array(unsigned char *image, int width, int height, int channels) {
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            printf("( ");
            for (int c = 0; c < channels; c++) {
                printf("%d ", image[y * width * channels + x * channels + c]);
            }
            printf(")");
            printf(" ");
        }
        printf("\n");
    }
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Использование: %s <входной файл> <выходной файл>\n", argv[0]);
        return 1;
    }

    // Загрузка изображения
    int width, height, channels;
    unsigned char *image = stbi_load(argv[1], &width, &height, &channels, 0);
    if (!image) {
        fprintf(stderr, "Ошибка загрузки изображения\n");
        return 1;
    }

    // print_array(image, width, height, channels);
    // Обработка изображения (замените на process_image_asm для ассемблера)
    //process_image_c(image, width, height, channels);
    process_image_asm(image, width, height, channels);

    //printf("\n\n");
    //print_array(image, width, height, channels);
    // Сохранение результата
    if (!stbi_write_jpg(argv[2], width, height, channels, image, width * channels)) {
        fprintf(stderr, "Ошибка сохранения изображения\n");
    }

    stbi_image_free(image);
    return 0;
}

// Функция обработки на C: умножение матриц 3x3 (усреднение)
void process_image_c(unsigned char *image, int width, int height, int channels) {
    unsigned char *buffer = malloc(width * height * channels);
    if (!buffer) {
        fprintf(stderr, "Ошибка выделения памяти\n");
        exit(1);
    }

    // Копия данных для обработки
    memcpy(buffer, image, width * height * channels);

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int mirrored_y = height - 1 - y; // Инвертируем X
            for (int c = 0; c < channels; c++) {
                // Копируем пиксель из исходного изображения в буфер с отражением
                buffer[y * width * channels + x * channels + c] = 
                    image[mirrored_y * width * channels + x * channels + c];
            }
        }
    }

    memcpy(image, buffer, width * height * channels);
    free(buffer);
}
